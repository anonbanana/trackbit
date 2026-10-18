import { Suspense } from "react";
import Link from "next/link";
import { produkPerluRestock, ringkasanStok } from "@/lib/stok";
import { formatAngka, formatRupiah } from "@/lib/format";
import { KELAS_KARTU, KELAS_TOMBOL_KECIL } from "@/lib/ui";

export const metadata = { title: "Dashboard" };

export default function Dashboard() {
  return (
    <>
      <div className="flex flex-wrap items-end justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Dashboard</h1>
          <p className="mt-1 text-sm text-zinc-600 dark:text-zinc-400">
            Angka stok terkini, dihitung dari seluruh pergerakan barang.
          </p>
        </div>
        <Link href="/produk" className={KELAS_TOMBOL_KECIL}>
          Kelola produk
        </Link>
      </div>

      <Suspense fallback={<KerangkaDashboard />}>
        <IsiDashboard />
      </Suspense>
    </>
  );
}

function KerangkaDashboard() {
  return (
    <div className="mt-8 space-y-6">
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {Array.from({ length: 4 }).map((_, i) => (
          <div key={i} className={`${KELAS_KARTU} animate-pulse`}>
            <div className="h-3 w-24 rounded bg-zinc-200 dark:bg-zinc-800" />
            <div className="mt-3 h-7 w-32 rounded bg-zinc-200 dark:bg-zinc-800" />
          </div>
        ))}
      </div>
      <div className={`${KELAS_KARTU} animate-pulse`}>
        <div className="h-3 w-40 rounded bg-zinc-200 dark:bg-zinc-800" />
        <div className="mt-4 h-16 rounded bg-zinc-100 dark:bg-zinc-800/60" />
      </div>
    </div>
  );
}

async function IsiDashboard() {
  const [ringkasan, perluRestock] = await Promise.all([
    ringkasanStok(),
    produkPerluRestock(),
  ]);

  const kartu = [
    { label: "Jumlah produk", nilai: formatAngka(ringkasan.jumlah_produk) },
    { label: "Nilai stok", nilai: formatRupiah(ringkasan.nilai_stok) },
    { label: "Perlu restock", nilai: formatAngka(ringkasan.produk_menipis) },
    { label: "Pergerakan hari ini", nilai: formatAngka(ringkasan.pergerakan_hari_ini) },
  ];

  return (
    <div className="mt-8 space-y-6">
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {kartu.map((k) => (
          <div key={k.label} className={KELAS_KARTU}>
            <p className="text-xs font-medium uppercase tracking-wide text-zinc-500 dark:text-zinc-400">
              {k.label}
            </p>
            <p className="mt-2 text-2xl font-bold tracking-tight">{k.nilai}</p>
          </div>
        ))}
      </div>

      <section className={KELAS_KARTU}>
        <h2 className="font-semibold">Perlu restock</h2>
        <p className="mt-1 text-sm text-zinc-600 dark:text-zinc-400">
          Produk yang stoknya sudah menyentuh batas minimum.
        </p>

        {perluRestock.length === 0 ? (
          <p className="mt-4 text-sm text-zinc-500 dark:text-zinc-400">
            Semua produk masih di atas batas minimum.
          </p>
        ) : (
          <ul className="mt-4 divide-y divide-zinc-200 dark:divide-zinc-800">
            {perluRestock.map((p) => (
              <li key={p.id} className="flex items-center justify-between gap-4 py-3">
                <div className="min-w-0">
                  <Link
                    href={`/produk/${p.id}`}
                    className="font-medium hover:text-indigo-600 dark:hover:text-indigo-400"
                  >
                    {p.nama}
                  </Link>
                  <p className="text-xs text-zinc-500 dark:text-zinc-400">{p.sku}</p>
                </div>
                <div className="text-right text-sm">
                  <p className="font-semibold text-amber-600 dark:text-amber-500">
                    {formatAngka(p.stok)} {p.satuan}
                  </p>
                  <p className="text-xs text-zinc-500 dark:text-zinc-400">
                    min {formatAngka(p.stok_minimum)}
                  </p>
                </div>
              </li>
            ))}
          </ul>
        )}
      </section>
    </div>
  );
}
