@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-modal id="btn-save-modal" label="Posting" :url="$url_save_modal"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_JournalHeader" name="IDX_T_JournalHeader" value="{{ $fields->IDX_T_JournalHeader }}"/>

    <x-textbox-horizontal label="Posting By" id="PostedBy" :value="$fields->PostedBy" placeholder="" class="required readonly" />
    <x-textbox-horizontal label="Posting Date" id="PostingDate" :value="$fields->PostingDate" placeholder="Posting Date" class="required datepicker2" />          
    <x-textbox-horizontal label="Posting Notes" id="PostingNotes" :value="$fields->PostingNotes" placeholder="Keterangan" class="required" />

@endsection 