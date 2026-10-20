"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import {
  catatPergerakan,
  hapusProduk,
  KesalahanStok,
  simpanProduk,
  type JenisPergerakan,
} from "./stok";

export type HasilAksi = { ok: boolean; pesan: string };

/**
 * Ubah teks form menjadi bilangan bulat.
 * Koma/titik ribuan dibuang supaya "1.500" tetap terbaca 1500, bukan 1.5.
 */
function keBulat(nilai: FormDataEntryValue | null): number | null {
  if (typeof nilai !== "string") return null;
  const bersih = nilai.trim().replace(/[.\s]/g, "").replace(",", ".");
  if (bersih === "") return 0;
  const angka = Number(bersih);
  if (!Number.isFinite(angka)) return null;
  return Math.round(angka);
}

function teks(nilai: FormDataEntryValue | null): string {
  return typeof nilai === "string" ? nilai.trim() : "";
}

export async function simpanProdukAksi(
  _sebelumnya: HasilAksi | null,
  data: FormData,
): Promise<HasilAksi> {
  const sku = teks(data.get("sku"));
  const nama = teks(data.get("nama"));
  const satuan = teks(data.get("satuan")) || "pcs";
  const hargaJual = keBulat(data.get("harga_jual"));
  const stokMinimum = keBulat(data.get("stok_minimum"));
  const idMentah = teks(data.get("id"));
  const id = idMentah ? Number(idMentah) : null;
  const kategoriIdMentah = teks(data.get("kategori_id"));
  const kategoriBaru = teks(data.get("kategori_baru"));

  if (!sku) return { ok: false, pesan: "SKU wajib diisi." };
  if (!nama) return { ok: false, pesan: "Nama produk wajib diisi." };
  if (hargaJual === null || hargaJual < 0)
    return { ok: false, pesan: "Harga jual harus angka 0 atau lebih." };
  if (stokMinimum === null || stokMinimum < 0)
    return { ok: false, pesan: "Stok minimum harus angka 0 atau lebih." };

  try {
    const idTersimpan = simpanProduk({
      id: id && Number.isInteger(id) ? id : null,
      sku,
      nama,
      satuan,
      harga_jual: hargaJual,
      stok_minimum: stokMinimum,
      kategori_id: kategoriIdMentah ? Number(kategoriIdMentah) : null,
      kategori_baru: kategoriBaru || null,
    });

    revalidatePath("/");
    revalidatePath("/produk");
    revalidatePath(`/produk/${idTersimpan}`);

    return {
      ok: true,
      pesan: id ? `Perubahan "${nama}" tersimpan.` : `Produk "${nama}" ditambahkan.`,
    };
  } catch (galat) {
    if (galat instanceof KesalahanStok) return { ok: false, pesan: galat.message };
    console.error("[trackbit] gagal menyimpan produk:", galat);
    return { ok: false, pesan: "Gagal menyimpan produk. Cek log server." };
  }
}

export async function catatPergerakanAksi(
  _sebelumnya: HasilAksi | null,
  data: FormData,
): Promise<HasilAksi> {
  const produkId = Number(teks(data.get("produk_id")));
  const jenisMentah = teks(data.get("jenis"));
  const jumlah = keBulat(data.get("jumlah"));
  const catatan = teks(data.get("catatan"));

  if (!Number.isInteger(produkId) || produkId <= 0)
    return { ok: false, pesan: "Produk tidak valid." };
  if (jenisMentah !== "masuk" && jenisMentah !== "keluar")
    return { ok: false, pesan: "Pilih Barang Masuk atau Barang Keluar." };
  if (jumlah === null || jumlah <= 0)
    return { ok: false, pesan: "Jumlah harus angka bulat lebih dari 0." };

  const jenis: JenisPergerakan = jenisMentah;

  try {
    catatPergerakan({ produk_id: produkId, jenis, jumlah, catatan: catatan || null });

    revalidatePath("/");
    revalidatePath("/produk");
    revalidatePath(`/produk/${produkId}`);

    return {
      ok: true,
      pesan:
        jenis === "masuk"
          ? `${jumlah} tercatat masuk.`
          : `${jumlah} tercatat keluar.`,
    };
  } catch (galat) {
    if (galat instanceof KesalahanStok) return { ok: false, pesan: galat.message };
    console.error("[trackbit] gagal mencatat pergerakan:", galat);
    return { ok: false, pesan: "Gagal mencatat pergerakan. Cek log server." };
  }
}

export async function hapusProdukAksi(
  _sebelumnya: HasilAksi | null,
  data: FormData,
): Promise<HasilAksi> {
  const id = Number(teks(data.get("id")));
  if (!Number.isInteger(id) || id <= 0) return { ok: false, pesan: "Produk tidak valid." };

  try {
    hapusProduk(id);
  } catch (galat) {
    if (galat instanceof KesalahanStok) return { ok: false, pesan: galat.message };
    console.error("[trackbit] gagal menghapus produk:", galat);
    return { ok: false, pesan: "Gagal menghapus produk. Cek log server." };
  }

  revalidatePath("/");
  revalidatePath("/produk");
  redirect("/produk");
}
