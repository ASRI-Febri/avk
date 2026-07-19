@extends('layouts.master-form-with-log')

@section('active_link')
	$('#nav-setting').addClass('mm-active');
    $('#nav-ul-setting').addClass('mm-show');
    $('#nav-li-setting-fa-category').addClass('mm-active');
@endsection

@section('right_header')
    @if($state !== 'create')
    <x-btn-create-new label="Create New" :url="$url_create" />
    @endif
@endsection

@section('content-form')

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_M_AssetCategory" name="IDX_M_AssetCategory" value="{{ $fields->IDX_M_AssetCategory }}"/>

    <!-- INPUT FIELDS -->
    <x-select-horizontal label="Company" id="IDX_M_Company" :value="$fields->IDX_M_Company" class="select2 required" :array="$dd_company"/>
    <x-textbox-horizontal label="Kode Kategori" id="CategoryCode" :value="$fields->CategoryCode" placeholder="Contoh: BLD, VHC, EQP" class="required" />
    <x-textbox-horizontal label="Nama Kategori" id="CategoryName" :value="$fields->CategoryName" placeholder="Contoh: Bangunan, Kendaraan, Peralatan" class="required" />

    <hr>
    <h5 class="mb-3">Mapping Akun (COA)</h5>
    <x-select-horizontal label="Akun Aset Tetap" id="IDX_M_COA_Asset" :value="$fields->IDX_M_COA_Asset" class="select2 required" :array="$dd_coa"/>
    <x-select-horizontal label="Akun Akumulasi Penyusutan" id="IDX_M_COA_AccumDepr" :value="$fields->IDX_M_COA_AccumDepr" class="select2 required" :array="$dd_coa"/>
    <x-select-horizontal label="Akun Beban Penyusutan" id="IDX_M_COA_DeprExpense" :value="$fields->IDX_M_COA_DeprExpense" class="select2 required" :array="$dd_coa"/>
    <x-select-horizontal label="Akun Laba Pelepasan" id="IDX_M_COA_GainDisposal" :value="$fields->IDX_M_COA_GainDisposal" class="select2" :array="$dd_coa"/>
    <x-select-horizontal label="Akun Rugi Pelepasan" id="IDX_M_COA_LossDisposal" :value="$fields->IDX_M_COA_LossDisposal" class="select2" :array="$dd_coa"/>

    <hr>
    <h5 class="mb-3">Default Penyusutan</h5>
    <x-textbox-horizontal label="Umur Manfaat (Bulan)" id="DefaultUsefulLifeMonth" :value="$fields->DefaultUsefulLifeMonth" placeholder="Contoh: 48, 96, 240" class="required" />
    <x-select-horizontal label="Metode Penyusutan" id="DefaultDeprMethod" :value="$fields->DefaultDeprMethod" class="select2 required" :array="$dd_depr_method"/>
    <x-select-horizontal label="Kelompok Fiskal (Pajak)" id="FiscalGroup" :value="$fields->FiscalGroup" class="select2" :array="$dd_fiscal_group"/>

    <x-checkbox-horizontal id="add-new-after-save" name="add-new-after-save" label="add new data after save ?" :value="''" checked="" />
    <br>
    <div class="row">
        <div class="col-12">
            @include('form_helper.btn_save_header')
        </div>
    </div>

@endsection
