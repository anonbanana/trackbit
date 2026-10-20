# TrackBit

Aplikasi web manajemen bisnis kecil. Fokus pertama: **stok yang cepat, ringan, dan akurat**.
Dibuka di browser — HP maupun komputer — tanpa install aplikasi.

Versi Flutter lama (v1.0.0) tidak hilang; masih bisa diambil dari tag `v1.0.0`.

## Menjalankan

```bash
npm install
npm run dev          # http://localhost:3000
```

> **Penting:** `better-sqlite3` adalah modul native dan butuh compiler C++.
> Di mesin ini `g++` tidak terpasang, jadi arahkan ke `clang++`:
>
> ```bash
> CXX=c++ CC=cc npm install
> ```
>
> Kalau tidak, pemasangan gagal dengan pesan `make: g++: No such file or directory`.

## Cara data disimpan

- Satu file SQLite: `data/trackbit.db` (diabaikan git — isinya data bisnis).
- **Uang selalu bilangan bulat rupiah.** Tidak pernah pecahan, supaya angka tidak
  melenceng diam-diam. (Bug ini ada di app Flutter lama.)
- **Stok dihitung dari buku pergerakan** (`pergerakan_stok`), bukan angka yang ditimpa.
  Stok sebuah produk = jumlah semua `masuk` dikurangi semua `keluar`.
- Barang keluar yang melebihi stok ditolak **di dalam satu transaksi**, jadi
  stok tidak mungkin minus walau dua tab menekan tombol bersamaan.

## Yang sudah jalan

| Bagian | Isi |
|---|---|
| Dashboard | jumlah produk, nilai stok, perlu restock, pergerakan hari ini |
| Produk | daftar, tambah, ubah, hapus, kategori (bisa dibuat langsung dari form) |
| Detail produk | catat barang masuk / keluar + riwayat lengkap |

## Belum ada

Login/akun, kasir (POS), invoice, laporan keuangan, barcode, banyak gudang.

## Catatan

- `documentation/` masih menceritakan app Flutter lama — perlu diperbarui.
- Halaman jualan lama ada di cabang `gh-pages` repo ini dan masih menawarkan
  "Download APK"; perlu diganti setelah app web ini matang.
- Kerangka halaman sengaja statis (Partial Prerender): tampilan muncul dulu,
  angka stok menyusul. Karena itu semua pembacaan database lewat `connection()`.
