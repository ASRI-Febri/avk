@extends('layouts.report_form')

@section('form-remark')
    {{ $form_remark ?? '' }}
@endsection

@section('left_header')

@endsection

@section('content-form')

    <div class="d-grid gap-3">
        <x-select-horizontal label="Bulan" id="PeriodMonth" :value="$PeriodMonth" class="required" :array="$dd_month" flag="required" />

        <x-select-horizontal label="Tahun" id="PeriodYear" :value="$PeriodYear" class="required" :array="$dd_year" flag="required" />
    </div>

@endsection

@section('report-script')

@endsection
