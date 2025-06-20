<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

/*
    Model untuk table X_SalesSummary_Quality yang digunakan untuk menyimpan
    data hasil upload excel dari aplikasi Ezitama
*/

class XSalesSummary extends Model
{
    protected $table = "X_SalesSummary_Quality";
    protected $guarded = ['IDX_X_SalesSummary_Quality'];
    protected $primaryKey = 'IDX_X_SalesSummary_Quality'; 

    public $timestamps = false;
}
