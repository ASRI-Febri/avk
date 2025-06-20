<?php

namespace App\Imports;

use Illuminate\Support\Collection;
use Maatwebsite\Excel\Concerns\WithMultipleSheets;

// COMBINE 2 IMPORT FOR 2 WORKSHEET 

class XSalesMemberImport implements WithMultipleSheets
{
    private $upload_id;

    public function __construct($upload_id)
    { 
        $this->upload_id = $upload_id;
    }

    public function sheets(): array
    {
        return [
            'IGH' => new XSalesSummaryImport($this->upload_id),
            'PenjualanMember' => new XMemberSummaryImport($this->upload_id),
        ];
    }
}
