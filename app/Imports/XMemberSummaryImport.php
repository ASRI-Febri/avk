<?php

namespace App\Imports;

use App\XMemberSummary;
use Maatwebsite\Excel\Concerns\ToModel;
use Maatwebsite\Excel\Concerns\WithStartRow;

class XMemberSummaryImport implements ToModel, WithStartRow
{
    /**
    * @param array $row
    *
    * @return \Illuminate\Database\Eloquent\Model|null
    */

    private $upload_id;

    public function __construct($upload_id)
    { 
        $this->upload_id = $upload_id;
    }
    
    public function model(array $row)
    {
        return new XMemberSummary([
            'UploadID' => $this->upload_id,
            'CompanyID' => $row[0],
            'CompanyName' => $row[1],
            'LocationID' => $row[2],
            'LocationName' => $row[3],

            'SalesDate' => date('Y-m-d', strtotime($row[4])),
            'TransactionType' => $row[5],
            'TransactionQty' => $row[6],
            'TransactionAmount' => (double) str_replace(',', '', $row[7]),
            'Remark' => $row[8],
            'PaymentMethod' => $row[9],
            'UniqueID' => $row[10],
        ]);
    }

    /**
     * @return int
     */
    public function startRow(): int
    {
        return 3;
    }
}
