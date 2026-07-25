<?php

namespace App\Imports;

use Illuminate\Support\Collection;
use Maatwebsite\Excel\Concerns\ToCollection;

/**
 * Import daftar DTTOT (Daftar Terduga Teroris dan Organisasi Teroris).
 * Membaca seluruh baris apa adanya tanpa heading row karena posisi kolom
 * file resmi tetap: Nama, Deskripsi, Terduga, Kode Densus, Tempat Lahir,
 * Tanggal Lahir, WN/Asal Negara, Alamat. Validasi & mapping dilakukan di
 * DTTOTController@preview.
 */
class DTTOTImport implements ToCollection
{
    public $rows;

    public function collection(Collection $rows)
    {
        $this->rows = $rows;
    }
}
