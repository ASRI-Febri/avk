@extends('layouts.report_form')

@section('form-remark')
    {{ $form_remark ?? '' }}
@endsection

@section('left_header')

@endsection

@section('content-form')

    <div class="d-grid gap-3">
        <x-textbox-horizontal label="IDPJK" id="IDPJK" :value="$IDPJK" placeholder="IDPJK" class="required" flag="required" />

        <x-textbox-horizontal label="Tanggal Awal" id="start_date" :value="$start_date" placeholder="YYYY-MM-DD" class="readonly datepicker2 required" flag="required" />

        <x-textbox-horizontal label="Tanggal Akhir" id="end_date" :value="$end_date" placeholder="YYYY-MM-DD" class="readonly datepicker2 required" flag="required" />
    </div>

@endsection

@section('report-script')

@endsection
