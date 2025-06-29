@extends('layouts.report_form')

@section('form-remark')
    {{ $form_remark ?? '' }}
@endsection 

@section('left_header')    
    
@endsection

@section('content-form')
    
    <div class="d-grid gap-3">
        <x-select-horizontal label="Cabang" id="IDX_M_Branch" :value="$fields->IDX_M_Branch" class="required" :array="$dd_branch" flag="required" />
        <x-select-horizontal label="Jenis Transaksi" id="IDX_M_TransactionType" :value="$IDX_M_TransactionType" class="" :array="$dd_transaction_type" flag="" />
            {{-- <x-lookup-horizontal label="Vendor" id="PartnerDesc" :value="$fields->PartnerDesc" class="" button="btn-find-vendor"/>  --}}

        <x-select-horizontal label="Mata Uang (Opsional)" id="IDX_M_Currency" :value="$IDX_M_Currency" class="required" :array="$dd_currency"/>

        <x-select-horizontal label="Kode Valas (Opsional)" id="IDX_M_Valas" :value="$IDX_M_Valas" class="required" :array="$dd_valas"/>


        <x-textbox-horizontal label="Tanggal Awal" id="start_date" :value="$start_date" placeholder="YYYY-MM-DD" class="readonly datepicker2 required" flag="required" />

        <x-textbox-horizontal label="Tanggal Akhir" id="end_date" :value="$end_date" placeholder="YYYY-MM-DD" class="readonly datepicker2 required" flag="required" />
    </div>
   

@endsection