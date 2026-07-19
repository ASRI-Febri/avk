@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-modal id="btn-save-modal" label="Batalkan Perhitungan" :url="$url_save_modal" />
@endsection

@section('modal-content')

    <div class="alert alert-label-warning">
        Perhitungan penyusutan periode di bawah ini akan <b>dibatalkan</b> dan dapat dihitung ulang.
        Pembatalan hanya bisa dilakukan bila jurnal belum digenerate.
    </div>

    <input type="hidden" id="IDX_M_Company" name="IDX_M_Company" value="{{ $fields->IDX_M_Company }}"/>

    <div class="d-grid gap-3">
        <x-textbox-horizontal
            label="Periode"
            id="DeprPeriod"
            :value="$fields->DeprPeriod"
            placeholder="YYYYMM"
            class="required readonly" />
    </div>

@endsection
