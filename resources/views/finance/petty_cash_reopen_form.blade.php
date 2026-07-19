@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-modal id="btn-save-modal" label="Reopen" :url="$url_save_modal"/>
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_PettyCashHeader" name="IDX_T_PettyCashHeader" value="{{ $fields->IDX_T_PettyCashHeader }}"/>

    <div class="d-grid gap-3">
    <x-textbox-horizontal label="Reopened By" id="ClosingBy" :value="$fields->ClosingBy" placeholder="" class="required readonly" />
    <x-textbox-horizontal label="Reason" id="ClosingNotes" :value="$fields->ClosingNotes" placeholder="Alasan reopen" class="required" />
    </div>

@endsection
