@extends('layouts.form')

@section('right_header') 
    
@endsection

@section('content_form')

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_M_User" name="IDX_M_User" value="{{ $fields->IDX_M_User }}"/>

    <div class="form-group row">
        <label class="col-sm-3 col-form-label text-secondary">Old Password</label>
        <div class="col-sm-9">
            <input type="password" id="PrevPassword" name="PrevPassword" class="form-control required" placeholder="" value="">
        </div>
    </div>
    <hr>
    <div class="form-group row">
        <label class="col-sm-3 col-form-label text-secondary">New Password</label>
        <div class="col-sm-9">
            <input type="password" id="NewPassword" name="NewPassword" class="form-control required" placeholder="" value="">
        </div>
    </div>
    <div class="form-group row">
        <label class="col-sm-3 col-form-label text-secondary">Re-type New Password</label>
        <div class="col-sm-9">
            <input type="password" id="NewPasswordConfirm" name="NewPasswordConfirm" class="form-control required" placeholder="" value="">
        </div>
    </div>

    @include('form_helper.btn_save_header')

@endsection