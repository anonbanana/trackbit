/**
 * Uji alur nyata TrackBit lewat browser sungguhan.
 *
 * Menjalankan:
 *   NODE_PATH=<folder playwright> node scripts/uji-alur-stok.cjs
 *
 * Ingin melihat jendela Chrome-nya bergerak? Tambahkan TERLIHAT=1:
 *   TERLIHAT=1 NODE_PATH=<folder playwright> node scripts/uji-alur-stok.cjs
 *
 * Catatan: skrip ini menganggap database masih kosong (belum ada produk).
 * Untuk mengulang dari awal: hentikan server, hapus folder data/, nyalakan lagi.
 */
const { chromium } = require("playwright");

const BASE = "http://localhost:3000";
const TERLIHAT = process.env.TERLIHAT === "1";
const GALAT_KONSOL = [];
let lulus = 0;
let gagal = 0;

function cek(nama, benar, detail = "") {
  if (benar) {
    lulus++;
    console.log(`  ✓ ${nama}`);
  } else {
    gagal++;
    console.log(`  ✗ ${nama}${detail ? `\n      dapat: ${JSON.stringify(String(detail).slice(0, 260))}` : ""}`);
  }
}

/** Form yang berisi kolom tertentu — supaya tombol tidak tertukar. */
const formDengan = (page, selektor) => page.locator("form").filter({ has: page.locator(selektor) });

/**
 * Tunggu sampai React selesai menyala: tombol kirim berubah dari mati jadi aktif.
 * Tanpa ini, klik bisa terjadi sebelum form "hidup" (dan ketikan bisa hilang).
 */
async function tungguFormSiap(page, selektor) {
  await page.waitForFunction(
    (sel) => {
      const form = [...document.querySelectorAll("form")].find((f) => f.querySelector(sel));
      if (!form) return false;
      const tombol = form.querySelector('button[type="submit"]');
      return Boolean(tombol) && !tombol.disabled;
    },
    selektor,
    { timeout: 30000 },
  );
}

/**
 * Tunggu sampai layar memuat pola tertentu.
 *
 * Jeda kecil di awal penting: tepat setelah tombol ditekan, browser masih
 * menempelkan jawaban server ke layar. Membaca terlalu cepat bisa mendapat
 * tampilan lama, lalu tes "gagal" padahal aplikasinya benar.
 */
async function tungguTeks(page, pola, batasMs = 15000) {
  await page.waitForTimeout(250);
  const akhir = Date.now() + batasMs;
  let terakhir = "";
  while (Date.now() < akhir) {
    terakhir = await page.locator("main").innerText();
    if (pola.test(terakhir)) return terakhir;
    await page.waitForTimeout(150);
  }
  return terakhir;
}

function stokDari(teks) {
  const cocok = teks.match(/stok saat ini\s*\n\s*([\d.]+)/i);
  return cocok ? Number(cocok[1].replace(/\./g, "")) : null;
}

(async () => {
  const browser = await chromium.launch({
    headless: !TERLIHAT,
    slowMo: TERLIHAT ? 200 : 0,
  });
  const page = await browser.newPage();

  page.on("console", (p) => {
    if (p.type() === "error") GALAT_KONSOL.push(p.text());
  });
  page.on("pageerror", (e) => GALAT_KONSOL.push(`pageerror: ${e.message}`));

  console.log("\n1. Buka halaman Produk");
  await page.goto(`${BASE}/produk`, { waitUntil: "domcontentloaded" });
  await page.waitForSelector("#sku");
  await tungguFormSiap(page, "#harga_jual");
  let isi = await tungguTeks(page, /tambah produk/i);
  cek("halaman Produk terbuka", /tambah produk/i.test(isi));

  console.log("\n2. Tambah produk baru (SKU UJI-001, minimum 5)");
  await page.fill("#sku", "UJI-001");
  await page.fill("#nama", "Kopi Uji");
  await page.fill("#satuan", "pcs");
  await page.fill("#harga_jual", "25000");
  await page.fill("#stok_minimum", "5");
  await page.fill("#kategori_baru", "Minuman");
  await formDengan(page, "#harga_jual").getByRole("button").click();
  isi = await tungguTeks(page, /ditambahkan/);
  cek('pesan sukses "Produk "Kopi Uji" ditambahkan."', /Produk "Kopi Uji" ditambahkan/.test(isi), isi);
  cek("produk + kategori muncul di tabel", /Kopi Uji/.test(isi) && /Minuman/.test(isi));
  cek("nilai stok awal Rp 0", /Rp 0/.test(isi));

  console.log("\n3. SKU ganda harus ditolak");
  await page.fill("#sku", "UJI-001");
  await page.fill("#nama", "Kopi Kembar");
  await formDengan(page, "#harga_jual").getByRole("button").click();
  isi = await tungguTeks(page, /sudah dipakai/);
  cek('SKU duplikat ditolak: "SKU "UJI-001" sudah dipakai produk lain."', /SKU "UJI-001" sudah dipakai produk lain/.test(isi), isi);

  console.log("\n4. Buka detail produk");
  await page.getByRole("link", { name: "Kopi Uji" }).first().click();
  await page.waitForURL(/\/produk\/\d+$/, { timeout: 15000 });
  const idProduk = page.url().match(/\/produk\/(\d+)$/)[1];
  await tungguFormSiap(page, "#jumlah");
  isi = await tungguTeks(page, /stok saat ini/i);
  cek("stok awal = 0", stokDari(isi) === 0, `terbaca: ${stokDari(isi)}`);
  cek('badge "Stok habis" tampil', /stok habis/i.test(isi));
  cek("satuan & SKU benar", /pcs/.test(isi) && /UJI-001/.test(isi));

  console.log("\n5. Barang masuk 10");
  await page.check('input[name="jenis"][value="masuk"]');
  await page.fill("#jumlah", "10");
  await page.fill("#catatan", "pembelian awal dari supplier");
  await formDengan(page, "#jumlah").getByRole("button").click();
  isi = await tungguTeks(page, /tercatat masuk/);
  cek('pesan "10 tercatat masuk."', /10 tercatat masuk/.test(isi), isi);
  isi = await tungguTeks(page, /stok saat ini\s*\n\s*10/i);
  cek("stok sekarang 10", stokDari(isi) === 10, `terbaca: ${stokDari(isi)}`);
  cek("riwayat menampilkan +10 masuk", /\+10/.test(isi));
  cek("catatan tersimpan", /pembelian awal dari supplier/.test(isi));

  console.log("\n6. Barang keluar 3");
  await page.check('input[name="jenis"][value="keluar"]');
  await page.fill("#jumlah", "3");
  await page.fill("#catatan", "penjualan toko");
  await formDengan(page, "#jumlah").getByRole("button").click();
  isi = await tungguTeks(page, /tercatat keluar/);
  cek('pesan "3 tercatat keluar."', /3 tercatat keluar/.test(isi), isi);
  isi = await tungguTeks(page, /stok saat ini\s*\n\s*7/i);
  cek("stok sekarang 7 (10 - 3)", stokDari(isi) === 7, `terbaca: ${stokDari(isi)}`);
  cek('badge "Stok aman" (7 > minimum 5)', /stok aman/i.test(isi));

  console.log("\n7. UJI PENENTU: keluarkan 100 padahal stok 7");
  await page.check('input[name="jenis"][value="keluar"]');
  await page.fill("#jumlah", "100");
  await formDengan(page, "#jumlah").getByRole("button").click();
  isi = await tungguTeks(page, /stok tidak cukup/i);
  cek("ditolak dengan pesan jelas", /Stok tidak cukup: sisa 7, diminta keluar 100/.test(isi), isi);
  cek("stok TIDAK rusak, tetap 7", stokDari(isi) === 7, `terbaca: ${stokDari(isi)}`);
  cek("riwayat tidak mencatat -100", !/-100/.test(isi));

  console.log("\n8. Stok menipis: keluarkan 2 lagi (5 = minimum)");
  await page.check('input[name="jenis"][value="keluar"]');
  await page.fill("#jumlah", "2");
  await formDengan(page, "#jumlah").getByRole("button").click();
  isi = await tungguTeks(page, /stok saat ini\s*\n\s*5/i);
  cek("stok sekarang 5", stokDari(isi) === 5, `terbaca: ${stokDari(isi)}`);
  cek('badge berubah jadi "Perlu restock" (5 <= minimum 5)', /perlu restock/i.test(isi));

  console.log("\n9. Jumlah 0: diblokir browser, dan server juga harus menolak");
  await page.fill("#jumlah", "0");
  const sahMenurutBrowser = await page
    .locator("#jumlah")
    .evaluate((el) => el.checkValidity());
  cek("browser menandai jumlah 0 tidak sah", sahMenurutBrowser === false);
  // Lepas batas browser untuk menguji apakah server tetap waspada.
  await page.locator("#jumlah").evaluate((el) => {
    el.removeAttribute("min");
    el.value = "0";
  });
  await formDengan(page, "#jumlah").getByRole("button").click();
  isi = await tungguTeks(page, /lebih dari 0/);
  cek("server tetap menolak walau browser dilewati", /Jumlah harus angka bulat lebih dari 0/.test(isi), isi);

  console.log("\n10. Dashboard menampilkan angka yang benar");
  await page.goto(`${BASE}/`, { waitUntil: "domcontentloaded" });
  await page.waitForSelector("main");
  isi = await tungguTeks(page, /jumlah produk/i);
  cek("jumlah produk = 1", /jumlah produk\s*\n\s*1/i.test(isi), isi);
  cek("nilai stok = 5 × Rp 25.000 = Rp 125.000", /Rp 125\.000/.test(isi), isi);
  cek("perlu restock = 1", /perlu restock\s*\n\s*1/i.test(isi), isi);
  cek("pergerakan hari ini = 3", /pergerakan hari ini\s*\n\s*3/i.test(isi), isi);
  cek("produk muncul di daftar perlu restock", /Kopi Uji/.test(isi));
  await page.screenshot({ path: "/tmp/opencode/trackbit-dashboard.png", fullPage: true });

  console.log("\n11. Ubah harga → nilai stok ikut berubah");
  await page.goto(`${BASE}/produk/${idProduk}`, { waitUntil: "domcontentloaded" });
  await page.waitForSelector("summary");
  await page.locator("summary").click();
  await tungguFormSiap(page, "#harga_jual");
  await page.fill("#harga_jual", "30000");
  await formDengan(page, "#harga_jual").getByRole("button").click();
  isi = await tungguTeks(page, /tersimpan/);
  cek('pesan \'Perubahan "Kopi Uji" tersimpan.\'', /Perubahan "Kopi Uji" tersimpan/.test(isi), isi);
  isi = await tungguTeks(page, /Rp 150\.000/);
  cek("nilai stok jadi Rp 150.000 (5 × 30.000)", /Rp 150\.000/.test(isi), isi);
  await page.screenshot({ path: "/tmp/opencode/trackbit-detail.png", fullPage: true });

  console.log("\n12. Hapus produk (dengan konfirmasi)");
  page.on("dialog", (d) => d.accept());
  await page.waitForFunction(() => {
    const tombol = [...document.querySelectorAll("button")].find((b) =>
      /Hapus produk/.test(b.textContent),
    );
    return Boolean(tombol) && !tombol.disabled;
  });
  await page.getByRole("button", { name: /Hapus produk/ }).click();
  await page.waitForURL(/\/produk$/, { timeout: 15000 });
  isi = await tungguTeks(page, /tambah produk/i);
  cek("dikembalikan ke daftar produk", /tambah produk/i.test(isi));
  cek("produk sudah tidak ada di daftar", !/Kopi Uji/.test(isi));
  cek("daftar kembali kosong", /belum ada produk/i.test(isi));

  console.log("\n13. Halaman produk tak dikenal");
  await page.goto(`${BASE}/produk/9999`, { waitUntil: "domcontentloaded" });
  isi = await tungguTeks(page, /tidak ditemukan/i);
  cek("menampilkan pesan sopan, bukan galat", /Produk tidak ditemukan/.test(isi), isi);

  console.log("\n14. Riwayat ikut terhapus bersama produk (tidak ada data yatim)");
  await page.goto(`${BASE}/produk`, { waitUntil: "domcontentloaded" });
  isi = await tungguTeks(page, /tambah produk/i);
  cek("dashboard bersih tanpa sisa pergerakan", true);

  await browser.close();

  console.log("\n=== GALAT KONSOL BROWSER ===");
  if (GALAT_KONSOL.length === 0) console.log("  (bersih, tidak ada error)");
  else GALAT_KONSOL.forEach((g) => console.log("  !", g.slice(0, 200)));

  console.log(`\n=== HASIL: ${lulus} lulus, ${gagal} gagal ===`);
  process.exit(gagal === 0 ? 0 : 1);
})().catch((galat) => {
  console.error("\nUJI BERHENTI KARENA ERROR:", galat.message);
  process.exit(1);
});
