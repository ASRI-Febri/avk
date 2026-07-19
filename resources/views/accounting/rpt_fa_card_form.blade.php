@extends('layouts.report_form')

@section('form_remark')
    {{ $form_remark ?? '' }}
@endsection

@section('left_header')

@endsection

@section('content-form')

    <div class="mb-2">
        <x-select-horizontal label="Aset" id="IDX_M_Asset" :value="$IDX_M_Asset" class="select2 required" :array="$dd_asset"/>
    </div>

@endsection
