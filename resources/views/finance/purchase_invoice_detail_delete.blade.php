@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-detail id="btn-delete-detail" label="Delete ?" :url="$url_save_modal" table="table-purchaseinvoice-detail"/>     
@endsection

@section('modal-content')

    <input type="hidden" id="item_index" name="item_index" value="{{ $item_index }}"/>
    <input type="hidden" id="state" name="state" value="{{ $state }}"/>

    <h5 class="text-danger">Delete : {{ $item_description }} ?</h5>

@endsection