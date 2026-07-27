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

                <div class="card-body">
                    <div class="alert alert-label-info">
                        <span class="text-muted">{{ $form_remark }}</span>
                    </div>

                    <form id="form-entry" name="form-entry" action="{{ $url_preview }}" method="POST" class="needs-validation" novalidate
                        data-loader="Mencari transaksi tunai periode ini...">
                        <input type="hidden" name="_token" value="{{ csrf_token() }}" />
                        <input type="hidden" name="state" value="{{ $state }}" />

                        <div class="d-grid gap-3">
                            <div class="form-group row">
                                <label class="col-sm-3 col-form-label text-secondary">Bulan</label>
                                <div class="col-sm-9">
                                    <select id="PeriodMonth" name="PeriodMonth" class="form-control required" required>
                                        @foreach($dd_month as $key => $value)
                                            <option value="{{ $key }}" {{ $PeriodMonth == $key ? 'selected' : '' }}>{{ $value }}</option>
                                        @endforeach
                                    </select>
                                </div>
                            </div>
                            <div class="form-group row">
                                <label class="col-sm-3 col-form-label text-secondary">Tahun</label>
                                <div class="col-sm-9">
                                    <select id="PeriodYear" name="PeriodYear" class="form-control required" required>
                                        @foreach($dd_year as $key => $value)
                                            <option value="{{ $key }}" {{ $PeriodYear == $key ? 'selected' : '' }}>{{ $value }}</option>
                                        @endforeach
                                    </select>
                                </div>
                            </div>
                        </div>

                        <hr>

                        <div class="d-flex justify-content-end gap-2">
                            <button type="submit" id="btn-preview" class="btn btn-primary" data-loader-text="Memuat...">
                                <i class="fas fa-search me-1"></i> Preview Data
                            </button>
                        </div>
                    </form>
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
            $('#nav-li-ltkt').addClass('mm-active');
        });
    </script>
@endsection
