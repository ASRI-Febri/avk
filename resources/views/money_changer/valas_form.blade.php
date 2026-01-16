@extends('layouts.master-form-with-log')

@section('active_link')
	$('#nav-setting').addClass('mm-active');
    $('#nav-ul-setting').addClass('mm-show');
    $('#nav-li-setting-input-valas').addClass('mm-active');
@endsection

@section('form-remark')
    SKU (Stock Keeping Unit) dibuat otomatis untuk keperluan perhitungan persediaan. 
    <br> 
    Contoh <code>USD-100</code> untuk mata uang USD pecahan mata uang 100.
    <br>
    Nama valas menggunakan format Mata Uang + Pecahan
@endsection

@section('content-form')
    
    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_M_Valas" name="IDX_M_Valas" value="{{ $fields->IDX_M_Valas }}"/>

    <x-textbox-horizontal label="Effective Date" id="EffectiveDate" :value="$fields->EffectiveDate" placeholder="" class="required datepicker2" />

    @if($state == 'create')
        <x-textbox-horizontal label="SKU" id="ValasSKU" :value="$fields->ValasSKU" placeholder="(Auto)" class="required readonly" />
        <x-select-horizontal label="Mata Uang" id="IDX_M_Currency" :value="$fields->IDX_M_Currency" class="required" :array="$dd_currency"/>
        <x-select-horizontal label="Nilai Pecahan" id="IDX_M_ValasChange" :value="$fields->IDX_M_ValasChange" class="required" :array="$dd_valas_change"/>
        <x-textbox-horizontal label="Nama Valas" id="ValasName" :value="$fields->ValasName" placeholder="" class="required" />
    @else 
            <hr>
            <x-textbox-horizontal label="SKU" id="ValasSKU" :value="$fields->ValasSKU" placeholder="" class="required readonly" />
            <x-select-horizontal-disabled label="Mata Uang" id="IDX_M_Currency" :value="$fields->IDX_M_Currency" class="required" :array="$dd_currency" />
            <x-select-horizontal-disabled label="Nilai Pecahan" id="IDX_M_ValasChange" :value="$fields->IDX_M_ValasChange" class="required" :array="$dd_valas_change"/>
            <x-textbox-horizontal label="Nama Valas" id="ValasName" :value="$fields->ValasName" placeholder="" class="required" />
            <hr>
        <input type="hidden" id="IDX_M_Currency" name="IDX_M_Currency" value="{{ $fields->IDX_M_Currency }}"/>
        <input type="hidden" id="IDX_M_ValasChange" name="IDX_M_ValasChange" value="{{ $fields->IDX_M_ValasChange }}"/>
    @endif 

    <x-textbox-horizontal label="Nilai Beli" id="BuyValue" :value="$fields->BuyValue" placeholder="" class="required auto" />
    <x-textbox-horizontal label="Nilai Jual" id="SellValue" :value="$fields->SellValue" placeholder="" class="required auto" />                        

    <div class="row"> 
        <div class="col-12 mb-3">           
            @include('form_helper.btn_save_header')
        </div>
    </div>

@endsection 