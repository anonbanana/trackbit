"use client";

import { useActionState } from "react";
import { simpanProdukAksi, type HasilAksi } from "@/lib/actions";
import type { Kategori } from "@/lib/stok";
import { useSudahHidrasi } from "@/lib/use-sudah-hidrasi";
import { KELAS_INPUT, KELAS_LABEL, KELAS_TOMBOL } from "@/lib/ui";

export type ProdukAwal = {
  id: number;
  sku: string;
  nama: string;
  satuan: string;
  harga_jual: number;
  stok_minimum: number;
  kategori_id: number | null;
};

export default function FormProduk({
  kategori,
  produk,
  labelTombol = "Tambah produk",
}: {
  kategori: Kategori[];
  produk?: ProdukAwal;
  labelTombol?: string;
}) {
  const [hasil, kirim, sedangKirim] = useActionState<HasilAksi | null, FormData>(
    simpanProdukAksi,
    null,
  );
  const sudahSiap = useSudahHidrasi();

  return (
    <form action={kirim} className="space-y-4">
      {produk ? <input type="hidden" name="id" value={produk.id} /> : null}

      <div className="grid gap-4 sm:grid-cols-2">
        <div>
          <label htmlFor="sku" className={KELAS_LABEL}>
            SKU
          </label>
          <input
            id="sku"
            name="sku"
            required
            defaultValue={produk?.sku}
            placeholder="BRG-001"
            className={KELAS_INPUT}
          />
        </div>
        <div>
          <label htmlFor="satuan" className={KELAS_LABEL}>
            Satuan
          </label>
          <input
            id="satuan"
            name="satuan"
            defaultValue={produk?.satuan ?? "pcs"}
            placeholder="pcs"
            className={KELAS_INPUT}
          />
        </div>
      </div>

      <div>
        <label htmlFor="nama" className={KELAS_LABEL}>
          Nama produk
        </label>
        <input
          id="nama"
          name="nama"
          required
          defaultValue={produk?.nama}
          placeholder="Contoh: Kopi Arabika 250 gram"
          className={KELAS_INPUT}
        />
      </div>

      <div className="grid gap-4 sm:grid-cols-2">
        <div>
          <label htmlFor="harga_jual" className={KELAS_LABEL}>
            Harga jual (Rp)
          </label>
          <input
            id="harga_jual"
            name="harga_jual"
            type="number"
            inputMode="numeric"
            min={0}
            step={1}
            defaultValue={produk?.harga_jual ?? 0}
            className={KELAS_INPUT}
          />
        </div>
        <div>
          <label htmlFor="stok_minimum" className={KELAS_LABEL}>
            Stok minimum
          </label>
          <input
            id="stok_minimum"
            name="stok_minimum"
            type="number"
            inputMode="numeric"
            min={0}
            step={1}
            defaultValue={produk?.stok_minimum ?? 0}
            className={KELAS_INPUT}
          />
        </div>
      </div>

      <div>
        <label htmlFor="kategori_id" className={KELAS_LABEL}>
          Kategori
        </label>
        <select
          id="kategori_id"
          name="kategori_id"
          defaultValue={produk?.kategori_id ?? ""}
          className={KELAS_INPUT}
        >
          <option value="">— tanpa kategori —</option>
          {kategori.map((k) => (
            <option key={k.id} value={k.id}>
              {k.nama}
            </option>
          ))}
        </select>
      </div>

      <div>
        <label htmlFor="kategori_baru" className={KELAS_LABEL}>
          Atau tulis kategori baru
        </label>
        <input
          id="kategori_baru"
          name="kategori_baru"
          placeholder="Contoh: Minuman"
          className={KELAS_INPUT}
        />
      </div>

      <button
        type="submit"
        disabled={!sudahSiap || sedangKirim}
        className={KELAS_TOMBOL}
      >
        {sedangKirim ? "Menyimpan…" : labelTombol}
      </button>

      <p aria-live="polite" className="min-h-5 text-sm">
        {hasil ? (
          <span
            className={
              hasil.ok
                ? "text-emerald-600 dark:text-emerald-500"
                : "text-red-600 dark:text-red-500"
            }
          >
            {hasil.pesan}
          </span>
        ) : null}
      </p>
    </form>
  );
}
