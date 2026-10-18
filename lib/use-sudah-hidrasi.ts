"use client";

import { useEffect, useState } from "react";

/**
 * Menandai bahwa React sudah selesai "menyala" di browser.
 *
 * Kenapa perlu? Sebelum menyala, tombol kirim form masih bersifat HTML biasa.
 * Kalau ditekan saat itu, browser mengirim form dengan cara lama (halaman
 * dimuat ulang) dan semua ketikan pengguna hilang. Dengan menonaktifkan
 * tombol sampai siap, kejadian itu tidak mungkin terjadi.
 */
export function useSudahHidrasi(): boolean {
  const [siap, setSiap] = useState(false);
  useEffect(() => setSiap(true), []);
  return siap;
}
