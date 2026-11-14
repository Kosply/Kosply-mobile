# Implementasi Local Storage & Data Persistence (Tugas #9)

Dokumen ini menjelaskan cara kerja lapisan penyimpanan lokal Kosply Mobile:
cache offline-first berbasis Drift, penyimpanan pengaturan dengan
shared_preferences, penyimpanan rahasia dengan flutter_secure_storage, sampai
sesi login dan alur Google sign-up. Semua data yang tampil di UI berasal dari
cache lokal. UI berlangganan `Stream` Drift (`.watch()`), jadi begitu cache
berubah, layar otomatis re-render tanpa perlu menunggu koneksi ke backend.
Aliran datanya satu arah dan tidak pernah dilangkahi: **Drift (tabel) → DAO →
Repository → Provider → Widget**, sehingga widget tidak pernah menyentuh
database secara langsung.

## 1. Database Drift

Setiap tabel yang isinya berasal dari backend mewarisi mixin `CacheMarker`
yang menambahkan dua kolom penanda: `updatedAt` (kapan baris terakhir berubah)
dan `lastFetched` (kapan terakhir disegarkan dari server). Keduanya disimpan
sebagai UTC millis supaya bisa dibandingkan langsung tanpa parsing tanggal.
Nilai waktunya dihasilkan fungsi `utcMillisNow()`.

**File: `lib/core/database/tables/cache_marker.dart:14`**

```dart
mixin CacheMarker on Table {
  /// @dev UTC millis of the last write to this row.
  IntColumn get updatedAt => integer().withDefault(const Constant(0))();

  /// @dev UTC millis of the last successful backend refresh.
  IntColumn get lastFetched => integer().withDefault(const Constant(0))();
}

/// @notice Current time as UTC milliseconds since epoch.
int utcMillisNow() => DateTime.now().toUtc().millisecondsSinceEpoch;
```

Seluruh tabel dan DAO didaftarkan di satu database. Ada sepuluh tabel
(Users, Products, Favorites, Conversations, Messages, HelpTopics,
SupportTickets, SupportMessages, AiConversations, AiMessages) dan lima DAO
satu per domain (Catalog, Inbox, Support, AiChat, Account). Aplikasi membuka
file database lewat `driftDatabase(name: 'kosply_mobile')`, sedangkan tes
memakai varian in-memory `AppDatabase.memory()` supaya setiap tes berdiri
sendiri-sendiri tanpa saling mewarisi data. Kode `*.g.dart` digenerate ulang
dengan `dart run build_runner build --delete-conflicting-outputs` setiap kali
tabel atau DAO berubah.

**File: `lib/core/database/app_database.dart:27`**

```dart
@DriftDatabase(
  tables: <Type>[
    Users, Products, Favorites,
    Conversations, Messages,
    HelpTopics, SupportTickets, SupportMessages,
    AiConversations, AiMessages,
  ],
  daos: <Type>[CatalogDao, InboxDao, SupportDao, AiChatDao, AccountDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// @notice Opens an isolated in-memory database (tes).
  AppDatabase.memory() : super(NativeDatabase.memory());

  /// @notice Opens the on-device database file.
  static QueryExecutor openDefault() => driftDatabase(name: 'kosply_mobile');

  @override
  int get schemaVersion => 1;
}
```

Di dalam DAO, setiap query reaktif punya pasangan "sekali baca". Versi stream
(`.watch()`) dipakai UI agar layar ikut berubah begitu cache ditulis ulang,
sedangkan versi `Once()` dipakai alur imperatif dan tes yang tidak butuh
bookkeeping stream. Keduanya memakai urutan dan filter yang sama persis
supaya hasilnya tidak pernah berbeda.

**File: `lib/core/database/daos/ai_chat_dao.dart:24`**

```dart
/// @notice Streams every conversation, newest activity first.
Stream<List<AiConversationRow>> watchConversations() {
  return (select(aiConversations)
        ..orderBy(<OrderingTerm Function($AiConversationsTable)>[
          ($AiConversationsTable row) =>
              OrderingTerm.desc(row.lastMessageAt),
        ]))
      .watch();
}

/// @notice Reads every conversation once (one-shot twin of watchConversations).
Future<List<AiConversationRow>> conversationsOnce() {
  return (select(aiConversations)
        ..orderBy(<OrderingTerm Function($AiConversationsTable)>[
          ($AiConversationsTable row) =>
              OrderingTerm.desc(row.lastMessageAt),
        ]))
      .get();
}
```

Semua penulisan multi-baris dibungkus `transaction()` supaya refresh yang
gagal tidak meninggalkan data separuh jadi. Contohnya saat daftar percakapan
diganti: baris lama dihapus dan baris baru dimasukkan dalam satu transaksi,
sehingga kegagalan di tengah proses tidak akan mengosongkan cache. Pola yang
sama berlaku untuk kombinasi produk + seller, thread + pesan, dan tiket +
pesan.

**File: `lib/core/database/daos/ai_chat_dao.dart:115`**

```dart
/// @notice Replaces the conversation list atomically.
Future<void> replaceConversations({
  required List<AiConversationsCompanion> rows,
  required int fetchedAt,
}) {
  return transaction(() async {
    await delete(aiConversations).go();
    await batch((Batch batch) {
      batch.insertAll(aiConversations, rows);
    });
  });
}
```

Karena backend belum tersambung, isi cache awal dibuat oleh `AppSeeder` saat
start-up. Setiap repository punya guard "cache kosong?" sendiri
(`ensureSeeded()`), sehingga seed hanya berjalan sekali dan aman dipanggil
berulang. Data placeholder ditulis lewat transaksi yang sama seperti refresh
backend nanti, jadi mengganti seeder dengan hasil fetch API tidak akan
mengubah kode DAO maupun UI.

**File: `lib/data/shared/app_seeder.dart:45`**

```dart
Future<void> seedIfEmpty() async {
  await catalog.ensureSeeded();
  await inbox.ensureSeeded();
  await support.ensureSeeded();
  await aiChat.ensureSeeded();
}
```

## 2. Dua Jenis Penyimpanan

Data kecil non-sensitif seperti tema, mode akun (pembeli/penjual), dan
preferensi notifikasi disimpan dengan shared_preferences lewat pembungkus
`PreferencesStore`. Sedangkan rahasia — access token, refresh token, dan
metadata sesi — hanya boleh masuk ke keystore perangkat lewat `SecureStore`
yang membungkus flutter_secure_storage. Tidak ada token yang pernah menyentuh
preferences. Semua nama key dikumpulkan di satu kelas supaya tidak ada typo
antara penulis dan pembaca nilai.

**File: `lib/core/storage/keys/storage_keys.dart:10`**

```dart
abstract final class StorageKeys {
  static const String themeDark = 'settings.theme_dark';
  static const String accountMode = 'settings.account_mode';
  // ...
  static const String accessToken = 'auth.access_token';
  static const String refreshToken = 'auth.refresh_token';
  static const String authEmail = 'auth.email';
  static const String authDisplayName = 'auth.display_name';
  static const String authProvider = 'auth.provider';
  static const String authOnboarding = 'auth.onboarding_required';
}
```

`SecureStore` punya mode memori khusus tes. Di platform yang tidak punya
keystore (misalnya widget test), semua operasi gagal dengan aman: `read()`
mengembalikan `null` dan tulis menjadi no-op, sehingga layar tidak pernah
crash karena plugin tidak tersedia.

**File: `lib/core/storage/stores/secure_store.dart:32`**

```dart
Future<String?> read(String key) async {
  final Map<String, String>? memory = _memory;
  if (memory != null) {
    return memory[key];
  }
  try {
    return await _storage!.read(key: key);
  } on MissingPluginException {
    return null;
  } on PlatformException {
    return null;
  }
}
```

Password pengguna tidak pernah disimpan di device. Password hanya diminta
saat sign-in dan nanti diverifikasi oleh backend ketika endpoint auth
tersambung.

## 3. Sesi Login

Sesi direpresentasikan model `AuthSession` yang membawa email, display name,
provider (`google` atau `email`), pasangan token, dan flag
`onboardingRequired` (apakah data kampus masih perlu diisi). Flag inilah yang
membuat splash bisa membedakan user baru dari user yang sesinya sudah lengkap.

**File: `lib/models/auth/auth_session.dart:10`**

```dart
enum AuthProvider { google, email }

class AuthSession {
  const AuthSession({
    required this.email,
    required this.displayName,
    required this.provider,
    required this.accessToken,
    required this.refreshToken,
    this.onboardingRequired = false,
  });

  final String email;
  final String displayName;
  final AuthProvider provider;
  final String accessToken;
  final String refreshToken;
  final bool onboardingRequired;

  bool get isGoogle => provider == AuthProvider.google;

  AuthSession copyWith({bool? onboardingRequired}) { /* ... */ }
}
```

`SessionRepository` yang menulis dan membaca sesi ke `SecureStore`. Restore
hanya mengembalikan sesi jika kedua token ada — sesi setengah jadi tidak
pernah muncul di UI. Google sign-in saat ini adalah demo gateway dengan akun
kampus tetap; ketika `google_sign_in` dan endpoint backend siap, hanya isi
method ini yang berganti tanpa mengubah bentuk sesi atau routing. Logout
menghapus seluruh key `auth.*` dari keystore.

**File: `lib/data/account/session_repository.dart:37`**

```dart
Future<AuthSession?> restore() async {
  final String? access = await secure.read(StorageKeys.accessToken);
  final String? refresh = await secure.read(StorageKeys.refreshToken);
  if (access == null || access.isEmpty ||
      refresh == null || refresh.isEmpty) {
    return null;
  }
  return AuthSession(
    email: await secure.read(StorageKeys.authEmail) ?? '',
    displayName: await secure.read(StorageKeys.authDisplayName) ?? '',
    provider: _providerFrom(await secure.read(StorageKeys.authProvider)),
    accessToken: access,
    refreshToken: refresh,
    onboardingRequired:
        await secure.read(StorageKeys.authOnboarding) == '1',
  );
}
```

**File: `lib/data/account/session_repository.dart:62`**

```dart
Future<AuthSession> signInWithGoogle() {
  return _persist(
    AuthSession(
      email: googleDemoEmail,
      displayName: googleDemoName,
      provider: AuthProvider.google,
      accessToken: _issueToken('google'),
      refreshToken: _issueToken('google-refresh'),
      onboardingRequired: true,
    ),
  );
}

Future<void> signOut() async {
  await secure.delete(StorageKeys.accessToken);
  await secure.delete(StorageKeys.refreshToken);
  await secure.delete(StorageKeys.authEmail);
  await secure.delete(StorageKeys.authDisplayName);
  await secure.delete(StorageKeys.authProvider);
  await secure.delete(StorageKeys.authOnboarding);
}
```

Status login adalah state global lintas layar, jadi ia hidup di Riverpod.
`SessionNotifier` memegang sesi aktif dan menjadi satu-satunya sumber yang
dibaca semua layar; sign-in dan sign-out langsung memperbarui seluruh
aplikasi. `completeRegistration` menyimpan nama dan username ke profil cache
di Drift, lalu menutup flag onboarding pada sesi.

**File: `lib/providers/account/session_provider.dart:24`**

```dart
class SessionNotifier extends Notifier<AuthSession?> {
  SessionNotifier({this.initial});

  final AuthSession? initial;

  @override
  AuthSession? build() => initial; // sesi hasil restore saat start-up

  Future<void> signInWithGoogle() async {
    state = await ref.read(sessionRepositoryProvider).signInWithGoogle();
  }

  /// Menyimpan nama + username ke profil cache, lalu menutup flag onboarding.
  Future<void> completeRegistration({
    required String name,
    required String username,
  }) async {
    final UserProfile current = ref.read(profileProvider);
    await ref.read(accountRepositoryProvider)
        .saveProfile(current.copyWith(name: name, username: username));
    final AuthSession? session = state;
    if (session != null) {
      state = await ref.read(sessionRepositoryProvider).markOnboarded(session);
    }
  }

  Future<void> signOut() async {
    await ref.read(sessionRepositoryProvider).signOut();
    state = null;
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, AuthSession?>(
  SessionNotifier.new,
);
```

Agar layar pertama sudah tahu status login, sesi dipulihkan dari keystore
sebelum `runApp`, lalu disuntikkan lewat `overrideWith`. Setelah itu barulah
cache di-seed, sehingga tidak ada frame yang menampilkan empty state.

**File: `lib/main.dart:52`**

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SecureStore secureStore = SecureStore();
  final AuthSession? session =
      await SessionRepository(secure: secureStore).restore();

  final ProviderContainer container = ProviderContainer(
    overrides: [
      preferencesStoreProvider.overrideWithValue(
        await PreferencesStore.open(),
      ),
      secureStoreProvider.overrideWithValue(secureStore),
      appDatabaseProvider.overrideWithValue(
        AppDatabase(AppDatabase.openDefault()),
      ),
      sessionProvider.overrideWith(
        () => SessionNotifier(initial: session),
      ),
    ],
  );

  final AppSeeder seeder = container.read(appSeederProvider);
  await seeder.seedIfEmpty();

  runApp(
    UncontrolledProviderScope(container: container, child: const MyApp()),
  );
}
```

## 4. Alur Google Sign-up

Registrasi biasa punya delapan langkah: email, nama, username, password, kode
verifikasi, NIM, kampus, dan jurusan. Varian Google tidak menulis ulang
formnya — ia hanya memilih langkah yang relevan dari daftar yang sama, karena
email dari akun Google sudah terverifikasi dan password tidak dibutuhkan.
Langkah yang tersisa adalah nama, username, NIM, kampus, dan jurusan.

**File: `lib/screens/auth/register/register_email_screen.dart:80`**

```dart
/// @dev Google variant: name, username, NIM, university, and major only.
static final List<FormStep> googleSteps = [
  steps[1], // nama
  steps[2], // username
  steps[5], // NIM
  steps[6], // kampus
  steps[7], // jurusan
];
```

Tombol "Continue with Google" di halaman Register menyimpan sesi dulu, baru
membuka form ringkas lewat route `/register-google`. Flag `_busy` mencegah
double tap saat proses berjalan.

**File: `lib/screens/auth/register/register_screen.dart:72`**

```dart
Future<void> _continueWithGoogle() async {
  if (_busy) {
    return;
  }
  setState(() => _busy = true);
  await ref.read(sessionProvider.notifier).signInWithGoogle();
  if (!mounted) {
    return;
  }
  Navigator.of(context).pushReplacementNamed(
    RegisterEmailScreen.googleRouteName,
  );
}
```

Nama dari akun Google langsung ter-prefill lewat parameter `initialValues`
baru di `SteppedForm`, dan `onCompleted` sekarang menerima semua nilai sekaligus
dalam bentuk `List<String>` sehingga penyimpanan bisa dilakukan sekali jalan
di akhir.

**File: `lib/screens/auth/register/register_email_screen.dart:133`**

```dart
return SteppedForm(
  steps: googleFlow ? googleSteps : steps,
  initialValues: prefillName
      ? <int, String>{0: session.displayName}
      : const <int, String>{},
  onCompleted: (List<String> values) =>
      unawaited(_finish(context, ref, values)),
);
```

Saat langkah terakhir lolos validasi, `_finish` menulis profil ke cache Drift
lewat `completeRegistration` lalu melanjutkan ke `InterestScreen`. NIM,
kampus, dan jurusan tetap divalidasi di form, tetapi belum masuk cache karena
tabel `users` baru mendapat kolomnya saat integrasi fetch backend.

**File: `lib/screens/auth/register/register_email_screen.dart:96`**

```dart
Future<void> _finish(
  BuildContext context,
  WidgetRef ref,
  List<String> values,
) async {
  final SessionNotifier session = ref.read(sessionProvider.notifier);
  if (googleFlow) {
    await session.completeRegistration(
      name: values[0].trim(),
      username: values[1].trim(),
    );
  } else {
    await session.signInWithEmail(email: values[0].trim());
    await session.completeRegistration(
      name: values[1].trim(),
      username: values[2].trim(),
    );
  }
  if (!context.mounted) {
    return;
  }
  Navigator.of(context).pushReplacementNamed(InterestScreen.routeName);
}
```

Splash menjadi tempat keputusan routing: tanpa sesi diarahkan ke Register,
sesi yang masih butuh onboarding diarahkan ke form Google, dan sisanya ke
home shell.

**File: `lib/screens/auth/onboarding/splash_screen.dart:58`**

```dart
final AuthSession? session = ref.read(sessionProvider);
final String target = switch (session) {
  null => RegisterScreen.routeName,
  AuthSession(onboardingRequired: true) =>
    RegisterEmailScreen.googleRouteName,
  _ => KosplyMainLayout.routeName,
};
Navigator.of(context).pushReplacementNamed(target);
```

Logout memanggil `signOut()` yang menghapus token dari keystore, lalu kembali
ke splash supaya routing sadar-sesi di atas menentukan tujuan berikutnya.

**File: `lib/screens/settings/app/app_setting_screen.dart:172`**

```dart
onTap: () async {
  await ref.read(sessionProvider.notifier).signOut();
  if (!context.mounted) {
    return;
  }
  Navigator.of(context).pushNamedAndRemoveUntil(
    SplashScreen.routeName,
    (Route<dynamic> route) => false,
  );
},
```

## 5. Testing

Widget test memakai helper `pumpKosplyApp` yang menyemai database in-memory
dan membungkus layar dengan scope Riverpod yang sama seperti aplikasi asli,
sehingga layar membaca data Drift yang identik dengan kondisi pertama kali
aplikasi dibuka di device. Container bisa dikirim ulang lewat parameter
`container`, misalnya untuk lanjut dari kondisi setelah login.

**File: `test/helpers/kosply_test_app.dart:35`**

```dart
Future<ProviderContainer> pumpKosplyApp(
  WidgetTester tester,
  Widget home, {
  Map<String, WidgetBuilder>? routes,
  RouteFactory? onGenerateRoute,
  Widget Function(Widget home)? app,
  ProviderContainer? container, // reuse container, mis. setelah login
}) async {
  final ProviderContainer scope = container ?? await seededContainer();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: scope,
      child: app?.call(home) ??
          MaterialApp(
            home: home,
            routes: routes ?? const <String, WidgetBuilder>{},
            onGenerateRoute: onGenerateRoute,
          ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 20));
  await tester.pump(const Duration(milliseconds: 20));
  await tester.pump();
  return scope;
}
```

Ada dua jebakan yang sudah ditemukan saat menulis tes dan perlu diingat lagi.
Pertama, di plain test tanpa widget jangan menunggu `.future` dari
`StreamProvider`: tanpa listener aktif future-nya tidak pernah complete.
Pakai method one-shot dari repository/DAO seperti `threadsOnce()` atau
`profileOnce()`. Kedua, langkah terakhir `SteppedForm` tidak menjadwalkan
frame baru, jadi `pumpAndSettle` bisa berhenti sebelum rantai penyimpanan
selesai; tes auth memakai helper `_settle` dengan beberapa pump berdurasi
untuk menunggu. Verifikasi dilakukan dengan `flutter analyze` dan
`flutter test`; status terakhir keduanya bersih dengan 92 tes hijau.

## 6. Batasan yang Disengaja

Google sign-in masih berupa demo gateway dengan akun kampus tetap dan belum
memakai `google_sign_in` beserta client ID asli, tetapi bentuk sesi, token,
dan routing sudah final sehingga penggantian nanti hanya menyentuh
`SessionRepository`. NIM, kampus, dan jurusan juga divalidasi di form tapi
belum di-cache karena menunggu kolom baru di tabel `users` saat fetch backend
masuk. Password tidak pernah dipersist — hanya pasangan token yang disimpan
di keystore. Terakhir, target web tidak didukung karena Drift `NativeDatabase`
membutuhkan `dart:ffi`; aplikasi dijalankan di Android, iOS, atau desktop.
