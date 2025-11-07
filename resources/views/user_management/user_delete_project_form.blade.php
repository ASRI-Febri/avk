@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-detail id="btn-save-detail" label="Delete ?" :url="$url_save_modal" table="table-project"/>     
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_M_UserProject" name="IDX_M_UserProject" value="{{ $IDX_M_UserProject }}"/>
    <input type="hidden" id="state" name="state" value="{{ $state }}"/>

    <h5 class="text-danger">{{ $message }}</h5>

@endsection