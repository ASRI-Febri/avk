@extends('layouts.report_form')

@section('form-remark')
    {{ $form_remark ?? '' }}
@endsection 

@section('left_header')    
    
@endsection

@section('content-form')
    
    {{-- <input type="hidden" id="IDX_M_Branch" name="IDX_M_Branch" value="{{ $IDX_M_Branch }}"/>
    <input type="hidden" id="CurrencyName" name="CurrencyName" value=""/>
    <input type="hidden" id="ValasName" name="ValasName" value=""/> --}}

    <div class="d-grid gap-3">
        <x-textbox-horizontal label="Periode (YYYYMM)" id="Period" :value="$Period" placeholder="YYYMM" class="readonly required" flag="required" />
    </div>
   
@endsection

