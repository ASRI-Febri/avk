@extends('layouts.report_form')

@section('form-remark')
    {{ $form_remark ?? '' }}
@endsection

@section('left_header')

@endsection

@section('content-form')

    <div class="d-grid gap-3">
        <x-select-horizontal label="Periode" id="Period" :value="$Period" class="required" flag="required" :array="$dd_period"/>
    </div>

    <small class="text-muted d-block mt-3">
        Periode yang tersedia adalah periode yang sudah diproses di Perhitungan HPP.
        Jalankan ulang Perhitungan HPP bila ada transaksi yang berubah agar rekap ini ikut terbarui.
    </small>

@endsection
