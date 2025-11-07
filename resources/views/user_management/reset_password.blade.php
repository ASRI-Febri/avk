@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-modal id="btn-save-modal" label="Reset Password" :url="$url_save_modal"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_M_User" name="IDX_M_User" value="{{ $IDX_M_User }}"/>
    <input type="hidden" id="UserID" name="UserID" value="{{ $UserID }}"/>
    <input type="hidden" id="state" name="state" value="{{ $state }}"/>

    <p class="text-danger">Password akan direset sesuai dengan User ID</p>
    <br>

    <h5 class="text-danger">{{ $message }}</h5>

@endsection 