import Database from "better-sqlite3";
import { mkdirSync } from "node:fs";
import path from "node:path";

/**
 * Satu file database SQLite untuk seluruh aplikasi.
 * Lokasi bisa dipindah lewat env TRACKBIT_DB (berguna untuk backup / test).
 */
const FOLDER_DATA = path.join(process.cwd(), "data");
export const BERKAS_DB =
  process.env.TRACKBIT_DB ?? path.join(FOLDER_DATA, "trackbit.db");

const SKEMA = `
CREATE TABLE IF NOT EXISTS kategori (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  nama         TEXT NOT NULL UNIQUE,
  dibuat_pada  TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS produk (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  sku           TEXT NOT NULL UNIQUE,
  nama          TEXT NOT NULL,
  satuan        TEXT NOT NULL DEFAULT 'pcs',
  -- Uang SELALU bilangan bulat rupiah, tidak pernah pecahan (float).
  -- Pelajaran dari app lama: double membuat angka melenceng tanpa ketahuan.
  harga_jual    INTEGER NOT NULL DEFAULT 0 CHECK (harga_jual >= 0),
  stok_minimum  INTEGER NOT NULL DEFAULT 0 CHECK (stok_minimum >= 0),
  kategori_id   INTEGER REFERENCES kategori(id) ON DELETE SET NULL,
  dibuat_pada   TEXT NOT NULL,
  diubah_pada   TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS pergerakan_stok (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  produk_id    INTEGER NOT NULL REFERENCES produk(id) ON DELETE CASCADE,
  jenis        TEXT NOT NULL CHECK (jenis IN ('masuk', 'keluar')),
  jumlah       INTEGER NOT NULL CHECK (jumlah > 0),
  catatan      TEXT,
  dibuat_pada  TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_pergerakan_produk
  ON pergerakan_stok (produk_id, id);
`;

type WadahGlobal = typeof globalThis & { __trackbitDb?: Database.Database };

/**
 * Buka (sekali saja) lalu pakai terus. Tabel dibuat otomatis kalau belum ada.
 * Disimpan di globalThis supaya hot-reload saat `next dev` tidak membuka
 * koneksi baru terus-menerus.
 */
export function ambilDb(): Database.Database {
  const wadah = globalThis as WadahGlobal;
  if (wadah.__trackbitDb) return wadah.__trackbitDb;

  mkdirSync(path.dirname(BERKAS_DB), { recursive: true });
  const db = new Database(BERKAS_DB);

  // WAL = baca dan tulis tidak saling memblokir (lebih cepat, lebih aman).
  db.pragma("journal_mode = WAL");
  db.pragma("foreign_keys = ON");
  db.exec(SKEMA);

  wadah.__trackbitDb = db;
  return db;
}

/** Waktu sekarang dalam UTC, format ISO. Disimpan apa adanya, ditampilkan WIB. */
export function waktuSekarang(): string {
  return new Date().toISOString();
}
