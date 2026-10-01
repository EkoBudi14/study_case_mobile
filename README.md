# BLE Proximity Tracker

Aplikasi mobile (Flutter) pelacak kedekatan perangkat Bluetooth Low Energy (BLE).
Aplikasi memindai sinyal *advertising* perangkat di sekitar secara real-time,
menampilkan daftar perangkat aktif beserta kekuatan sinyal (RSSI), dan
memungkinkan pengguna memilih satu perangkat target untuk dilacak kedekatannya
lewat indikator visual berbasis zona jarak.

## Fitur

- **Pemindaian real-time** perangkat BLE: nama, ID unik (MAC/UUID), RSSI mentah
  (dBm), dan estimasi jarak.
- **Kontrol manual** Start / Stop pemindaian.
- **Pengurutan otomatis** berdasarkan sinyal terkuat (RSSI tertinggi).
- **Filter**: pencarian berdasarkan nama / MAC address, dan ambang batas sinyal
  minimum (mis. hanya tampilkan ≥ -80 dBm).
- **Radar View**: visualisasi kedekatan dinamis + indikator warna per kategori
  sinyal + detail koneksi (status terhubung / putus).
- **Riwayat perangkat**: tersimpan ke database lokal (SQLite), tidak hilang saat
  aplikasi ditutup.
- **Error handling**: menangani Bluetooth mati, izin ditolak, dan sinyal putus.
- **Lifecycle-aware**: pemindaian berhenti saat aplikasi ke background dan lanjut
  kembali saat dibuka lagi.

## Cara Menjalankan

Prasyarat: Flutter SDK (3.41+) terpasang, dan perangkat Android fisik (BLE tidak
berfungsi di emulator).

```bash
flutter pub get
flutter run            # menjalankan di perangkat yang terhubung
```

Menjalankan test unit:

```bash
flutter test
```

Build APK:

```bash
flutter build apk --release
# hasil: build/app/outputs/flutter-apk/app-release.apk
```

APK siap-uji juga disertakan pada pengumpulan (`app-release.apk`).

## Arsitektur

Pola **Clean Architecture + BLoC** dengan pemisahan 3 layer yang jelas:

```
lib/
├── common/                     # Helper & util lintas layer
│   ├── failure.dart            # tipe Failure (sisi kiri Either)
│   ├── helperText.dart         # konstanta string
│   └── rssi_helper.dart        # RSSI -> kategori, jarak, warna
├── data/                       # Layer DATA (implementasi)
│   ├── sources/
│   │   ├── db/
│   │   │   └── database_helper_device.dart   # SQLite (sqflite)
│   │   └── model/
│   │       └── bleDeviceModel.dart           # model data
│   └── repositories/
│       ├── bleRepositoryImpl.dart
│       └── deviceHistoryRepositoryImpl.dart
├── domain/                     # Layer DOMAIN (aturan bisnis, murni)
│   ├── repositories/           # Kontrak (abstract class)
│   │   ├── bleRepository.dart
│   │   └── deviceHistoryRepository.dart
│   └── usecase/                # 1 file per aksi (startScan, getHistory, ...)
├── presentation/               # Layer PRESENTATION (UI + BLoC)
│   ├── components/             # Widget dipakai ulang (device_tile, radar_view)
│   └── pages/
│       ├── scannerScreen/      # Screen 1: Dashboard scanner
│       │   ├── blocScanner/    # scanner_bloc + event + state
│       │   └── scannerPage.dart
│       ├── trackerScreen/      # Screen 2: Radar view
│       │   ├── blocTracker/
│       │   └── trackerPage.dart
│       └── historyScreen/      # Screen 3: Riwayat
│           ├── blocHistory/
│           └── historyPage.dart
├── services/                   # Pembungkus integrasi eksternal
│   └── ble_service.dart        # pembungkus flutter_blue_plus + izin
├── injection.dart              # Service locator (get_it) -> di.locator<T>()
└── main.dart                   # init DI + MultiBlocProvider + lifecycle
```

**Alur data (searah):** `Page` kirim `Event` ke `Bloc`. `Bloc` panggil
`UseCase` (`.execute()`). `UseCase` panggil `Repository` (kontrak di domain,
implementasi di data). `Repository` bicara ke `Service` (plugin BLE) atau
`database_helper` (SQLite). Hasil kembali sebagai `State` yang di-*render* `Page`.
UI tidak pernah menyentuh plugin langsung.

**Error handling fungsional — `dartz Either<Failure, T>`:** aksi one-shot
(startScan, getHistory, dll) mengembalikan `Either<Failure, T>`. Repository
menangkap error dan mengembalikan `Left(Failure)` (`ServerFailure`,
`DatabaseFailure`, `PermissionFailure`, `BluetoothOffFailure`); Bloc memproses
dengan `res.fold((failure) => ..., (success) => ...)`. Data streaming (hasil scan,
status Bluetooth) tetap berupa `Stream` karena tidak cocok dibungkus `Either`.

**State management — BLoC (event + state):** tiap layar punya `Bloc` dengan
`Event` dan `State`. State memakai **subclass + `Equatable`** (mis.
`HistoryInitial` / `HistoryLoading` / `HistoryLoaded` / `HistoryError`;
`TrackerConnected` / `TrackerLost`). Page memakai `BlocBuilder` / `BlocProvider`.

**Dependency Injection — `get_it`:** semua service, repository, usecase, dan bloc
didaftarkan di `injection.dart` (`init()` → `initRepository()` → `initUseCase()`
→ `initBloc()`) dan diakses lewat `di.locator<T>()`. `ScannerBloc` di-provide
global di `main.dart`; `TrackerBloc` & `HistoryBloc` dibuat per layar (factory).

## Library yang Digunakan & Alasannya

| Library | Fungsi | Alasan |
|---|---|---|
| `flutter_blue_plus` | Pemindaian BLE | Paket BLE paling umum & aktif dirawat untuk Flutter. |
| `flutter_bloc` + `bloc` | State management | Pola BLoC (event + state) yang teruji, pemisahan UI & logika jelas. |
| `equatable` | Perbandingan state | State & event mudah dibandingkan tanpa boilerplate. |
| `dartz` | Functional error handling | `Either<Failure, T>` agar jalur sukses & gagal eksplisit. |
| `get_it` | Dependency Injection | Service locator standar untuk wiring Clean Architecture. |
| `sqflite` + `path` | Database lokal | Pembungkus SQLite standar — setara Room (Android) / CoreData (iOS). |
| `permission_handler` | Izin runtime | Menangani izin Bluetooth & lokasi lintas versi Android. |
| `intl` | Format tanggal/waktu | Menampilkan "terakhir terlihat" dengan format rapi. |

Pilihan teknologi memakai pola yang umum dan mudah dipahami (Clean Architecture +
BLoC + get_it), bukan pendekatan eksotis, agar kode gampang dibaca dan dirawat.

## Logika Estimasi Jarak

Kategori sinyal mengikuti tabel pada soal (perbandingan ambang batas sederhana).
Estimasi jarak numerik memakai rumus **log-distance path loss** yang umum dipakai:

```
jarak = 10 ^ ((txPower - rssi) / (10 * n))
```

dengan `txPower = -59 dBm` (RSSI pada jarak 1 meter) dan `n = 2.0` (faktor
lingkungan). Lihat `lib/common/rssi_helper.dart`.

## Izin (Permissions)

- **Android 12+**: `BLUETOOTH_SCAN`, `BLUETOOTH_CONNECT`.
- **Android 11 ke bawah**: `BLUETOOTH`, `BLUETOOTH_ADMIN`, `ACCESS_FINE_LOCATION`
  (lokasi wajib untuk memindai BLE di versi lama).
- **iOS**: `NSBluetoothAlwaysUsageDescription`.

## Known Issues & Asumsi

- **BLE butuh perangkat fisik** — tidak berjalan di emulator/simulator.
- **Estimasi jarak bersifat perkiraan.** RSSI dipengaruhi penghalang, orientasi
  antena, dan pantulan sinyal, jadi angka jarak adalah estimasi kasar, bukan
  pengukuran presisi. Konstanta `txPower`/`n` memakai nilai umum, bukan hasil
  kalibrasi per perangkat.
- **Scanning di background dihentikan** saat aplikasi tidak aktif, lalu
  dilanjutkan saat kembali ke foreground. Ini pilihan yang aman (Android membatasi
  pemindaian BLE di background tanpa foreground service).
- **Perubahan konfigurasi (rotasi layar):** state scanning aman karena disimpan di
  `Bloc` (di-provide di atas widget tree), tidak ikut dibuang saat widget di-rebuild.
- **Riwayat** disimpan dengan ID perangkat sebagai primary key, sehingga perangkat
  yang sama tidak terduplikasi — data lama diperbarui (nama, RSSI terakhir, waktu).
  Penulisan ke database dibatasi (throttle) maksimum sekali per 3 detik per
  perangkat agar tidak membanjiri DB saat pemindaian berlangsung.

## Penggunaan AI (Disclosure)

Dalam pengerjaan proyek ini saya menggunakan bantuan AI generatif (Claude) pada
bagian logika tertentu, yaitu:

- **Resolusi nama perangkat dari manufacturer data** di
  `lib/data/repositories/bleRepositoryImpl.dart`:
  - `_manufacturerName` — pemetaan *company id* Bluetooth SIG ke nama vendor.
  - `_resolveName` — penentuan nama perangkat (platform name / advertisement /
    tebakan vendor / fallback ID).
- **Logika estimasi jarak & sinyal dari RSSI** di `lib/common/rssi_helper.dart`:
  - `estimateMeters` — rumus *log-distance path loss*.
  - `proximity` — normalisasi RSSI ke rentang 0–1 untuk posisi titik radar.
  - `metersText` — format tampilan jarak.
- **Visualisasi radar** di `lib/presentation/components/radar_view.dart`:
  - `_RadarPainter` — penggambaran lingkaran radar, posisi titik, dan animasi.

AI dipakai untuk mempercepat penyusunan dan menjelaskan konsep di balik bagian
tersebut (mis. asal nilai *company id*, konversi heksadesimal, serta nilai acuan
`txPower`/`n`). Keputusan arsitektur, struktur kode, dan hasil akhir telah saya
tinjau dan pahami sepenuhnya.
