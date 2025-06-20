@extends('layouts.master-form-with-log')

@section('form-remark')
    Kode pecahan menggunakan kode P ditambah 4 angka sesuai nominal pecahan. 
    <br> 
    Contoh <code>P0100</code> untuk pecahan mata uang 100.
    <br>
    Nama pecahan dan nominal disesuaikan dengan nilai pecahan
@endsection

@section('content-form')

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_M_ValasChange" name="IDX_M_ValasChange" value="{{ $fields->IDX_M_ValasChange }}"/>

    <x-textbox-horizontal label="Kode Pecahan" id="ValasChangeID" :value="$fields->ValasChangeID" placeholder="" class="required" />
    <x-textbox-horizontal label="Nama Pecahan" id="ValasChangeName" :value="$fields->ValasChangeName" placeholder="" class="required" />
    <x-textbox-horizontal label="Nominal Pecahan" id="ValasChangeNumber" :value="$fields->ValasChangeNumber" placeholder="" class="required" />

    <div class="row"> 
        <div class="col-12 mb-3">           
            @include('form_helper.btn_save_header')
        </div>
    </div>       

@endsection 