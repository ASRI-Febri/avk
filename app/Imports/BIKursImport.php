<?php

namespace App\Imports;

use Illuminate\Support\Collection;
use Maatwebsite\Excel\Concerns\ToCollection;

/**
 * Import file "Kurs Transaksi" hasil download website Bank Indonesia.
 * Membaca seluruh baris apa adanya tanpa heading row; struktur file BI tetap:
 * judul "Kurs Transaksi dd-Mmm-yyyy" lalu tabel NO, Mata Uang, Nilai,
 * Kurs Jual, Kurs Beli. Validasi & mapping dilakukan di
 * BIMiddleRateController@preview.
 */
class BIKursImport implements ToCollection
{
    public $rows;

    public function collection(Collection $rows)
    {
        $this->rows = $rows;
    }
}
