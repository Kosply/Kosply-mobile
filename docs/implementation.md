# Implementasi Local Storage & Data Persistence (Tugas #9)

Dokumen ini menjelaskan cara kerja lapisan penyimpanan lokal Kosply Mobile:
cache offline-first berbasis Drift, penyimpanan pengaturan dengan
shared_preferences, penyimpanan rahasia dengan flutter_secure_storage, sampai
sesi login dan alur Google sign-up. Semua data yang tampil di UI berasal dari
cache lokal. UI berlangganan `Stream` Drift (`.watch()`), jadi begitu cache
berubah, layar otomatis re-render tanpa perlu menunggu koneksi ke backend.

Cache itu diisi dari [Kosply-backend](https://github.com/Kosply/Kosply-backend).
Aliran datanya satu arah dan tidak pernah dilangkahi: **API → Repository →
Drift (tabel, DAO) → Provider → Widget**. Widget tidak pernah menyentuh HTTP
maupun database secara langsung.

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
  int get schemaVersion => 2;
}
```

Skema sekarang di versi 2. Versi 2 menambahkan kolom
`conversations.unreadCount`, karena jumlah pesan belum dibaca kini dikirim
server di setiap baris inbox. Migrasinya hanya menambah kolom, jadi cache
milik pengguna versi 1 tidak hilang.

**File: `lib/core/database/app_database.dart:62`**

```dart
MigrationStrategy get migration => MigrationStrategy(
  onUpgrade: (Migrator m, int from, int to) async {
    if (from < 2) {
      await m.addColumn(conversations, conversations.unreadCount);
    }
  },
);
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

Isi cache berasal dari backend. Setiap repository punya method `refresh*`
yang memanggil API lewat `ApiClient`, memetakan JSON ke companion Drift, lalu
menulisnya lewat transaksi DAO di atas. Contohnya katalog:

**File: `lib/data/catalog/catalog_repository.dart:90`**

```dart
Future<void> refresh() async {
  final Map<String, dynamic> json = await api.get(
    '/api/products',
    query: <String, String>{'limit': '$pageSize'},
    auth: false,
  );
  final List<Map<String, dynamic>> items = json.objects('items');
  final int now = utcMillisNow();
  await dao.replaceCatalog(
    userRows: _sellerRows(items, now),
    productRows: <ProductsCompanion>[
      for (final Map<String, dynamic> item in items) _productRow(item, now),
    ],
    fetchedAt: now,
  );
}
```

`AppSync` menjalankan semua refresh itu di satu tempat. Data publik (katalog
dan FAQ) selalu ditarik; data pribadi (profil, favorit, inbox, tiket, riwayat
AI) hanya ditarik bila ada sesi. Setiap langkah menelan `ApiException`
sendiri-sendiri, jadi satu route yang gagal atau tidak ada jaringan sama
sekali hanya berarti cache terakhir tetap tampil.

**File: `lib/data/shared/app_sync.dart:57`**

```dart
Future<void> syncAll() async {
  await syncPublic();
  await syncAccount();
}
```

Selain sinkronisasi saat start-up dan setelah login, layar yang dibuka
menyegarkan datanya sendiri lewat provider `*SyncProvider` (misalnya
`catalogSyncProvider`, `productSyncProvider`, `inboxSyncProvider`).

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
  // ... settings.notification.*
  static const String accessToken = 'auth.access_token';
  static const String refreshToken = 'auth.refresh_token';
  static const String authEmail = 'auth.email';
  static const String authDisplayName = 'auth.display_name';
  static const String authProvider = 'auth.provider';
  static const String authOnboarding = 'auth.onboarding_required';
  static const String authUserId = 'auth.user_id';
  static const String authUsername = 'auth.username';
  static const String authRole = 'auth.role';
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

Password pengguna tidak pernah disimpan di device. Password dikirim sekali
ke `POST /api/auth/login` atau `/api/auth/register`, dan yang disimpan
hanyalah pasangan token yang dikembalikan server.

## 3. Sesi Login

Sesi direpresentasikan model `AuthSession` yang membawa email, display name,
provider (`google` atau `email`), pasangan token, dan flag
`onboardingRequired` (apakah data kampus masih perlu diisi). Sejak tersambung
ke backend, sesi juga membawa `userId` (`users.id` di server), `username`,
dan `role`. `userId` dipakai setiap pengecekan "ini milik saya?" — bubble
chat dan etalase penjual sendiri — sedangkan `role` menentukan boleh tidaknya
memasang barang.

**File: `lib/models/auth/auth_session.dart:25`**

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
    this.userId = '',
    this.username = '',
    this.role = 'BUYER',
  });

  bool get isGoogle => provider == AuthProvider.google;

  bool get canSell =>
      role == 'SELLER' || role == 'ADMIN' || role == 'SUPER_ADMIN';
}
```

`SessionRepository` memanggil route `/api/auth/*` dan menyimpan hasilnya ke
`SecureStore`. Restore hanya mengembalikan sesi jika kedua token ada — sesi
setengah jadi tidak pernah muncul di UI. Method-nya statis supaya `main` bisa
memulihkan sesi sebelum provider (dan `ApiClient`) ada.

**File: `lib/data/account/session_repository.dart:42`**

```dart
static Future<AuthSession?> restoreFrom(SecureStore secure) async {
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
    userId: await secure.read(StorageKeys.authUserId) ?? '',
    username: await secure.read(StorageKeys.authUsername) ?? '',
    role: await secure.read(StorageKeys.authRole) ?? 'BUYER',
  );
}
```

Google sign-in menukar id token dari `google_sign_in` dengan sesi Kosply.
Server memverifikasi token itu terhadap client id OAuth bertipe web, sehingga
aplikasi harus memintanya dengan id yang sama (`GOOGLE_SERVER_CLIENT_ID` di
`.env`).

**File: `lib/data/account/session_repository.dart:121`**

```dart
Future<AuthSession> signInWithGoogle(String idToken) async {
  final Map<String, dynamic> json = await api.post(
    '/api/auth/google',
    body: <String, String>{'idToken': idToken},
    auth: false,
  );
  return _persist(_sessionFrom(json, AuthProvider.google));
}
```

Status login adalah state global lintas layar, jadi ia hidup di Riverpod.
`SessionNotifier` memegang sesi aktif dan menjadi satu-satunya sumber yang
dibaca semua layar; sign-in dan sign-out langsung memperbarui seluruh
aplikasi. Pemilih akun Google berada di balik `googleIdTokenSourceProvider`
supaya widget test tidak pernah membuka dialog platform.

**File: `lib/providers/account/session_provider.dart:107`**

```dart
Future<AuthSession> signInWithGoogle() async {
  final String idToken = await ref
      .read(googleIdTokenSourceProvider)
      .idToken();
  final AuthSession session = await _repo.signInWithGoogle(idToken);
  _publish(session);
  return session;
}
```

Notifier yang sama memperbarui access token untuk `ApiClient`. Server
merotasi refresh token dan menganggap pemakaian kedua token lama sebagai
replay (seluruh sesi dicabut), jadi semua request yang kena 401 bersamaan
berbagi satu refresh. Refresh yang ditolak mengakhiri sesi; kegagalan
jaringan tidak, supaya HP yang offline tidak ter-logout.

**File: `lib/providers/account/session_provider.dart:206`**

```dart
Future<bool> refreshTokens() {
  return _refreshing ??= _refresh().whenComplete(() => _refreshing = null);
}

Future<bool> _refresh() async {
  final AuthSession? session = state;
  if (session == null) {
    return false;
  }
  try {
    state = await _repo.refresh(session);
    return true;
  } on ApiException catch (error) {
    if (error.isNetwork) {
      return false;
    }
    await _repo.clear();
    state = null;
    return false;
  }
}
```

`ApiClient` memakai refresh itu tepat sekali per request: 401 pertama memicu
refresh lalu request diulang, dan 401 kedua diteruskan ke pemanggil sebagai
`ApiException`.

Agar layar pertama sudah tahu status login, konfigurasi `.env` dimuat dan
sesi dipulihkan dari keystore sebelum `runApp`, lalu sesi disuntikkan lewat
`overrideWith`. Sinkronisasi ke backend berjalan setelah frame pertama dan
tidak ditunggu, jadi aplikasi langsung tampil dengan cache terakhir.

**File: `lib/main.dart:59`**

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.load();
  final SecureStore secureStore = SecureStore();
  final AuthSession? session = await SessionRepository.restoreFrom(
    secureStore,
  );
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
  runApp(
    UncontrolledProviderScope(container: container, child: const MyApp()),
  );
  unawaited(container.read(appSyncProvider).syncAll());
}
```

## 4. Alur Google Sign-up

Registrasi biasa punya delapan langkah: email, nama, username, password, kode
verifikasi, NIM, kampus, dan jurusan. Varian Google tidak menulis ulang
formnya — ia hanya memilih langkah yang relevan dari daftar yang sama, karena
email dari akun Google sudah terverifikasi dan password tidak dibutuhkan.
Langkah yang tersisa adalah nama, username, NIM, kampus, dan jurusan.

**File: `lib/screens/auth/register/register_email_screen.dart:92`**

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

Tombol "Continue with Google" di halaman Register masuk dulu lewat server.
Akun baru (`onboardingRequired`) dibawa ke form ringkas di route
`/register-google`; akun yang sudah lengkap langsung ke beranda. Pembatalan
di pemilih akun (`GOOGLE_CANCELED`) diam saja, sedangkan error lain tampil
sebagai snackbar. Flag `_busy` mencegah double tap.

**File: `lib/screens/auth/register/register_screen.dart:78`**

```dart
Future<void> _continueWithGoogle() async {
  if (_busy) {
    return;
  }
  setState(() => _busy = true);
  final AuthSession session;
  try {
    session = await ref.read(sessionProvider.notifier).signInWithGoogle();
    await ref.read(appSyncProvider).syncAccount();
  } on ApiException catch (error) {
    // GOOGLE_CANCELED diam; error lain -> snackbar error.userMessage
    return;
  }
  if (!mounted) {
    return;
  }
  if (session.onboardingRequired) {
    Navigator.of(context).pushReplacementNamed(
      RegisterEmailScreen.googleRouteName,
    );
    return;
  }
  Navigator.of(context).pushNamedAndRemoveUntil(
    KosplyMainLayout.routeName,
    (Route<dynamic> route) => false,
  );
}
```

`SteppedForm` memanggil hook `onStepSubmit` di setiap langkah, sehingga
server bisa menolak sebuah langkah dan form kembali ke langkah yang salah.
Alur email meminta kode verifikasi setelah langkah password, mengeceknya di
langkah kode, lalu membuat akun di langkah terakhir. Alur Google hanya
mengirim data kampus lewat `PATCH /api/users/me` di langkah terakhir. Penolakan
`EMAIL_TAKEN`, `USERNAME_TAKEN`, dan `EMAIL_CODE_INVALID` mengembalikan
pengguna ke langkah yang bersangkutan.

**File: `lib/screens/auth/register/register_email_screen.dart:112`**

```dart
Future<StepFeedback?> _submit(
  WidgetRef ref,
  int step,
  List<String> values,
) async {
  final int last = (googleFlow ? googleSteps : steps).length - 1;
  final SessionNotifier session = ref.read(sessionProvider.notifier);
  final int usernameStep = googleFlow ? 1 : 2;
  final String email = values[emailStep].trim();
  try {
    if (!googleFlow && step == passwordStep) {
      await session.requestEmailCode(email);
    } else if (!googleFlow && step == codeStep) {
      await session.verifyEmailCode(email: email, code: values[codeStep]);
    } else if (step == last) {
      if (googleFlow) {
        await session.completeRegistration(
          name: values[0].trim(),
          username: values[1].trim(),
          universitas: values[3].trim(),
          programStudi: values[4].trim(),
        );
      } else {
        await session.register(/* email, nama, username, password, kampus, jurusan, kode */);
      }
      await ref.read(appSyncProvider).syncAccount();
    }
  } on ApiException catch (error) {
    switch (error.code) {
      case 'EMAIL_TAKEN':
        return StepFeedback(error.userMessage, step: emailStep);
      case 'USERNAME_TAKEN':
        return StepFeedback(error.userMessage, step: usernameStep);
      case 'EMAIL_CODE_INVALID':
        return StepFeedback(error.userMessage, step: codeStep);
      default:
        return StepFeedback(error.userMessage);
    }
  }
  return null;
}
```

NIM tetap divalidasi di form tetapi tidak dikirim saat registrasi: NIM dan
foto KTM masuk lewat pengajuan verifikasi penjual (`/api/verifications`).

Splash menjadi tempat keputusan routing: tanpa sesi diarahkan ke Register,
sesi yang masih butuh onboarding diarahkan ke form Google, dan sisanya ke
home shell.

**File: `lib/screens/auth/onboarding/splash_screen.dart:59`**

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

Logout memanggil `signOut()`, lalu kembali ke splash supaya routing
sadar-sesi di atas menentukan tujuan berikutnya.

**File: `lib/screens/settings/app/app_setting_screen.dart:213`**

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

`signOut()` mencabut refresh token di server (best effort, supaya logout
tetap jalan saat offline), menghapus seluruh key `auth.*` dari keystore, lalu
membersihkan data akun dari cache. Katalog publik dibiarkan, jadi pengguna
berikutnya di HP yang sama tidak melihat chat, tiket, favorit, atau riwayat AI
milik akun sebelumnya.

**File: `lib/providers/account/session_provider.dart:232`**

```dart
Future<void> signOut() async {
  final AuthSession? session = state;
  await _repo.signOut(session);
  state = null;
  await ref.read(appDatabaseProvider).clearAccountData();
}
```

## 5. Testing

Widget test tidak menyentuh jaringan. `FakeKosplyBackend`
(`test/helpers/fake_backend.dart`) adalah pengganti server di memori yang
dilayani lewat `MockClient` milik `package:http`. Ia menjawab dengan envelope
dan bentuk respons yang sama seperti server, diisi dari fixture di
`test/helpers/fixtures/`. Karena yang diganti hanya transport HTTP, setiap
repository menjalankan kode HTTP, pemetaan, dan cache yang sebenarnya.

Helper `seededContainer` membuat scope Riverpod yang diarahkan ke backend
palsu itu, login sebagai mahasiswa fixture, lalu menjalankan sinkronisasi
yang sama dengan aplikasi asli. `pumpKosplyApp` membungkus layar dengan scope
tersebut. Parameter `signedIn: false` dipakai untuk layar sebelum login, dan
`backend` untuk tes yang perlu memeriksa request atau mengatur respons.

**File: `test/helpers/kosply_test_app.dart:35`**

```dart
Future<ProviderContainer> seededContainer({
  List<Override> overrides = const <Override>[],
  bool signedIn = true,
  FakeKosplyBackend? backend,
}) async {
  final FakeKosplyBackend api = backend ?? FakeKosplyBackend();
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      httpClientProvider.overrideWithValue(api.client),
      apiBaseUrlProvider.overrideWithValue(FakeKosplyBackend.origin),
      googleIdTokenSourceProvider.overrideWithValue(_FixedGoogleIdToken()),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  if (signedIn) {
    await container
        .read(sessionProvider.notifier)
        .signInWithEmail(email: 'me@kampus.ac.id', password: 'password');
  }
  await container.read(appSyncProvider).syncAll();
  return container;
}
```

`test/real_api_smoke_test.dart` menjalankan repository yang sama terhadap
server sungguhan. Tes itu dilewati kecuali dijalankan dengan
`--dart-define=KOSPLY_REAL_API=http://127.0.0.1:3500`, sehingga
`flutter test` biasa tetap offline.

Ada dua jebakan yang sudah ditemukan saat menulis tes dan perlu diingat lagi.
Pertama, di plain test tanpa widget jangan menunggu `.future` dari
`StreamProvider`: tanpa listener aktif future-nya tidak pernah complete.
Pakai method one-shot dari repository/DAO seperti `threadsOnce()` atau
`profileOnce()`. Kedua, langkah terakhir `SteppedForm` tidak menjadwalkan
frame baru, jadi `pumpAndSettle` bisa berhenti sebelum rantai penyimpanan
selesai; tes auth memakai helper `_settle` dengan beberapa pump berdurasi
untuk menunggu. Verifikasi dilakukan dengan `flutter analyze` dan
`flutter test`; status terakhir keduanya bersih dengan 114 tes hijau dan 1
dilewati (smoke test API sungguhan).

## 6. Batasan yang Disengaja

Google sign-in butuh client id OAuth sendiri: tanpa `GOOGLE_SERVER_CLIENT_ID`
tombolnya hanya menjelaskan bahwa login Google belum dikonfigurasi, dan login
email tetap berjalan. Akun baru berstatus pembeli; memasang barang ditolak
server (`SELLER_NOT_APPROVED`) sampai pengajuan verifikasinya disetujui
admin. Password tidak pernah dipersist — hanya pasangan token yang disimpan
di keystore. Koneksi `http://` hanya diizinkan di build debug, jadi build
release harus menunjuk ke server `https://`. Terakhir, target web tidak
didukung karena Drift `NativeDatabase` membutuhkan `dart:ffi`; aplikasi
dijalankan di Android, iOS, atau desktop.
