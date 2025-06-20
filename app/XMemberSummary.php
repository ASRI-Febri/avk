<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

/*
    Model untuk table X_SalesSummary_Quality yang digunakan untuk menyimpan
    data hasil upload excel dari aplikasi Ezitama
*/

class XMemberSummary extends Model
{
    protected $table = "X_MemberSummary_Quality";
    protected $guarded = ['IDX_X_MemberSummary_Quality'];
    protected $primaryKey = 'IDX_X_MemberSummary_Quality'; 

    public $timestamps = false;
}
