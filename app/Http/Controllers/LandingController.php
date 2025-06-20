<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\MyController;

// MODEL
use App\Models\General\Partner;
use App\Models\Finance\SalesInvoice;
use App\Models\Finance\PurchaseInvoice;

class LandingController extends Controller
{  
    // =========================================================================================
    // CONSTRUCTOR
    // =========================================================================================
    public function __construct(Request $request)
    {   
        //parent::__construct($request);
    }

    public function index()
    {
        return view('landing_page');
    }

}