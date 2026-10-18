/** Zona waktu tampilan. WIB tidak punya daylight saving, jadi selisihnya tetap 7 jam. */
export const ZONA_WAKTU = "Asia/Jakarta";
const SELISIH_WIB_MS = 7 * 60 * 60 * 1000;

const formatAngkaId = new Intl.NumberFormat("id-ID");

export function formatAngka(nilai: number): string {
  return formatAngkaId.format(nilai);
}

export function formatRupiah(nilai: number): string {
  return `Rp ${formatAngkaId.format(nilai)}`;
}

/** Contoh: "18 Okt 2026, 11.24" */
export function formatWaktu(iso: string): string {
  return new Intl.DateTimeFormat("id-ID", {
    dateStyle: "medium",
    timeStyle: "short",
    timeZone: ZONA_WAKTU,
  }).format(new Date(iso));
}

/**
 * Awal hari ini menurut WIB, dikembalikan sebagai ISO UTC —
 * supaya bisa dibandingkan langsung dengan kolom `dibuat_pada`.
 */
export function awalHariIniWib(): string {
  const sekarang = new Date(Date.now() + SELISIH_WIB_MS);
  sekarang.setUTCHours(0, 0, 0, 0);
  return new Date(sekarang.getTime() - SELISIH_WIB_MS).toISOString();
}
