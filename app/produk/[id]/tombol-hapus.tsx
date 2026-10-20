"use client";

import { useActionState } from "react";
import { hapusProdukAksi, type HasilAksi } from "@/lib/actions";
import { useSudahHidrasi } from "@/lib/use-sudah-hidrasi";

export default function TombolHapus({ id, nama }: { id: number; nama: string }) {
  const [hasil, kirim, sedangKirim] = useActionState<HasilAksi | null, FormData>(
    hapusProdukAksi,
    null,
  );
  const sudahSiap = useSudahHidrasi();

  return (
    <form
      action={kirim}
      onSubmit={(peristiwa) => {
        const setuju = window.confirm(
          `Hapus "${nama}" beserta seluruh riwayat stoknya? Tindakan ini tidak bisa dibatalkan.`,
        );
        if (!setuju) peristiwa.preventDefault();
      }}
    >
      <input type="hidden" name="id" value={id} />
      <button
        type="submit"
        disabled={!sudahSiap || sedangKirim}
        className="inline-flex h-9 items-center justify-center rounded-lg border border-red-200 px-3 text-sm font-medium text-red-600 transition-colors hover:bg-red-50 disabled:cursor-not-allowed disabled:opacity-60 dark:border-red-900 dark:text-red-400 dark:hover:bg-red-950"
      >
        {sedangKirim ? "Menghapus…" : "Hapus produk"}
      </button>
      {hasil && !hasil.ok ? (
        <p aria-live="polite" className="mt-2 text-sm text-red-600 dark:text-red-500">
          {hasil.pesan}
        </p>
      ) : null}
    </form>
  );
}
