# Kosply Mobile

Aplikasi marketplace barang bekas antar mahasiswa (Flutter). Aplikasi ini
tersambung ke [Kosply-backend](https://github.com/Kosply/Kosply-backend) dan
tetap **offline-first**: semua layar membaca cache lokal (Drift), sedangkan
repository menyegarkan cache itu dari API. Tanpa koneksi, data terakhir tetap
tampil.

- **Desain Figma:** [Kosply mobile design](https://www.figma.com/design/TkunWRuVgaA6JapwO536j0/Kosply-mobile-design?node-id=0-1&t=zjJLtvytCla93880-1)
- **Backend:** [Kosply/Kosply-backend](https://github.com/Kosply/Kosply-backend) (Express + MariaDB + agen AI)
- **Penjelasan implementasi:** [docs/implementation.md](docs/implementation.md)

## Fitur

- **Akun** — daftar dengan email (kode verifikasi lewat email), login, lupa
  password, dan login Google. Akun Google baru melengkapi nama, username,
  kampus, dan jurusan lewat form ringkas.
- **Katalog** — beranda, pencarian, detail barang, profil penjual, dan
  favorit, semuanya dari `GET /api/products`, `/api/users/:id`, dan
  `/api/favorites`.
- **Jual barang dengan AI** — tombol "+" membuka kamera, penjual memotret
  lima foto (tanpa galeri), foto diunggah ke `/api/uploads/images`, lalu agen
  AI mengisi nama, kategori, dan deskripsi. Ketiga isian itu dikunci; penjual
  hanya mengisi harga, kuantitas, dan lokasi.
- **Chat COD** — inbox dan ruang chat pembeli–penjual lewat
  `/api/conversations`.
- **Asisten AI** — overlay chat di beranda dengan riwayat percakapan
  (`/api/ai/*`).
- **Analitik penjual** — views, favorit, chat, dan terjual dari
  `/api/analytics/seller`.
- **Verifikasi penjual** — unggah foto KTM lewat `/api/verifications`; akun
  baru berstatus pembeli sampai disetujui admin.
- **Bantuan** — FAQ, tiket support dengan balasan, dan laporan
  (`/api/support/*`, `/api/reports`).
- **Notifikasi** — kotak masuk dan preferensi notifikasi
  (`/api/notifications`).
- **Sesi aman** — access token dan refresh token hanya di
  `flutter_secure_storage`. Token yang kedaluwarsa diperbarui otomatis sekali,
  lalu request diulang.

## Menjalankan

### 1. Siapkan backend

Ikuti [Getting started di Kosply-backend](https://github.com/Kosply/Kosply-backend#getting-started),
lalu jalankan stack lokalnya:

```bash
./scripts/dev.sh setup    # sekali: dependensi + migrasi
./scripts/dev.sh start    # server di :3500, agen AI di :8000
```

### 2. Buat `.env`

```bash
cp .env.example .env
```

Isi dua nilai di dalamnya. Petunjuk lengkap dan tautan setup ada di
[`.env.example`](.env.example).

| Variabel | Isi |
| --- | --- |
| `KOSPLY_API_URL` | Alamat server. Emulator: `http://10.0.2.2:3500`. HP lewat `adb reverse`: `http://127.0.0.1:3500`. HP di LAN yang sama: `http://<ip-komputer>:3500`. |
| `GOOGLE_SERVER_CLIENT_ID` | Client id OAuth bertipe *Web application* dari [Google Cloud Console](https://console.cloud.google.com/apis/credentials). Boleh kosong; login email tetap jalan. |

`.env` dibaca sekali saat aplikasi mulai, jadi perubahan butuh restart penuh.
`--dart-define` dengan nama yang sama selalu menang atas `.env`.

### 3. Jalankan

```bash
flutter pub get
flutter run -d <device>
```

Untuk HP Android lewat wireless debugging:

```bash
adb pair <ip>:<port-pairing> <kode>     # sekali per HP
adb connect <ip>:<port>
adb reverse tcp:3500 tcp:3500           # ulangi tiap adb connect
flutter run -d <ip>:<port>
```

Dengan `adb reverse`, `KOSPLY_API_URL=http://127.0.0.1:3500` tetap berlaku
walau Wi-Fi atau hotspot berganti.

Catatan:

- Build Android membutuhkan **JDK 21**. JDK yang lebih baru gagal di langkah
  `jlink` milik Android Gradle Plugin; arahkan `JAVA_HOME` ke JDK 21.
- `http://` hanya diizinkan di build debug. Build release harus memakai
  `https://`.
- Target web tidak didukung karena Drift `NativeDatabase` butuh `dart:ffi`.

## Mencoba jual barang

Akun yang baru daftar berstatus `BUYER`, dan `POST /api/products` menolaknya
dengan `SELLER_NOT_APPROVED`. Ajukan verifikasi dari Pengaturan → Verifikasi
kampus, lalu setujui pengajuannya dari dashboard admin backend. Agen AI juga harus
berjalan (`dev.sh start` menyalakannya) agar form terisi.

## Testing

```bash
flutter analyze
flutter test
```

Widget test tidak menyentuh jaringan. `test/helpers/fake_backend.dart`
(`FakeKosplyBackend`) meniru envelope dan bentuk respons server, sehingga
repository menjalankan kode HTTP, pemetaan, dan cache yang sebenarnya.

Untuk menguji repository terhadap server sungguhan:

```bash
flutter test test/real_api_smoke_test.dart \
  --dart-define=KOSPLY_REAL_API=http://127.0.0.1:3500
```

Tanpa `KOSPLY_REAL_API`, tes itu dilewati.

## Struktur

```
lib/
  core/
    auth/            # Sumber id token Google
    camera/          # Kamera foto barang dan KTM
    database/        # Drift: tabel, DAO, AppDatabase
    network/         # ApiClient, ApiConfig (.env), ApiException, SSE
    storage/         # PreferencesStore, SecureStore, StorageKeys
    ui_bridge/       # Kontrak ui_state untuk agen AI
  data/              # Repository per fitur + AppSync (API -> cache)
  models/            # Model domain
  providers/         # State Riverpod
  screens/           # Layar: auth, main, seller, settings, support, reports
  widgets/           # Widget bersama
test/
  helpers/           # FakeKosplyBackend, fixture, pumpKosplyApp
```

Alur data satu arah: **API → Repository → Drift → Provider → Widget**. Widget
tidak pernah memanggil HTTP atau database secara langsung.

## Peta Requirement Tugas #9

| Requirement | Implementasi |
| --- | --- |
| Database lokal type-safe & reaktif | `lib/core/database/` (Drift) + `.watch()` di semua DAO |
| Cache data dari backend | Repository di `lib/data/` menulis respons API ke Drift; UI selalu membaca cache |
| Penanda `last_fetched` / `updated_at` | Mixin `CacheMarker` di `lib/core/database/tables/cache_marker.dart` |
| Stream reaktif | `StreamProvider`/`Notifier` di `lib/providers/` |
| Transaksi atomik | `transaction()` di `catalog_dao`, `inbox_dao`, `ai_chat_dao`, `support_dao`, `account_dao` |
| `shared_preferences` untuk setting | `PreferencesStore` (tema, mode akun, notifikasi) |
| `flutter_secure_storage` untuk token | `SecureStore` + `SessionRepository` (access & refresh token) |
| Fitur global state lintas layar | `sessionProvider` (login/logout) & `favoritesProvider` (favorit) |

## Screenshot

> Tambahkan hasil slicing ke `docs/screenshots/` lalu tautkan di sini, contoh:
>
> ```md
> ![Home](docs/screenshots/home.png)
> ```
