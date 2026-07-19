@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-modal id="btn-save-modal" label="Close" :url="$url_save_modal"/>
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_PettyCashHeader" name="IDX_T_PettyCashHeader" value="{{ $fields->IDX_T_PettyCashHeader }}"/>

    <div class="d-grid gap-3">
    <x-textbox-horizontal label="Closed By" id="ClosingBy" :value="$fields->ClosingBy" placeholder="" class="required readonly" />
    <x-textbox-horizontal label="Closing Date" id="ClosingDate" :value="$fields->ClosingDate" placeholder="Closing Date" class="required datepicker2" />
    <x-textbox-horizontal label="Closing Notes" id="ClosingNotes" :value="$fields->ClosingNotes" placeholder="Keterangan" class="required" />
    </div>

@endsection
