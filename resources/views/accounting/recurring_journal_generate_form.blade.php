@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-modal id="btn-save-modal" label="Generate" :url="$url_save_modal" />
@endsection

@section('modal-content')

    <div class="alert alert-label-info">
        Semua template recurring <b>aktif</b> yang masa berlakunya mencakup periode di bawah ini
        akan digenerate jurnalnya (tanggal jurnal = akhir bulan, langsung posted).
        Template yang sudah pernah digenerate untuk periode tersebut otomatis dilewati.
    </div>

    <div class="d-grid gap-3">
        <x-select-horizontal
            label="Company"
            id="IDX_M_Company"
            :value="$fields->IDX_M_Company"
            class="select2 required"
            :array="$dd_company"/>

        <x-textbox-horizontal
            label="Periode (YYYYMM)"
            id="Period"
            :value="$fields->Period"
            placeholder="Contoh: {{ date('Ym') }}"
            class="required" />
    </div>

@endsection
