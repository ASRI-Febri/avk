@extends('layouts.master')

@section('topbar-title')
    {{ $form_title }}
@endsection

@section('title')
    {{ $form_title }}
@endsection

@section('content')

    <div class="row">
        <div class="col-xl-8 col-md-10 col-sm-12">
            <div class="card">
                <div class="card-header card-header-bordered">
                    <h3 class="card-title">{{ $form_sub_title }}</h3>
                </div>
                <div class="card-body text-center">

                    <div class="my-4">
                        <i class="fas fa-check-circle text-success" style="font-size: 64px;"></i>
                    </div>

                    <h4 class="mb-2">Proses Perhitungan HPP Berhasil</h4>
                    <p class="text-muted">
                        Perhitungan HPP untuk periode
                        <b>{{ $PeriodDesc ?: $COGSPeriod }}</b>
                        ({{ $COGSPeriod }}) telah selesai diproses.
                    </p>

                    <hr>

                    <div class="d-flex justify-content-center gap-2 mt-3">
                        <a href="{{ $url_back }}" class="btn btn-light">
                            <i class="fas fa-arrow-left me-1"></i> Kembali ke Daftar
                        </a>
                        <a href="{{ $url_report }}" class="btn btn-info">
                            <i class="fas fa-file-alt me-1"></i> Lihat Laporan Perhitungan HPP
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

@endsection

@section('script')
    <script>
        $(document).ready(function () {
            $('#nav-transaction').addClass('mm-active');
            $('#nav-ul-transaction').addClass('mm-show');
            $('#nav-li-cogs-calculation').addClass('mm-active');
        });
    </script>
@endsection
