@extends('layouts.master-form-with-log')

@section('active_link')
    $('#nav-fixed-asset').addClass('mm-active');
    $('#nav-ul-fixed-asset').addClass('mm-show');
    $('#nav-li-fa-mutation').addClass('mm-active');
@endsection

@section('content-form')

    <div class="alert alert-label-info">
        <span class="text-muted">
            Mutasi memindahkan posisi aset ke cabang / departemen tujuan dan mencatat riwayatnya.
            Nilai buku aset tidak berubah dan tidak ada jurnal yang dibentuk.
        </span>
    </div>

    <!-- INPUT FIELDS -->
    <x-select-horizontal label="Aset" id="IDX_M_Asset" :value="$fields->IDX_M_Asset" class="select2 required" :array="$dd_asset"/>
    <x-textbox-horizontal label="Tanggal Mutasi" id="MutationDate" :value="$fields->MutationDate" placeholder="Tanggal Mutasi" class="required datepicker2 mb-2" />
    <x-select-horizontal label="Cabang Tujuan" id="IDX_M_Branch_To" :value="$fields->IDX_M_Branch_To" class="select2 required" :array="$dd_branch"/>
    <x-select-horizontal label="Departemen Tujuan" id="IDX_M_Department_To" :value="$fields->IDX_M_Department_To" class="select2" :array="$dd_department"/>
    <x-textarea-horizontal label="Keterangan" id="MutationNotes" :value="$fields->MutationNotes" placeholder="Alasan / keterangan mutasi" class="" />

    <br>
    <div class="row">
        <div class="col-12">
            @include('form_helper.btn_save_header')
        </div>
    </div>

@endsection
