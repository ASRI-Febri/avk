@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-modal id="btn-save-modal" label="Proses Closing Harian" :url="$url_save_modal"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_OpenCloseDaily" name="IDX_T_OpenCloseDaily" value="{{ $fields->IDX_T_OpenCloseDaily }}"/>

    <div class="d-grid gap-3">
        <x-textbox-horizontal label="Tanggal" id="TransactionDate" :value="$fields->TransactionDate" placeholder="Approval Date" class="required datepicker2" />          
        <x-textbox-horizontal label="Notes" id="Notes" :value="$fields->Notes" placeholder="Keterangan" class="required" />
    </div>

@endsection 