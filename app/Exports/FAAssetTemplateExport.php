<?php

namespace App\Exports;

use Maatwebsite\Excel\Concerns\FromArray;
use Maatwebsite\Excel\Concerns\WithHeadings;

/**
 * Template Excel import register aset tetap (migrasi saldo awal).
 * Baris pertama berisi satu contoh data yang harus dihapus/diganti user.
 */
class FAAssetTemplateExport implements FromArray, WithHeadings
{
    public function headings(): array
    {
        return [
            'kode_aset',
            'nama_aset',
            'keterangan',
            'kategori',
            'cabang',
            'departemen',
            'tgl_perolehan',
            'tgl_mulai_pakai',
            'harga_perolehan',
            'nilai_residu',
            'umur_bulan',
            'metode',
            'kelompok_fiskal',
            'metode_fiskal',
            'akum_penyusutan_awal',
            'no_referensi',
        ];
    }

    public function array(): array
    {
        return [
            [
                '',                     // kode_aset: kosongkan = generate otomatis
                'Mobil Operasional Avanza',
                'Contoh baris - hapus/ganti dengan data aset Anda',
                'VHC',                  // kategori: CategoryCode di master Kategori Aset
                'JKT',                  // cabang: BranchID di master Cabang
                '',                     // departemen: DepartmentID (opsional)
                '2024-03-15',           // tgl_perolehan (YYYY-MM-DD)
                '2024-04-01',           // tgl_mulai_pakai (YYYY-MM-DD)
                '250000000',            // harga_perolehan
                '25000000',             // nilai_residu
                '96',                   // umur_bulan
                'SL',                   // metode: SL = Garis Lurus, DB = Saldo Menurun
                '2',                    // kelompok_fiskal: 1-4 / BP / BN (opsional)
                'SL',                   // metode_fiskal: SL / DB (opsional)
                '56250000',             // akum_penyusutan_awal (akumulasi s/d migrasi)
                'INV-2024-001',         // no_referensi (opsional)
            ],
        ];
    }
}
