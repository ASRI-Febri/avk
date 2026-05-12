@extends('layouts.report_form')

@section('form-remark')
    {{ $form_remark ?? '' }}
@endsection

@section('left_header')

@endsection

@section('content-form')

    <div class="d-grid gap-3">
        <x-select-horizontal label="Periode HPP (YYYYMM)" id="COGSPeriod" :value="$COGSPeriod" class="required" flag="required" :array="$dd_cogs_period"/>
    </div>

@endsection
