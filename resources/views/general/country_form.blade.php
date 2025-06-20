@extends('layouts.master-form-with-log')

@section('form-remark')
    Data negara-negara untuk proses penjualan valuta asing
@endsection

@section('content-form')

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_M_Country" name="IDX_M_Country" value="{{ $fields->IDX_M_Country }}"/>

    <x-textbox-horizontal label="Kode Negara" id="CountryID" :value="$fields->CountryID" placeholder="" class="required" />
    <x-textbox-horizontal label="Nama Negara" id="CountryName" :value="$fields->CountryName" placeholder="" class="required" />                        

    <div class="row"> 
        <div class="col-12 mb-3">           
            @include('form_helper.btn_save_header')
        </div>
    </div>

@endsection 