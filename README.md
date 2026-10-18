# Kosply Mobile

Aplikasi marketplace barang bekas antar mahasiswa (Flutter). Proyek PBL UAS
dengan arsitektur **offline-first**: semua data yang ditampilkan berasal dari
cache lokal (Drift), sehingga UI tetap jalan tanpa koneksi dan otomatis
ter-update begitu cache berubah.

- **Desain Figma:** [Kosply mobile design](https://www.figma.com/design/TkunWRuVgaA6JapwO536j0/Kosply-mobile-design?node-id=0-1&t=zjJLtvytCla93880-1)
- **Tugas:** #9 Mobile Developer — Local Storage & Data Persistence

## Fitur

- **Offline-first cache (Drift)** — produk, seller, favorit, inbox, chat AI,
  support, dan profil dibaca lewat `Stream` reaktif (`.watch()`), jadi UI
  otomatis re-render saat database berubah.
- **Penanda cache** — setiap tabel inti punya `updated_at` dan `last_fetched`
  (UTC millis) untuk melacak kapan data terakhir disegarkan dari server.
- **Transaksi atomik** — semua penulisan multi-baris (produk + seller, thread
  + pesan, tiket + pesan) dibungkus `transaction()` Drift.
- **Pengaturan** — tema, mode akun (pembeli/penjual), dan preferensi
  notifikasi disimpan dengan `shared_preferences` (data kecil, non-sensitif).
- **Keamanan rahasia** — access token & refresh token hanya disimpan di
  `flutter_secure_storage` (`SecureStore`), tidak pernah di shared preferences.
- **Login Google di onboarding** — memakai akun Google, langkah email,
  password, dan verifikasi dilewati; user langsung melengkapi nama, username,
  NIM, kampus, dan jurusan.
- **Global state login** — `sessionProvider` dipakai lintas layar: splash
  mengarahkan ke home bila sudah login, halaman Profil menampilkan email yang
  masuk, dan Log out menghapus token dari keystore lalu kembali ke splash.

## Screenshot

> Tambahkan hasil slicing ke `docs/screenshots/` lalu tautkan di sini, contoh:
>
> ```md
> ![Home](docs/screenshots/home.png)
> ```

## Struktur

```
lib/
  core/
    database/        # Drift: tabel, DAO, provider, AppDatabase
    storage/         # PreferencesStore, SecureStore, StorageKeys
    ui_bridge/       # Kontrak ui_state untuk agen AI (id, callback, snapshot)
  models/            # Model domain (product, seller, chat, form, auth, ...)
  data/              # Repository + placeholder builder + seeder
  providers/         # State management Riverpod (catalog, account, chat, ...)
  screens/           # UI per layar (auth, main, seller, settings, support)
  widgets/           # Widget bersama (form, kartu produk, settings, dll.)
```

## Peta Requirement Tugas #9

| Requirement | Implementasi |
| --- | --- |
| Database lokal type-safe & reaktif | `lib/core/database/` (Drift) + `.watch()` di semua DAO |
| Cache data dari backend | Repository + seeder menulis ke Drift; UI selalu membaca dari cache |
| Penanda `last_fetched` / `updated_at` | `CacheMarker` mixin di `lib/core/database/tables/cache_marker.dart` |
| Stream reaktif | `StreamProvider`/`Notifier` di `lib/providers/` |
| Transaksi atomik | `transaction()` di `catalog_dao`, `inbox_dao`, `ai_chat_dao`, `support_dao`, `account_dao` |
| `shared_preferences` untuk setting | `PreferencesStore` (tema, mode akun, notifikasi) |
| `flutter_secure_storage` untuk token | `SecureStore` + `SessionRepository` (access & refresh token) |
| Fitur global state lintas layar | `sessionProvider` (login/logout) & `favoritesProvider` (favorit) |

## Catatan

- **Google Sign-In** saat ini lewat *demo gateway* (`SessionRepository`):
  mengembalikan akun kampus contoh dan menyimpan token asli ke keystore.
  Ganti isi `signInWithGoogle()` dengan `google_sign_in` + endpoint backend
  saat API siap — kontrak sesi dan skip-step onboarding tidak perlu berubah.
- Data produk/inbox/chat saat ini adalah seed lokal yang mensimulasikan
  respons backend; ketika fetch API nyata masuk, hasilnya tinggal ditulis
  lewat repository yang sama.

## Menjalankan

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d <device>       # Android: bisa via wireless debugging (adb pair/connect)
```
