import { connection } from "next/server";
import { ambilDb, waktuSekarang } from "./db";
import { awalHariIniWib } from "./format";

export type JenisPergerakan = "masuk" | "keluar";

export type Produk = {
  id: number;
  sku: string;
  nama: string;
  satuan: string;
  harga_jual: number;
  stok_minimum: number;
  kategori_id: number | null;
  kategori: string | null;
  stok: number;
  dibuat_pada: string;
  diubah_pada: string;
};

export type Kategori = { id: number; nama: string };

export type Pergerakan = {
  id: number;
  jenis: JenisPergerakan;
  jumlah: number;
  catatan: string | null;
  dibuat_pada: string;
};

export type Ringkasan = {
  jumlah_produk: number;
  nilai_stok: number;
  produk_menipis: number;
  pergerakan_hari_ini: number;
};

/** Kesalahan yang disengaja (aturan bisnis), bukan bug — pesannya aman ditampilkan. */
export class KesalahanStok extends Error {}

/** Stok sebuah produk = jumlah seluruh pergerakan masuk dikurangi keluar. */
const POTONGAN_STOK = `COALESCE(SUM(CASE WHEN m.jenis = 'masuk' THEN m.jumlah ELSE -m.jumlah END), 0)`;

const SQL_PRODUK = `
  SELECT p.id, p.sku, p.nama, p.satuan, p.harga_jual, p.stok_minimum,
         p.kategori_id, k.nama AS kategori, p.dibuat_pada, p.diubah_pada,
         ${POTONGAN_STOK} AS stok
    FROM produk p
    LEFT JOIN kategori k        ON k.id = p.kategori_id
    LEFT JOIN pergerakan_stok m ON m.produk_id = p.id
`;

const SQL_STOK_SATU = `
  SELECT COALESCE(SUM(CASE WHEN jenis = 'masuk' THEN jumlah ELSE -jumlah END), 0) AS stok
    FROM pergerakan_stok
   WHERE produk_id = ?
`;

// ---------------------------------------------------------------------------
// Baca (perlu request-time, jadi selalu lewat connection())
// ---------------------------------------------------------------------------

export async function daftarProduk(): Promise<Produk[]> {
  await connection();
  return ambilDb()
    .prepare(`${SQL_PRODUK} GROUP BY p.id ORDER BY p.nama COLLATE NOCASE`)
    .all() as Produk[];
}

export async function ambilProduk(id: number): Promise<Produk | undefined> {
  await connection();
  return ambilDb()
    .prepare(`${SQL_PRODUK} WHERE p.id = ? GROUP BY p.id`)
    .get(id) as Produk | undefined;
}

export async function daftarKategori(): Promise<Kategori[]> {
  await connection();
  return ambilDb()
    .prepare(`SELECT id, nama FROM kategori ORDER BY nama COLLATE NOCASE`)
    .all() as Kategori[];
}

export async function riwayatPergerakan(produkId: number): Promise<Pergerakan[]> {
  await connection();
  return ambilDb()
    .prepare(
      `SELECT id, jenis, jumlah, catatan, dibuat_pada
         FROM pergerakan_stok
        WHERE produk_id = ?
        ORDER BY id DESC
        LIMIT 100`,
    )
    .all(produkId) as Pergerakan[];
}

/** Produk yang stoknya sudah menyentuh / di bawah batas minimum. */
export async function produkPerluRestock(batas = 5): Promise<Produk[]> {
  await connection();
  return ambilDb()
    .prepare(
      `${SQL_PRODUK}
        GROUP BY p.id
       HAVING stok <= p.stok_minimum
        ORDER BY stok ASC, p.nama COLLATE NOCASE
        LIMIT ?`,
    )
    .all(batas) as Produk[];
}

export async function ringkasanStok(): Promise<Ringkasan> {
  await connection();
  const db = ambilDb();

  const angka = db
    .prepare(
      `SELECT COUNT(*) AS jumlah_produk,
              COALESCE(SUM(harga_jual * stok), 0) AS nilai_stok,
              COALESCE(SUM(CASE WHEN stok <= stok_minimum THEN 1 ELSE 0 END), 0) AS produk_menipis
         FROM (${SQL_PRODUK} GROUP BY p.id)`,
    )
    .get() as Omit<Ringkasan, "pergerakan_hari_ini">;

  const hariIni = db
    .prepare(
      `SELECT COUNT(*) AS jumlah FROM pergerakan_stok WHERE dibuat_pada >= ?`,
    )
    .get(awalHariIniWib()) as { jumlah: number };

  return { ...angka, pergerakan_hari_ini: hariIni.jumlah };
}

// ---------------------------------------------------------------------------
// Tulis (dipanggil dari server action)
// ---------------------------------------------------------------------------

function keIdKategori(nama: string): number {
  const db = ambilDb();
  const bersih = nama.trim();
  db.prepare(
    `INSERT INTO kategori (nama, dibuat_pada) VALUES (?, ?) ON CONFLICT(nama) DO NOTHING`,
  ).run(bersih, waktuSekarang());
  const baris = db
    .prepare(`SELECT id FROM kategori WHERE nama = ?`)
    .get(bersih) as { id: number };
  return baris.id;
}

/**
 * Tambah produk baru (id kosong) atau ubah produk yang sudah ada.
 * Mengembalikan id produk.
 */
export function simpanProduk(input: {
  id?: number | null;
  sku: string;
  nama: string;
  satuan: string;
  harga_jual: number;
  stok_minimum: number;
  kategori_id: number | null;
  kategori_baru: string | null;
}): number {
  const db = ambilDb();
  const sekarang = waktuSekarang();
  const kategoriId = input.kategori_baru ? keIdKategori(input.kategori_baru) : input.kategori_id;

  try {
    if (input.id) {
      const hasil = db
        .prepare(
          `UPDATE produk
              SET sku = ?, nama = ?, satuan = ?, harga_jual = ?,
                  stok_minimum = ?, kategori_id = ?, diubah_pada = ?
            WHERE id = ?`,
        )
        .run(
          input.sku,
          input.nama,
          input.satuan,
          input.harga_jual,
          input.stok_minimum,
          kategoriId,
          sekarang,
          input.id,
        );
      if (hasil.changes === 0) throw new KesalahanStok("Produk tidak ditemukan.");
      return input.id;
    }

    const hasil = db
      .prepare(
        `INSERT INTO produk
           (sku, nama, satuan, harga_jual, stok_minimum, kategori_id, dibuat_pada, diubah_pada)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      )
      .run(
        input.sku,
        input.nama,
        input.satuan,
        input.harga_jual,
        input.stok_minimum,
        kategoriId,
        sekarang,
        sekarang,
      );
    return Number(hasil.lastInsertRowid);
  } catch (galat) {
    if (galat instanceof KesalahanStok) throw galat;
    if (kodeSqlite(galat) === "SQLITE_CONSTRAINT_UNIQUE") {
      throw new KesalahanStok(`SKU "${input.sku}" sudah dipakai produk lain.`);
    }
    throw galat;
  }
}

export function hapusProduk(id: number): void {
  const hasil = ambilDb().prepare(`DELETE FROM produk WHERE id = ?`).run(id);
  if (hasil.changes === 0) throw new KesalahanStok("Produk tidak ditemukan.");
}

/**
 * Catat barang masuk / keluar. Dijalankan dalam satu transaksi:
 * kalau stok tidak cukup, tidak ada satu baris pun yang tersimpan.
 */
export function catatPergerakan(input: {
  produk_id: number;
  jenis: JenisPergerakan;
  jumlah: number;
  catatan: string | null;
}): void {
  const db = ambilDb();

  const jalan = db.transaction(() => {
    const produk = db
      .prepare(`SELECT id, nama FROM produk WHERE id = ?`)
      .get(input.produk_id) as { id: number; nama: string } | undefined;
    if (!produk) throw new KesalahanStok("Produk tidak ditemukan.");

    if (input.jenis === "keluar") {
      const { stok } = db.prepare(SQL_STOK_SATU).get(input.produk_id) as { stok: number };
      if (stok < input.jumlah) {
        throw new KesalahanStok(
          `Stok tidak cukup: sisa ${stok}, diminta keluar ${input.jumlah}.`,
        );
      }
    }

    db.prepare(
      `INSERT INTO pergerakan_stok (produk_id, jenis, jumlah, catatan, dibuat_pada)
       VALUES (?, ?, ?, ?, ?)`,
    ).run(input.produk_id, input.jenis, input.jumlah, input.catatan, waktuSekarang());
  });

  jalan();
}

function kodeSqlite(galat: unknown): string | undefined {
  if (typeof galat === "object" && galat !== null && "code" in galat) {
    const kode = (galat as { code?: unknown }).code;
    if (typeof kode === "string") return kode;
  }
  return undefined;
}
