@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-detail id="btn-save-detail" :label="$submit_title" :url="$url_save_modal" table="table-role"/>     
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_M_GroupForm" name="IDX_M_GroupForm" value="{{ $IDX_M_GroupForm }}"/>
    <input type="hidden" id="state" name="state" value="{{ $state }}"/>

    <h5 class="text-danger">{{ $message }}</h5>

@endsection