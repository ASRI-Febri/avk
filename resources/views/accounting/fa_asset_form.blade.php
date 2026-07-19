@extends('layouts.master-form-with-log')

@section('active_link')
	$('#nav-fixed-asset').addClass('mm-active');
    $('#nav-ul-fixed-asset').addClass('mm-show');
    $('#nav-li-fa-asset-create').addClass('mm-active');
@endsection

@section('right_header')
    @if($state !== 'create')
    <x-btn-create-new label="Create New" :url="$url_create" />
    @endif
@endsection

@section('content-form')

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_M_Asset" name="IDX_M_Asset" value="{{ $fields->IDX_M_Asset }}"/>

    <!-- INPUT FIELDS -->
    <x-select-horizontal label="Company" id="IDX_M_Company" :value="$fields->IDX_M_Company" class="select2 required" :array="$dd_company"/>
    <x-select-horizontal label="Cabang" id="IDX_M_Branch" :value="$fields->IDX_M_Branch" class="select2 required" :array="$dd_branch"/>
    <x-select-horizontal label="Departemen" id="IDX_M_Department" :value="$fields->IDX_M_Department" class="select2" :array="$dd_department"/>
    <x-select-horizontal label="Kategori Aset" id="IDX_M_AssetCategory" :value="$fields->IDX_M_AssetCategory" class="select2 required" :array="$dd_asset_category"/>

    <x-textbox-horizontal label="Kode Aset" id="AssetCode" :value="$fields->AssetCode" placeholder="Kosongkan untuk generate otomatis (FA/Cabang/Periode/No)" class="" />
    <x-textbox-horizontal label="Nama Aset" id="AssetName" :value="$fields->AssetName" placeholder="Nama aset" class="required" />
    <x-textarea-horizontal label="Keterangan" id="AssetDesc" :value="$fields->AssetDesc" placeholder="Merk / tipe / no seri" class="" />
    <x-textbox-horizontal label="No Referensi" id="ReferenceNo" :value="$fields->ReferenceNo" placeholder="No invoice / dokumen perolehan" class="" />

    <hr>
    <h5 class="mb-3">Perolehan &amp; Penyusutan (PSAK 16)</h5>
    <x-textbox-horizontal label="Tanggal Perolehan" id="AcquisitionDate" :value="$fields->AcquisitionDate" placeholder="Tanggal Perolehan" class="required datepicker2 mb-2" />
    <x-textbox-horizontal label="Tanggal Mulai Pakai" id="UsageStartDate" :value="$fields->UsageStartDate" placeholder="Mulai disusutkan" class="required datepicker2 mb-2" />
    <x-textbox-horizontal label="Harga Perolehan" id="AcquisitionCost" :value="$fields->AcquisitionCost" placeholder="0" class="required auto text-right" />
    <x-textbox-horizontal label="Nilai Residu" id="ResidualValue" :value="$fields->ResidualValue" placeholder="0" class="required auto text-right" />
    <x-textbox-horizontal label="Umur Manfaat (Bulan)" id="UsefulLifeMonth" :value="$fields->UsefulLifeMonth" placeholder="Contoh: 48, 96, 240" class="required" />
    <x-select-horizontal label="Metode Penyusutan" id="DeprMethod" :value="$fields->DeprMethod" class="select2 required" :array="$dd_depr_method"/>
    <x-textbox-horizontal label="Akum. Penyusutan Saldo Awal" id="OpeningAccumDepr" :value="$fields->OpeningAccumDepr" placeholder="Diisi hanya untuk migrasi aset lama" class="auto text-right" />

    <hr>
    <h5 class="mb-3">Penyusutan Fiskal (Pajak)</h5>
    <x-select-horizontal label="Kelompok Fiskal" id="FiscalGroup" :value="$fields->FiscalGroup" class="select2" :array="$dd_fiscal_group"/>
    <x-select-horizontal label="Metode Fiskal" id="FiscalDeprMethod" :value="$fields->FiscalDeprMethod" class="select2" :array="$dd_depr_method"/>

    <hr>
    <x-select-horizontal label="Status Aset" id="AssetStatus" :value="$fields->AssetStatus" class="select2 required" :array="$dd_asset_status"/>

    @if($state == 'update')
    <div class="row mb-2">
        <label class="col-sm-3 col-form-label">Akum. Penyusutan Berjalan</label>
        <div class="col-sm-9">
            <input type="text" class="form-control text-right" value="{{ number_format((float) ($fields->AccumDepr ?? 0), 2) }}" readonly disabled>
        </div>
    </div>
    <div class="row mb-2">
        <label class="col-sm-3 col-form-label">Nilai Buku</label>
        <div class="col-sm-9">
            <input type="text" class="form-control text-right" value="{{ number_format((float) ($fields->BookValue ?? 0), 2) }}" readonly disabled>
        </div>
    </div>
    @endif

    <x-checkbox-horizontal id="add-new-after-save" name="add-new-after-save" label="add new data after save ?" :value="''" checked="" />
    <br>
    <div class="row">
        <div class="col-12">
            @include('form_helper.btn_save_header')
        </div>
    </div>

@endsection
