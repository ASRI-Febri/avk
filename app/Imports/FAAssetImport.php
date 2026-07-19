<?php

namespace App\Imports;

use Illuminate\Support\Collection;
use Maatwebsite\Excel\Concerns\ToCollection;
use Maatwebsite\Excel\Concerns\WithHeadingRow;

/**
 * Import register aset tetap (migrasi saldo awal).
 * Membaca seluruh baris apa adanya; validasi & mapping dilakukan di
 * FAAssetImportController@preview supaya pesan error per baris bisa
 * ditampilkan ke user sebelum data disimpan.
 */
class FAAssetImport implements ToCollection, WithHeadingRow
{
    public $rows;

    public function collection(Collection $rows)
    {
        $this->rows = $rows;
    }
}
