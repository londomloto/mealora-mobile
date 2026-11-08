# domain/

Lapisan domain: entitas, nilai, dan layanan Dart murni.

Aturan yang berlaku di folder ini (ditegakkan oleh uji arsitektur di
`test/unit/architecture/`):

- dilarang mengimpor Flutter, Drift, paket jaringan, atau paket basis data;
- dilarang membaca jam sistem (`DateTime.now()`) atau membuat pengenal acak
  secara langsung — keduanya diterima lewat `Clock` dan `IdGenerator`;
- tidak mengetahui bentuk penyimpanan maupun bentuk tampilan.

Change 001 belum menambahkan isi apa pun di sini. Domain gizi dan program
masuk pada change berikutnya.
