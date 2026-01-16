@extends('layouts.report_form')

@section('form_remark')
    {{ $form_remark ?? '' }}
@endsection 

@section('left_header')    
    
@endsection

@section('content-form')


    <div class="mb-2">
        <x-select-horizontal label="Company" id="IDX_M_Company" :value="$IDX_M_Company" class="required" :array="$dd_company"/>
    </div>

    <div class="mb-2">
        <x-select-horizontal label="Profit Center" id="IDX_M_Branch" :value="$IDX_M_Branch" class="required" :array="$dd_branch"/>
    </div>

    <div class="mb-2">
        <x-select-horizontal label="Project (abaikan jika ingin all project)" id="IDX_M_Project" :value="$IDX_M_Project" class="" :array="$dd_project"/>
    </div>

    <x-textbox-horizontal label="Period (YYYYMM)" id="Period" :value="$Period" placeholder="(YYYYMM)" class="required mb-2" />    

@endsection