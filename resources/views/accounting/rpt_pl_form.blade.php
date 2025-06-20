@extends('layouts.report_form')

@section('form_remark')
    {{ $form_remark ?? '' }}
@endsection 

@section('left_header')    
    
@endsection

@section('content_form')

    <x-select-horizontal label="Company" id="IDX_M_Company" :value="$IDX_M_Company" class="required" :array="$dd_company"/>
    <x-select-horizontal label="Branch" id="IDX_M_Branch" :value="$IDX_M_Branch" class="required" :array="$dd_branch"/>
    <x-select-horizontal label="Project (abaikan jika ingin all project)" id="IDX_M_Project" :value="$IDX_M_Project" class="" :array="$dd_project"/>
    <x-textbox-horizontal label="Period (YYYYMM)" id="Period" :value="$Period" placeholder="(YYYYMM)" class="required" />    

@endsection