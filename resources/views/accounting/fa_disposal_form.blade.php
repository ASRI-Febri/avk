@extends('layouts.master-form-with-log')

@section('active_link')
    $('#nav-fixed-asset').addClass('mm-active');
    $('#nav-ul-fixed-asset').addClass('mm-show');
    $('#nav-li-fa-disposal').addClass('mm-active');
@endsection

@section('content-form')

    <div class="alert alert-label-warning">
        <span class="text-muted">
            Pelepasan mengeluarkan aset dari pembukuan (PSAK 16): harga perolehan dan akumulasi
            penyusutan dikeluarkan, laba/rugi pelepasan dijurnal otomatis, dan aset berhenti
            disusutkan. <b>Proses ini tidak dapat dibatalkan dari layar ini.</b>
        </span>
    </div>

    @if(!empty($asset_info))
    <div class="alert alert-label-info">
        <span>
            <b>{{ trim($asset_info->AssetCode) }} — {{ trim($asset_info->AssetName) }}</b><br>
            Harga Perolehan: <b>{{ number_format((float) $asset_info->AcquisitionCost, 2) }}</b> &nbsp;·&nbsp;
            Akum. Penyusutan: <b>{{ number_format((float) $asset_info->AccumDepr, 2) }}</b> &nbsp;·&nbsp;
            Nilai Buku: <b>{{ number_format((float) $asset_info->BookValue, 2) }}</b>
        </span>
    </div>
    @endif

    <!-- INPUT FIELDS -->
    <x-select-horizontal label="Aset" id="IDX_M_Asset" :value="$fields->IDX_M_Asset" class="select2 required" :array="$dd_asset"/>
    <x-textbox-horizontal label="Tanggal Pelepasan" id="DisposalDate" :value="$fields->DisposalDate" placeholder="Tanggal Pelepasan" class="required datepicker2 mb-2" />
    <x-select-horizontal label="Tipe Pelepasan" id="DisposalType" :value="$fields->DisposalType" class="select2 required" :array="$dd_disposal_type"/>

    <hr>
    <h5 class="mb-3">Khusus Tipe Dijual</h5>
    <x-textbox-horizontal label="Harga Jual" id="DisposalProceed" :value="$fields->DisposalProceed" placeholder="0" class="auto text-right" />
    <x-select-horizontal label="Akun Penerima (Kas/Bank)" id="IDX_M_COA_Proceed" :value="$fields->IDX_M_COA_Proceed" class="select2" :array="$dd_coa"/>

    <hr>
    <x-textarea-horizontal label="Keterangan" id="DisposalNotes" :value="$fields->DisposalNotes" placeholder="Alasan / keterangan pelepasan" class="" />

    <br>
    <div class="row">
        <div class="col-12">
            @include('form_helper.btn_save_header')
        </div>
    </div>

@endsection
