@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-modal id="btn-save-modal" label="Generate Journal" :url="$url_save_modal" />
@endsection

@section('modal-content')

    <div class="alert alert-label-info">
        Jurnal HPP akan digenerate untuk seluruh transaksi penjualan pada periode di bawah ini.
    </div>

    <div class="d-grid gap-3">
        <x-textbox-horizontal
            label="Journal Period"
            id="JournalPeriod"
            :value="$fields->JournalPeriod"
            placeholder="YYYYMM"
            class="required readonly" />
    </div>

@endsection
