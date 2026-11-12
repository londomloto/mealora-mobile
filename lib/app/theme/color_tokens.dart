import 'dart:ui';

/// Token warna Mealora.
///
/// Sumber nilai: variabel dan sampel layar di dokumen desain
/// `mealora-plans/docs/mealora-v2.pen` ("Mealora · UI system & interactions"
/// dan layar-layar terkait) — palet hijau/mint/lime dengan permukaan kaca
/// (glassmorphism) di atas latar hijau pucat.
///
/// Ini satu-satunya tempat nilai warna ditulis. Widget membaca warna lewat
/// tema atau lewat kelas ini, tidak pernah menulis nilai heksadesimal sendiri
/// — aturan ini ditegakkan oleh uji arsitektur.
abstract final class MealoraColors {
  /// Latar aplikasi.
  static const Color background = Color(0xFFF2F7F3);

  /// Permukaan kartu solid (non-kaca) dan kolom isian.
  static const Color surface = Color(0xFFFFFFFF);

  /// Warna merek dipakai di permukaan ber-teks (mis. `FilledButton`,
  /// `ColorScheme.primary`) — "Hijau tua" di palet desain. Dipilih atas
  /// varian yang lebih terang (`primaryBright`) karena `primaryBright` hanya
  /// mencapai rasio kontras 3,38:1 di atas putih, di bawah ambang 4,5:1 untuk
  /// teks biasa. Uji kontras di `test/unit/theme_test.dart` menjaga nilai ini.
  static const Color primary = Color(0xFF077A50);

  /// "Hijau" — varian merek lebih terang untuk ikon, aksen, dan isian ring
  /// non-teks (tidak dipakai sebagai latar di belakang teks putih).
  static const Color primaryBright = Color(0xFF12A05C);

  /// Hijau tua-pekat — titik awal gradien hero/CTA ("deep forest").
  static const Color primaryDeep = Color(0xFF0A6B4C);

  /// Hijau muda-terang — titik akhir gradien hero penuh layar (splash,
  /// welcome, kartu target).
  static const Color primaryLight = Color(0xFF35C97E);

  /// Gradien hero penuh layar (200°, 3 titik): hijau pekat → hijau cerah →
  /// hijau muda. Dipakai lewat `LinearGradient(colors: heroGradient, stops:
  /// heroGradientStops, ...)`.
  static const List<Color> heroGradient = <Color>[
    primaryDeep,
    primaryBright,
    primaryLight,
  ];
  static const List<double> heroGradientStops = <double>[0, 0.6, 1];

  /// Teks/ikon di atas [primary].
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Teks sekunder (tanggal, label) di atas hero gradien gelap.
  static const Color onPrimaryMuted = Color(0xFFDFF3E6);

  /// Eyebrow terang pada kartu hero target.
  static const Color onPrimaryEyebrow = Color(0xFFCFF3DD);

  /// Teks tersier (footnote) di atas hero gradien gelap.
  static const Color onPrimaryFaint = Color(0xFFC9EEDB);

  /// Mint — aksen sekunder (badge, sorotan ringan).
  static const Color mint = Color(0xFF3FD5A0);

  /// Lime — aksen dekoratif (blob latar, sorotan langka).
  static const Color lime = Color(0xFFB6ED6A);

  /// Permukaan pratinjau pemindai barcode pada layar `21`.
  static const List<Color> barcodeScannerGradient = <Color>[
    Color(0xFF0D2B20),
    Color(0xFF1D4436),
  ];

  /// Lapisan dan aksen khusus bingkai pemindai barcode (`21`).
  static const Color barcodeScannerWindow = Color(0x14B6ED6A);
  static const Color barcodeScannerBorder = Color(0x33FFFFFF);
  static const Color barcodeScannerScrim = Color(0x8A0D2B20);
  static const List<Color> barcodeScannerSweepGradient = <Color>[
    Color(0x00B6ED6A),
    Color(0x1FB6ED6A),
    Color(0x80B6ED6A),
    Color(0x1FB6ED6A),
    Color(0x00B6ED6A),
  ];

  /// Kuning aksen (mis. makro lemak).
  static const Color accent = Color(0xFFFFB020);

  /// Oranye-koral hangat (mis. makro protein, status perhatian lembut).
  static const Color peach = Color(0xFFFF7A5A);

  /// Biru aksen (kategori/ilustrasi, jarang dipakai untuk teks).
  static const Color info = Color(0xFF6E8BFF);

  /// Gradien batang tren berat (`31`, atas ke bawah): biru aksen → hijau
  /// terang, dipakai pada jalur kapsul yang punya catatan.
  static const List<Color> weightTrendGradient = <Color>[info, primaryBright];

  /// Hijau pekat kedua yang menjadi titik akhir gradien ruas kebiasaan
  /// minggu ini (`05`) — berbeda dari [primary] dan [primaryBright],
  /// diambil langsung dari rancangan.
  static const Color consistencyDeep = Color(0xFF0E8B57);

  /// Gradien ruas kebiasaan minggu ini (`05`, atas ke bawah): hijau muda
  /// terang → hijau pekat.
  static const List<Color> consistencyGradient = <Color>[
    primaryLight,
    consistencyDeep,
  ];

  /// Warna teks utama (tinta).
  static const Color ink = Color(0xFF10291E);

  /// Warna teks sekunder.
  ///
  /// Dokumen desain memakai `#5C7667`. Nilai itu hanya mencapai rasio
  /// kontras 4,42:1 di atas latar isian `#EAF5EC` — di bawah ambang 4,5:1
  /// untuk teks biasa. Token digelapkan 2% menjadi `#5A7465` (4,56:1 di atas
  /// `#EAF5EC`, 4,70:1 di atas [background]) agar memenuhi ambang tanpa
  /// mengubah rona merek. Uji kontras di `test/unit/theme_test.dart` menjaga
  /// nilai ini.
  static const Color muted = Color(0xFF5A7465);

  /// Latar lembut untuk sorotan dan keadaan terpilih (padanan opak dari kaca
  /// hijau 12% di atas putih).
  static const Color softGreen = Color(0xFFE3F4EC);

  /// Latar tujuan navigasi terpilih — hijau 12% tembus, dipakai langsung di
  /// atas permukaan kaca dok navigasi (`Tab · Hari ini` di dokumen desain).
  static const Color primarySelectedTint = Color(0x1F12A05C);

  /// Latar ubin ikon di dalam kartu/formulir.
  static const Color iconField = Color(0xFFEAF5EC);

  /// Garis pembatas dan tepi kartu solid.
  static const Color line = Color(0xFFE6EFE7);

  /// Latar bilah progres dan jalur netral.
  static const Color track = Color(0xFFDFEAE1);

  /// Ikon afordansi netral (chevron, panah kecil) di atas permukaan kaca.
  static const Color affordance = Color(0xFF9FB3A6);

  /// Lingkaran pilihan yang belum aktif pada kartu onboarding.
  static const Color selectionIdle = Color(0xFFB9CDBF);

  /// Permukaan kaca untuk kartu utama (putih 65% di atas [background]).
  static const Color glassCard = Color(0xA6FFFFFF);

  /// Permukaan kaca kuat (ubin ikon, tombol dalam kartu — putih 85%).
  static const Color glassStrong = Color(0xD9FFFFFF);

  /// Permukaan kaca sedang (kapsul statistik ringkas — putih 72%).
  static const Color glassSoft = Color(0xB8FFFFFF);

  /// Permukaan kaca untuk kartu pilihan aktif (putih 82%).
  static const Color glassSelected = Color(0xD1FFFFFF);

  /// Permukaan note bertint sesuai varian di dokumen desain.
  static const Color noteWarning = Color(0xCCFFF8E8);
  static const Color noteSuccess = Color(0xCCDDF4E6);
  static const Color noteInfo = Color(0xCCEEF1FF);

  /// Tint koral lembut untuk ikon aksi Riwayat pada ruang Program.
  static const Color historyActionTint = Color(0xFFFFECE8);

  /// Latar ubin ikon beraksen kuning/amber (mis. jalur pencarian pada lembar
  /// tambah makanan, nilai energi/karbohidrat pada kisi nutrisi — change
  /// 007).
  static const Color iconFieldAmber = Color(0xFFFFF4DA);

  /// Latar ubin ikon beraksen biru (mis. jalur suara pada lembar tambah
  /// makanan, ikon waktu makan malam — change 007).
  static const Color iconFieldBlue = Color(0xFFE6EBFF);

  /// Latar ubin ikon beraksen hijau pekat (opak, berbeda dari [softGreen] —
  /// mis. jalur foto pada lembar tambah makanan, tombol tambah hasil
  /// pencarian — change 007).
  static const Color iconFieldGreen = Color(0xFFDDF4E6);

  /// Latar ubin ikon beraksen koral (mis. jalur barcode pada lembar tambah
  /// makanan, nilai lemak pada kisi nutrisi — change 007).
  static const Color iconFieldCoral = Color(0xFFFFE9E2);

  /// Teks aksen amber pekat untuk nilai pada kisi nutrisi makanan sendiri
  /// (energi, karbohidrat — change 007).
  static const Color amberText = Color(0xFFA96B00);

  /// Teks aksen koral pekat untuk nilai lemak pada kisi nutrisi dan label
  /// tindakan hapus (change 007).
  static const Color coralText = Color(0xFFB4452B);

  /// Teks penanda "perkiraan" di atas [iconFieldAmber] — 5,4:1, lebih
  /// gelap dari [amberText] (4,0:1) karena labelnya berukuran kecil
  /// (change 015, desain 67/71).
  static const Color estimateText = Color(0xFF8A5A00);

  /// Permukaan lembar modal (mis. lembar tambah makanan) — putih hampir
  /// pekat di atas latar aplikasi (change 007).
  static const Color sheetSurface = Color(0xF0F4FAF5);

  /// Scrim layar `02 · Tambah makanan` — hijau tinta 50% di atas layar yang
  /// diburamkan 6 px.
  static const Color modalScrim = Color(0x8007321F);

  /// Bayangan ke atas pada lembar modal (`0 -10 40`, hijau tinta 20%).
  static const Color shadowSheet = Color(0x3306281A);

  /// Permukaan dan bayangan card pilihan pada lembar `02 · Tambah makanan`.
  static const Color sheetOptionSurface = Color(0xC7FFFFFF);
  static const Color shadowSheetOption = Color(0x140B3A28);

  /// Permukaan kaca pudar di atas hero gelap (chip aktif — putih 18%).
  static const Color glassOnHero = Color(0x2EFFFFFF);

  /// Permukaan dan tepi kaca khusus layar sambutan di atas hero gelap.
  static const Color welcomeCard = Color(0x24FFFFFF);
  static const Color welcomeCardBorder = Color(0x52FFFFFF);
  static const Color welcomeIconBorder = Color(0x66FFFFFF);

  /// Isian ubin ikon pudar di atas hero gelap (putih 20%).
  static const Color glassOnHeroStrong = Color(0x33FFFFFF);

  /// Garis tepi kaca (putih 80%, `strokeAlignment: inner` 1 px).
  static const Color glassBorder = Color(0xCCFFFFFF);

  /// Permukaan navigasi kapsul mengambang — sama dengan [glassCard].
  static const Color navigationSurface = glassCard;

  /// Lapisan transisi di belakang dock: konten tetap tampak lalu melebur ke
  /// latar aplikasi sebelum mencapai area aman bawah.
  static const Color navigationScrimTransparent = Color(0x00F2F7F3);
  static const Color navigationScrimSoft = Color(0xB8F2F7F3);

  /// Bayangan dock lebih ringan daripada bayangan kartu biasa agar tidak
  /// membentuk pita gelap pada scrim transparan.
  static const Color shadowNavigation = Color(0x120B3A28);

  /// Warna dasar bayangan permukaan kaca (hijau-tinta 10% opak).
  static const Color shadowGlass = Color(0x1A0B3A28);

  /// Warna dasar bayangan tombol CTA (hijau 28% opak).
  static const Color shadowButton = Color(0x470C8B55);

  /// Bayangan inti tombol CTA untuk memberi kedalaman tepat di bawah tombol.
  static const Color shadowButtonCore = Color(0x330C8B55);

  /// Bayangan FAB Catat pada navigasi bawah.
  static const Color shadowFab = Color(0x590C8B55);

  /// Bayangan kartu hero target.
  static const Color shadowHero = Color(0x400C8B55);

  /// Bayangan tombol putih pada layar sambutan.
  static const Color shadowWelcomeButton = Color(0x4D05271A);

  /// Gradien tombol CTA dan FAB · Catat (135°, hijau terang → hijau tua).
  static const List<Color> ctaGradient = <Color>[
    Color(0xFF2BC46B),
    Color(0xFF0C8B55),
  ];

  /// Transparan murni — dipakai untuk menyingkirkan latar `Material` bawaan
  /// di belakang permukaan gradien/kaca yang digambar sendiri.
  static const Color transparent = Color(0x00000000);

  /// Warna dasar bayangan lama (dipakai `ColorScheme.shadow`, Material
  /// menerapkan opasitasnya sendiri).
  static const Color shadow = Color(0xFF0B3A28);

  /// Warna untuk keadaan kesalahan yang dapat dibaca pengguna.
  ///
  /// Dokumen v2 tidak mendefinisikan ulang warna galat; nilai Material lama
  /// dipertahankan karena sudah memenuhi kontras AA (6,54:1 di atas putih).
  static const Color danger = Color(0xFFB3261E);

  // Kartu berbagi (change 014) — rancangan `59`–`62` dan `57` di
  // `mealora-v2.pen`.

  /// Gradien kartu ringkasan harian (`59`, rotasi 200°).
  static const List<Color> shareCardGradient = <Color>[
    Color(0xFF0A6B4C),
    Color(0xFF077A50),
    Color(0xFF35C97E),
  ];

  /// Tanggal dan baris makro di kartu ringkasan.
  static const Color shareCardMuted = Color(0xFFBFE8CF);

  /// Lintasan cincin di kartu ringkasan.
  static const Color shareCardTrack = Color(0x2EFFFFFF);

  /// Scrim atas/bawah di atas foto kartu makanan (`62`).
  static const Color shareCardScrim = Color(0x660A1F17);
  static const Color shareCardScrimClear = Color(0x000A1F17);

  /// Chip watermark putih di atas foto kartu makanan.
  static const Color shareCardChip = Color(0xE8FFFFFF);

  /// Chip waktu makan gelap di atas foto kartu makanan.
  static const Color shareCardDarkChip = Color(0x730A1F17);
  static const Color shareCardDarkChipBorder = Color(0x47FFFFFF);

  /// Bidang di dalam panel kartu makanan.
  static const Color shareCardField = Color(0xFFF4F8F5);

  /// Bayangan panel mengambang dan pratinjau kartu.
  static const Color shadowShareCard = Color(0x3D04231A);

  /// Gradien pengganti saat kartu makanan tanpa foto.
  static const List<Color> shareCardPhotoFallback = <Color>[
    Color(0xFF8C5A2B),
    Color(0xFFC98B4B),
    Color(0xFFE8C98A),
  ];

  /// Tombol sekunder di atas latar kaca (`57`, "Selesai").
  static const Color secondaryButtonBorder = Color(0xFFD7E7DB);
}
