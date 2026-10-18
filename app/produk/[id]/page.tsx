import { Suspense } from "react";
import Link from "next/link";
import { ambilProduk, daftarKategori, riwayatPergerakan } from "@/lib/stok";
import { formatAngka, formatRupiah, formatWaktu } from "@/lib/format";
import { KELAS_KARTU } from "@/lib/ui";
import FormProduk from "../form-produk";
import FormPergerakan from "./form-pergerakan";
import TombolHapus from "./tombol-hapus";

export const metadata = { title: "Detail produk" };

// Hanya butuh `params` — searchParams tidak dipakai di halaman ini.
type PropsHalaman = Pick<PageProps<"/produk/[id]">, "params">;

export default function HalamanDetail({ params }: PropsHalaman) {
  return (
    <Suspense fallback={<KerangkaDetail />}>
      <IsiDetail params={params} />
    </Suspense>
  );
}

function KerangkaDetail() {
  return (
    <div className="space-y-6">
      <div className="h-5 w-32 animate-pulse rounded bg-zinc-200 dark:bg-zinc-800" />
      <div className="h-8 w-64 animate-pulse rounded bg-zinc-200 dark:bg-zinc-800" />
      <div className="grid gap-4 sm:grid-cols-3">
        {Array.from({ length: 3 }).map((_, i) => (
          <div key={i} className={`${KELAS_KARTU} h-24 animate-pulse`} />
        ))}
      </div>
      <div className={`${KELAS_KARTU} h-64 animate-pulse`} />
    </div>
  );
}

function TidakDitemukan() {
  return (
    <div className={KELAS_KARTU}>
      <h1 className="text-lg font-semibold">Produk tidak ditemukan</h1>
      <p className="mt-2 text-sm text-zinc-600 dark:text-zinc-400">
        Produk ini mungkin sudah dihapus.
      </p>
      <Link
        href="/produk"
        className="mt-4 inline-block text-sm font-medium text-indigo-600 hover:text-indigo-500 dark:text-indigo-400"
      >
        ← Kembali ke daftar produk
      </Link>
    </div>
  );
}

async function IsiDetail({ params }: PropsHalaman) {
  const { id } = await params;
  const produkId = Number(id);

  if (!Number.isInteger(produkId) || produkId <= 0) return <TidakDitemukan />;

  const produk = await ambilProduk(produkId);
  if (!produk) return <TidakDitemukan />;

  const [riwayat, kategori] = await Promise.all([
    riwayatPergerakan(produkId),
    daftarKategori(),
  ]);

  const stokHabis = produk.stok === 0;
  const perluRestock = produk.stok <= produk.stok_minimum;

  return (
    <>
      <div className="flex flex-wrap items-center justify-between gap-3">
        <Link
          href="/produk"
          className="text-sm text-zinc-500 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-100"
        >
          ← Semua produk
        </Link>
        <TombolHapus id={produk.id} nama={produk.nama} />
      </div>

      <div className="mt-4 flex flex-wrap items-end justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">{produk.nama}</h1>
          <p className="mt-1 text-sm text-zinc-500 dark:text-zinc-400">
            {produk.sku}
            {produk.kategori ? ` · ${produk.kategori}` : ""}
          </p>
        </div>
        <span
          className={`rounded-full px-3 py-1 text-xs font-medium ${
            stokHabis
              ? "bg-red-100 text-red-700 dark:bg-red-950 dark:text-red-400"
              : perluRestock
                ? "bg-amber-100 text-amber-700 dark:bg-amber-950 dark:text-amber-400"
                : "bg-emerald-100 text-emerald-700 dark:bg-emerald-950 dark:text-emerald-400"
          }`}
        >
          {stokHabis ? "Stok habis" : perluRestock ? "Perlu restock" : "Stok aman"}
        </span>
      </div>

      <div className="mt-8 grid gap-4 sm:grid-cols-3">
        <div className={KELAS_KARTU}>
          <p className="text-xs font-medium uppercase tracking-wide text-zinc-500 dark:text-zinc-400">
            Stok saat ini
          </p>
          <p className="mt-2 text-3xl font-bold tracking-tight">
            {formatAngka(produk.stok)}
            <span className="ml-1 text-base font-medium text-zinc-500 dark:text-zinc-400">
              {produk.satuan}
            </span>
          </p>
        </div>
        <div className={KELAS_KARTU}>
          <p className="text-xs font-medium uppercase tracking-wide text-zinc-500 dark:text-zinc-400">
            Nilai stok
          </p>
          <p className="mt-2 text-3xl font-bold tracking-tight">
            {formatRupiah(produk.stok * produk.harga_jual)}
          </p>
        </div>
        <div className={KELAS_KARTU}>
          <p className="text-xs font-medium uppercase tracking-wide text-zinc-500 dark:text-zinc-400">
            Harga jual / minimum
          </p>
          <p className="mt-2 text-xl font-bold tracking-tight">
            {formatRupiah(produk.harga_jual)}
          </p>
          <p className="text-xs text-zinc-500 dark:text-zinc-400">
            min {formatAngka(produk.stok_minimum)} {produk.satuan}
          </p>
        </div>
      </div>

      <div className="mt-6 grid items-start gap-6 lg:grid-cols-2">
        <section className={KELAS_KARTU}>
          <h2 className="font-semibold">Catat pergerakan</h2>
          <p className="mt-1 text-sm text-zinc-600 dark:text-zinc-400">
            Setiap perubahan stok tercatat permanen dan tidak bisa ditimpa.
          </p>
          <div className="mt-4">
            <FormPergerakan produkId={produk.id} satuan={produk.satuan} />
          </div>
        </section>

        <section className={KELAS_KARTU}>
          <h2 className="font-semibold">Riwayat pergerakan</h2>
          {riwayat.length === 0 ? (
            <p className="mt-3 text-sm text-zinc-500 dark:text-zinc-400">
              Belum ada pergerakan untuk produk ini.
            </p>
          ) : (
            <ul className="mt-3 divide-y divide-zinc-200 dark:divide-zinc-800">
              {riwayat.map((m) => (
                <li key={m.id} className="flex items-start justify-between gap-4 py-2.5">
                  <div className="min-w-0">
                    <p className="text-sm">
                      <span
                        className={`font-semibold ${
                          m.jenis === "masuk"
                            ? "text-emerald-600 dark:text-emerald-500"
                            : "text-amber-600 dark:text-amber-500"
                        }`}
                      >
                        {m.jenis === "masuk" ? "+" : "-"}
                        {formatAngka(m.jumlah)}
                      </span>
                      <span className="ml-1 text-zinc-500 dark:text-zinc-400">
                        {m.jenis === "masuk" ? "masuk" : "keluar"}
                      </span>
                    </p>
                    {m.catatan ? (
                      <p className="truncate text-xs text-zinc-500 dark:text-zinc-400">
                        {m.catatan}
                      </p>
                    ) : null}
                  </div>
                  <time className="shrink-0 text-xs text-zinc-500 dark:text-zinc-400">
                    {formatWaktu(m.dibuat_pada)}
                  </time>
                </li>
              ))}
            </ul>
          )}
        </section>
      </div>

      <details className={`${KELAS_KARTU} mt-6`}>
        <summary className="cursor-pointer font-semibold">Ubah data produk</summary>
        <div className="mt-4">
          <FormProduk
            kategori={kategori}
            labelTombol="Simpan perubahan"
            produk={{
              id: produk.id,
              sku: produk.sku,
              nama: produk.nama,
              satuan: produk.satuan,
              harga_jual: produk.harga_jual,
              stok_minimum: produk.stok_minimum,
              kategori_id: produk.kategori_id,
            }}
          />
        </div>
      </details>
    </>
  );
}
