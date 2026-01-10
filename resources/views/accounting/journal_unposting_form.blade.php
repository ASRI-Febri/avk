@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-modal id="btn-save-modal" label="Un-Posting" :url="$url_save_modal"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_JournalHeader" name="IDX_T_JournalHeader" value="{{ $fields->IDX_T_JournalHeader }}"/>

    <x-textbox-horizontal label="UnPosting By" id="PostedBy" :value="$fields->PostedBy" placeholder="" class="required readonly mb-2" />
    <x-textbox-horizontal label="UnPosting Date" id="PostingDate" :value="$fields->PostingDate" placeholder="Posting Date" class="required datepicker2 mb-2" />          
    <x-textbox-horizontal label="UnPosting Notes" id="PostingNotes" :value="$fields->PostingNotes" placeholder="Keterangan" class="required mb-2" />

@endsection 