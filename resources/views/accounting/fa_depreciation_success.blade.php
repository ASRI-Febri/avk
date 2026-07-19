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

                    <h4 class="mb-2">Proses Penyusutan Berhasil</h4>
                    <p class="text-muted">
                        Penyusutan aset tetap untuk periode
                        <b>{{ $PeriodDesc ?: $DeprPeriod }}</b>
                        ({{ $DeprPeriod }}) telah selesai dihitung.
                        Lanjutkan dengan <b>Generate Journal</b> dari daftar periode penyusutan
                        agar beban penyusutan tercatat di General Ledger.
                    </p>

                    <hr>

                    <div class="d-flex justify-content-center gap-2 mt-3">
                        <a href="{{ $url_back }}" class="btn btn-primary">
                            <i class="fas fa-arrow-left me-1"></i> Kembali ke Daftar Periode
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
            $('#nav-fixed-asset').addClass('mm-active');
            $('#nav-ul-fixed-asset').addClass('mm-show');
            $('#nav-li-fa-depreciation').addClass('mm-active');
        });
    </script>
@endsection
