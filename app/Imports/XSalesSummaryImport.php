<?php

namespace App\Imports;

use App\XSalesSummary;
use Maatwebsite\Excel\Concerns\ToModel;
use Maatwebsite\Excel\Concerns\WithStartRow;
//use Maatwebsite\Excel\Concerns\WithHeadingRow;

class XSalesSummaryImport implements ToModel, WithStartRow
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
        return new XSalesSummary([
            'UploadID' => $this->upload_id,
            'CompanyID' => $row[0],
            'CompanyName' => $row[1],
            'LocationID' => $row[2],
            'LocationName' => $row[3],

            'SalesDate' => date('Y-m-d', strtotime($row[4])),
            'VehicleType' => $row[5],
            'VehicleQty' => $row[6],

            'CasualQty_System' => $row[7],
            'CasualAmount_System' => (double) str_replace(',', '', $row[8]),

            'MemberQty_System' => $row[9],
            'MemberAmount_System' => (double) str_replace(',', '', $row[10]),

            'CasualQty_Manual' => $row[11],
            'CasualAmount_Manual' => (double) str_replace(',', '', $row[12]),

            'DendaAmount' => (double) str_replace(',', '', $row[13]),

            'CashAmount' => (double) str_replace(',', '', $row[15]),
            'EMoneyAmount' => (double) str_replace(',', '', $row[16]),
            'FlazzAmount' => (double) str_replace(',', '', $row[17]),

            'BrizziAmount' => (double) str_replace(',', '', $row[18]),
            'TapcashAmount' => (double) str_replace(',', '', $row[19]),
            'QRISAmount' => (double) str_replace(',', '', $row[20]),

            'VoucherAmount' => (double) str_replace(',', '', $row[22]),
            'OtherAmount' => (double) str_replace(',', '', $row[23]),
            'UniqueID' => $row[25],            
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
