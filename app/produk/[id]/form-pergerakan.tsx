"use client";

import { useActionState } from "react";
import { catatPergerakanAksi, type HasilAksi } from "@/lib/actions";
import { useSudahHidrasi } from "@/lib/use-sudah-hidrasi";
import { KELAS_INPUT, KELAS_LABEL, KELAS_TOMBOL } from "@/lib/ui";

export default function FormPergerakan({
  produkId,
  satuan,
}: {
  produkId: number;
  satuan: string;
}) {
  const [hasil, kirim, sedangKirim] = useActionState<HasilAksi | null, FormData>(
    catatPergerakanAksi,
    null,
  );
  const sudahSiap = useSudahHidrasi();

  return (
    <form action={kirim} className="space-y-4">
      <input type="hidden" name="produk_id" value={produkId} />

      <fieldset>
        <legend className={KELAS_LABEL}>Jenis</legend>
        <div className="grid grid-cols-2 gap-2">
          <label className="flex h-11 cursor-pointer items-center justify-center gap-2 rounded-lg border border-zinc-300 text-sm font-medium has-checked:border-emerald-500 has-checked:bg-emerald-50 has-checked:text-emerald-700 dark:border-zinc-700 dark:has-checked:border-emerald-600 dark:has-checked:bg-emerald-950 dark:has-checked:text-emerald-400">
            <input
              type="radio"
              name="jenis"
              value="masuk"
              defaultChecked
              className="accent-emerald-600"
            />
            Barang masuk
          </label>
          <label className="flex h-11 cursor-pointer items-center justify-center gap-2 rounded-lg border border-zinc-300 text-sm font-medium has-checked:border-amber-500 has-checked:bg-amber-50 has-checked:text-amber-700 dark:border-zinc-700 dark:has-checked:border-amber-600 dark:has-checked:bg-amber-950 dark:has-checked:text-amber-400">
            <input
              type="radio"
              name="jenis"
              value="keluar"
              className="accent-amber-600"
            />
            Barang keluar
          </label>
        </div>
      </fieldset>

      <div>
        <label htmlFor="jumlah" className={KELAS_LABEL}>
          Jumlah ({satuan})
        </label>
        <input
          id="jumlah"
          name="jumlah"
          type="number"
          inputMode="numeric"
          min={1}
          step={1}
          required
          defaultValue={1}
          className={KELAS_INPUT}
        />
      </div>

      <div>
        <label htmlFor="catatan" className={KELAS_LABEL}>
          Catatan (boleh kosong)
        </label>
        <input
          id="catatan"
          name="catatan"
          placeholder="Contoh: pembelian dari supplier"
          className={KELAS_INPUT}
        />
      </div>

      <button
        type="submit"
        disabled={!sudahSiap || sedangKirim}
        className={KELAS_TOMBOL}
      >
        {sedangKirim ? "Menyimpan…" : "Simpan pergerakan"}
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
