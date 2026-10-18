import { Suspense } from "react";
import Link from "next/link";
import { daftarKategori, daftarProduk } from "@/lib/stok";
import { formatAngka, formatRupiah } from "@/lib/format";
import { KELAS_KARTU } from "@/lib/ui";
import FormProduk from "./form-produk";

export const metadata = { title: "Produk" };

export default function HalamanProduk() {
  return (
    <>
      <h1 className="text-2xl font-bold tracking-tight">Produk</h1>
      <p className="mt-1 text-sm text-zinc-600 dark:text-zinc-400">
        Daftar barang beserta stok saat ini. Klik nama produk untuk mencatat
        barang masuk atau keluar.
      </p>

      <Suspense fallback={<KerangkaProduk />}>
        <IsiProduk />
      </Suspense>
    </>
  );
}

function KerangkaProduk() {
  return (
    <div className="mt-8 grid gap-6 lg:grid-cols-[1.5fr_1fr]">
      <div className={`${KELAS_KARTU} h-64 animate-pulse`} />
      <div className={`${KELAS_KARTU} h-64 animate-pulse`} />
    </div>
  );
}

async function IsiProduk() {
  const [produk, kategori] = await Promise.all([daftarProduk(), daftarKategori()]);

  return (
    <div className="mt-8 grid items-start gap-6 lg:grid-cols-[1.5fr_1fr]">
      <section className={`${KELAS_KARTU} overflow-x-auto`}>
        {produk.length === 0 ? (
          <p className="text-sm text-zinc-500 dark:text-zinc-400">
            Belum ada produk. Tambah produk pertama lewat formulir di samping.
          </p>
        ) : (
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-zinc-200 text-left text-xs uppercase tracking-wide text-zinc-500 dark:border-zinc-800 dark:text-zinc-400">
                <th className="pb-3 pr-3 font-medium">Produk</th>
                <th className="pb-3 pr-3 text-right font-medium">Stok</th>
                <th className="pb-3 pr-3 text-right font-medium">Harga</th>
                <th className="pb-3 text-right font-medium">Nilai</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-zinc-200 dark:divide-zinc-800">
              {produk.map((p) => (
                <tr key={p.id}>
                  <td className="py-3 pr-3">
                    <Link
                      href={`/produk/${p.id}`}
                      className="font-medium hover:text-indigo-600 dark:hover:text-indigo-400"
                    >
                      {p.nama}
                    </Link>
                    <p className="text-xs text-zinc-500 dark:text-zinc-400">
                      {p.sku}
                      {p.kategori ? ` · ${p.kategori}` : ""}
                    </p>
                  </td>
                  <td className="py-3 pr-3 text-right">
                    <span
                      className={
                        p.stok <= p.stok_minimum
                          ? "font-semibold text-amber-600 dark:text-amber-500"
                          : "font-medium"
                      }
                    >
                      {formatAngka(p.stok)}
                    </span>
                    <span className="ml-1 text-xs text-zinc-500 dark:text-zinc-400">
                      {p.satuan}
                    </span>
                  </td>
                  <td className="py-3 pr-3 text-right text-zinc-600 dark:text-zinc-400">
                    {formatRupiah(p.harga_jual)}
                  </td>
                  <td className="py-3 text-right text-zinc-600 dark:text-zinc-400">
                    {formatRupiah(p.stok * p.harga_jual)}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>

      <section className={KELAS_KARTU}>
        <h2 className="font-semibold">Tambah produk</h2>
        <p className="mt-1 text-sm text-zinc-600 dark:text-zinc-400">
          Stok awal ditambahkan lewat halaman produk, bukan di sini.
        </p>
        <div className="mt-4">
          <FormProduk kategori={kategori} />
        </div>
      </section>
    </div>
  );
}
