# Mealora — aplikasi mobile

Teman gizi harianmu. **Lokal, offline, tanpa akun.**

MVP 1 berjalan sepenuhnya di perangkat: tidak ada backend, tidak ada
autentikasi, tidak ada SDK analitik/iklan/pelacak. Target rilis **Android**;
**web (Chrome)** dipakai sebagai lingkungan debug/pratinjau antarmuka.

Rancangan visual dan seluruh layar ada di `../../mealora-plans/docs/mealora.pen`.
Kebutuhan produk ada di `../../mealora-plans/openspec/`.

---

## Menjalankan

```bash
flutter pub get
```

```bash
dart run build_runner build
```

Pratinjau antarmuka di browser (hot reload, DevTools):

```bash
flutter run -d chrome
```

Untuk melihat pratinjau di browser lain atau di panel editor, jalankan sebagai
server lalu buka alamatnya sendiri:

```bash
flutter run -d web-server --web-port 5173 --web-hostname 127.0.0.1
```

Di Android (target rilis):

```bash
flutter run -d <id-perangkat>
```

Ukuran acuan desain adalah **390 × 844**. Saat memeriksa di browser, setel
viewport ke ukuran itu sebelum membandingkan dengan `mealora.pen`.

### Emulator Android

Daftar emulator yang tersedia:

```bash
flutter emulators
```

Menyalakan emulator yang dipakai untuk verifikasi change 001
(Android 16, API 36, x86_64):

```bash
flutter emulators --launch Medium_Phone_API_36.1
```

Memastikan emulator sudah siap sebelum memasang aplikasi:

```bash
flutter devices
```

Menjalankan aplikasi di emulator itu:

```bash
flutter run -d emulator-5554 --debug
```

Menutup emulator:

```bash
adb emu kill
```

`adb` tidak otomatis ada di PATH. Berkasnya ada di
`%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe`; tambahkan folder itu ke
PATH, atau panggil dengan path lengkap.

### Memeriksa keadaan di perangkat

Melihat aplikasi yang terpasang:

```bash
adb shell pm list packages | findstr mealora
```

Memastikan basis data lokal benar-benar terbentuk (butuh build debug):

```bash
adb shell run-as com.supernova.mealora ls -l /data/data/com.supernova.mealora/app_flutter/
```

Mengambil tangkapan layar perangkat ke berkas:

```bash
adb exec-out screencap -p > layar.png
```

Menguji perilaku offline — nyalakan lalu matikan mode pesawat:

```bash
adb shell cmd connectivity airplane-mode enable
```

```bash
adb shell cmd connectivity airplane-mode disable
```

Mengubah `applicationId` membuat pemasangan lama tidak ikut ter-upgrade.
Copot dulu paket lamanya sebelum memasang yang baru:

```bash
adb uninstall <application-id-lama>
```

### Debugger editor

`flutter run` mencetak alamat Dart VM Service (`ws://127.0.0.1:<port>/<token>`).
Tempelkan alamat itu pada perintah "Attach to Dart process"/"Attach to Flutter"
di editor untuk memasang debugger ke sesi yang sedang berjalan. Di VS Code,
`Dart: Attach to Flutter Process` menanyakan alamat tersebut.

---

## Menguji

```bash
flutter test
```

Gate verifikasi repo — ketiganya harus bersih:

```bash
flutter analyze
```

```bash
dart format --set-exit-if-changed .
```

```bash
flutter test
```

Struktur uji:

| Folder | Isi |
|---|---|
| `test/unit/` | Domain murni: jam, pengenal, hasil bertipe, validasi nilai, format Indonesia, token & kontras tema |
| `test/unit/architecture/` | Batas lapisan, larangan nilai gaya harfiah, larangan jam/pengenal langsung, kemandirian jaringan |
| `test/widget/` | Komponen dasar, splash, navigasi empat ruang, rute tidak dikenal, skala teks besar |
| `test/database/` | Konvensi record, integritas nilai, transaksi, kunci asing, dan harness migrasi — dijalankan terhadap SQLite nyata |

Uji arsitektur menegakkan aturan yang tidak punya padanan lint bawaan di
analyzer Dart (larangan impor lintas-lapisan, larangan warna/ukuran font
harfiah di luar berkas token). Aturan itu karena itu gagal di `flutter test`,
bukan di `flutter analyze`.

### Bila uji basis data gagal sebelum berjalan

Paket `sqlite3` mengunduh pustaka SQLite siap pakai dari halaman rilis GitHub
saat pertama kali `flutter test` dijalankan. Di jaringan yang memblokir host
unduhan rilis GitHub, unduhan itu mengembalikan halaman kesalahan dan uji gagal
dengan pesan `Hash of downloaded file ... is ..., expected ...` sebelum satu uji
pun berjalan.

Jalan keluarnya: ambil berkasnya lewat GitHub API (host yang berbeda), lalu
letakkan di cache yang sudah dipakai hook pembangunan. Jalankan dari akar repo
aplikasi, ganti `<versi>` dengan versi `sqlite3` di `pubspec.lock`:

```bash
curl -s "https://api.github.com/repos/simolus3/sqlite3.dart/releases/tags/sqlite3-<versi>"
```

Ambil `url` aset yang dibutuhkan dari keluaran itu — `sqlite3.x64.windows.dll`
untuk menjalankan uji di Windows, `libsqlite3.x64.android.so` dan
`libsqlite3.arm64.android.so` untuk membangun APK — lalu unduh satu per satu:

```bash
curl -sL -H "Accept: application/octet-stream" -o sqlite3.dll "<url-aset>"
```

Simpan tiap berkas sebagai `sqlite3.dll` (Windows) atau `libsqlite3.so`
(Android) di dalam
`.dart_tool/hooks_runner/shared/sqlite3/build/download-<8-karakter-pertama-hash>/`.
Nilai hash yang diharapkan ada di berkas `asset_hashes.dart` milik paket
`sqlite3` di pub cache, dan muncul juga pada pesan kegagalannya. Hook akan
memakai berkas yang hashnya cocok dan melewati unduhan.

---

## Struktur

```text
lib/
├── app/          # Akar aplikasi: tema, token, rute, penyedia, komponen dasar
├── core/         # Jam, pengenal, hasil/kegagalan bertipe, validasi, format
├── database/     # Drift/SQLite: tabel, migrasi, pembuka koneksi
├── data/         # Akses data yang mengimplementasikan konvensi record
├── domain/       # Dart murni — belum berisi apa pun di change 001
└── features/     # Splash dan empat ruang utama
```

Arah dependensi: `features → domain ← data`, `database` hanya dipakai `data`.
Lapisan domain tidak boleh mengimpor Flutter, Drift, jaringan, jam global,
atau pembangkit pengenal acak.

---

## Penyimpanan lokal

Perangkat adalah satu-satunya sumber kebenaran. Setiap record milik pengguna
memakai konvensi di `lib/database/tables/user_record_columns.dart`:

| Kolom | Arti |
|---|---|
| `id` | UUID v7 yang dibuat aplikasi — bukan nomor urut basis data |
| `created_at` | Waktu pembuatan (UTC); tidak pernah berubah |
| `updated_at` | Waktu pembaruan terakhir (UTC), diisi dari `Clock` yang disuntikkan |
| `deleted_at` | Penanda terhapus; pembacaan biasa selalu menyaringnya |
| `sync_status` | Selalu `local` di MVP 1 |
| `revision` | Naik satu pada setiap perubahan, ditegakkan pemicu basis data |

Waktu kejadian disimpan UTC; tanggal lokal (`YYYY-MM-DD`) dan pengenal zona
waktu dicatat terpisah saat penulisan, supaya berpindah zona waktu tidak
memindahkan catatan lama ke hari lain.

`harness_records` dan `harness_record_notes` **bukan tabel produk**. Keduanya
ada semata untuk membuktikan konvensi di atas sampai tabel domain sungguhan
masuk; lapisan fitur dilarang memakainya dan uji arsitektur menjaganya.

### Menambah migrasi

1. Ubah atau tambah tabel di `lib/database/tables/`.
2. Naikkan `kSchemaVersion` di `lib/database/app_database.dart`.
3. Tambahkan langkahnya di `onUpgrade` pada `AppDatabase.migration`, dari versi
   sebelumnya ke versi baru. Penurunan versi tidak didukung dan ditolak.
4. Bila tabel baru itu milik pengguna, tambahkan namanya ke
   `kUserRecordTables` di `lib/database/migrations/user_record_triggers.dart`
   dan buat pemicunya pada langkah migrasi.
5. Jalankan `dart run build_runner build`.
6. Tambah kasus uji di `test/database/migration_test.dart`: basis data kosong,
   basis data berisi data versi sebelumnya, dan migrasi yang terputus di
   tengah. Pemeriksaan pasca-migrasi (`verifyMigration`) harus sehat.

### Pratinjau web: penyimpanan tidak bertahan

Penyimpanan web yang bertahan membutuhkan worker bersama yang dapat memuat
`sqlite3.wasm` (`web/sqlite3.wasm` dan `web/drift_worker.js`). Sebagian
lingkungan browser melarangnya. Pada build **debug** saja, aplikasi lalu
memuat modul WASM di isolate utama dan memakai basis data in-memory supaya
iterasi antarmuka tetap jalan — lihat
`lib/database/connection/web_fallback_web.dart`. Konsekuensinya data pratinjau
web **tidak bertahan** antar muat ulang. Android tidak pernah memakai jalur ini.

---

## Desain

Nilai warna, tipografi, jarak, radius, dan elevasi hanya ditulis di
`lib/app/theme/`. Widget membacanya lewat tema atau kelas token; menulis nilai
gaya harfiah di luar folder itu menggagalkan uji arsitektur.

Satu penyimpangan dari `mealora.pen` yang disengaja: token `muted` digelapkan
dari `#687D70` menjadi `#63776A` agar memenuhi rasio kontras 4,5:1 untuk teks
biasa. Alasannya tercatat di `lib/app/theme/color_tokens.dart` dan dijaga uji
kontras di `test/unit/theme_test.dart`.

Aset merek ada di `assets/brand/`, disalin dari
`../../mealora-plans/docs/brand-assets/`. Ikon peluncur Android (termasuk ikon
adaptif dan monokrom) dibangun dari aset yang sama.
