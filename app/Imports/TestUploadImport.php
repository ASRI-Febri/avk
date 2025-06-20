<?php

namespace App\Imports;

use App\TestUpload;
use Maatwebsite\Excel\Concerns\ToModel;

class TestUploadImport implements ToModel
{
    /**
    * @param array $row
    *
    * @return \Illuminate\Database\Eloquent\Model|null
    */
    public function model(array $row)
    {
        return new TestUpload([
            'CustomerID' => $row[0],
            'CustomerName' => $row[1],
        ]);
    }
}
