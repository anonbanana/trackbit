export default function Home() {
  return (
    <div className="flex flex-1 flex-col bg-zinc-50 text-zinc-900 dark:bg-zinc-950 dark:text-zinc-100">
      <header className="border-b border-zinc-200 dark:border-zinc-800">
        <div className="mx-auto flex w-full max-w-5xl items-center justify-between px-6 py-4">
          <span className="text-lg font-bold tracking-tight">TrackBit</span>
          <nav className="flex gap-4 text-sm text-zinc-600 dark:text-zinc-400">
            <a href="#fitur" className="hover:text-zinc-900 dark:hover:text-zinc-100">
              Fitur
            </a>
            <a href="#mulai" className="hover:text-zinc-900 dark:hover:text-zinc-100">
              Mulai
            </a>
          </nav>
        </div>
      </header>

      <main className="mx-auto flex w-full max-w-5xl flex-1 flex-col justify-center px-6 py-20">
        <h1 className="max-w-2xl text-4xl font-bold leading-tight tracking-tight sm:text-5xl">
          Kelola bisnis kecil dari browser — di HP maupun komputer.
        </h1>
        <p className="mt-6 max-w-xl text-lg leading-relaxed text-zinc-600 dark:text-zinc-400">
          Penjualan, stok barang, invoice, dan laporan dalam satu aplikasi web
          yang ringan. Tanpa install aplikasi, cukup buka di browser.
        </p>

        <section id="fitur" className="mt-16 grid gap-6 sm:grid-cols-3">
          {[
            {
              title: "Penjualan & POS",
              desc: "Catat transaksi kasir dan penjualan online dengan cepat.",
            },
            {
              title: "Stok & Produk",
              desc: "Pantau stok, kategori, dan pergerakan barang secara real time.",
            },
            {
              title: "Invoice & Laporan",
              desc: "Buat tagihan pelanggan dan lihat ringkasan keuangan bisnis.",
            },
          ].map((f) => (
            <div
              key={f.title}
              className="rounded-xl border border-zinc-200 bg-white p-5 shadow-sm dark:border-zinc-800 dark:bg-zinc-900"
            >
              <h2 className="font-semibold">{f.title}</h2>
              <p className="mt-2 text-sm leading-relaxed text-zinc-600 dark:text-zinc-400">
                {f.desc}
              </p>
            </div>
          ))}
        </section>

        <section id="mulai" className="mt-16">
          <button
            type="button"
            className="inline-flex h-11 items-center justify-center rounded-lg bg-indigo-600 px-6 text-sm font-medium text-white transition-colors hover:bg-indigo-500"
          >
            Coba sekarang
          </button>
        </section>
      </main>

      <footer className="border-t border-zinc-200 py-6 text-center text-sm text-zinc-500 dark:border-zinc-800">
        TrackBit — aplikasi web manajemen bisnis.
      </footer>
    </div>
  );
}
