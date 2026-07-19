@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-modal id="btn-save-modal" label="Generate Journal" :url="$url_save_modal" />
@endsection

@section('modal-content')

    <div class="alert alert-label-info">
        Jurnal penyusutan (Debet Beban Penyusutan, Kredit Akumulasi Penyusutan per kategori aset)
        akan digenerate ke General Ledger untuk periode di bawah ini.
    </div>

    <input type="hidden" id="IDX_M_Company" name="IDX_M_Company" value="{{ $fields->IDX_M_Company }}"/>

    <div class="d-grid gap-3">
        <x-textbox-horizontal
            label="Periode"
            id="DeprPeriod"
            :value="$fields->DeprPeriod"
            placeholder="YYYYMM"
            class="required readonly" />

        <x-select-horizontal
            label="Cabang Pembukuan"
            id="IDX_M_Branch"
            :value="$fields->IDX_M_Branch"
            class="select2 required"
            :array="$dd_branch"/>
    </div>

@endsection
