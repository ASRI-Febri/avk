<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class TestUpload extends Model
{
    protected $table = "X_TestUpload";
    protected $guarded = ['IDX_Test'];
    protected $primaryKey = 'IDX_Test'; 

    public $timestamps = false;
}
