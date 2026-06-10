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
                    <div class="card-addon">
                        <a href="{{ $url_cancel }}" class="btn btn-secondary">
                            <i class="fas fa-arrow-left me-1"></i> Kembali
                        </a>
                    </div>
                </div>

                <div class="card-body">
                    <div class="alert alert-label-info">
                        <span class="text-muted">{{ $form_remark }}</span>
                    </div>

                    <form id="form-entry" name="form-entry" action="{{ $url_save_header }}" method="POST" class="needs-validation" novalidate>
                        <input type="hidden" name="_token" value="{{ csrf_token() }}" />
                        <input type="hidden" name="state" value="{{ $state }}" />

                        <div class="d-grid gap-3">
                            <div class="row">
                                <label class="col-sm-3 col-form-label text-secondary">COGS Period (YYYYMM)</label>
                                <div class="col-sm-9">
                                    <input type="text" id="COGSPeriod" name="COGSPeriod"
                                           class="form-control required"
                                           value="{{ $fields->COGSPeriod ?? '' }}"
                                           placeholder="YYYYMM, contoh: 202605"
                                           maxlength="6"
                                           inputmode="numeric"
                                           pattern="\d{6}"
                                           required />
                                    <small class="text-muted">Masukkan 6 digit angka. 4 digit pertama tahun, 2 digit terakhir bulan (01-12).</small>
                                </div>
                            </div>
                        </div>

                        <hr>

                        <div class="d-flex justify-content-end gap-2">
                            <a href="{{ $url_cancel }}" class="btn btn-light">Batal</a>
                            <button type="submit" id="btn-process" class="btn btn-primary">
                                <i class="fas fa-calculator me-1"></i> Proses Perhitungan HPP
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
            $('#nav-li-cogs-calculation').addClass('mm-active');

            $('#COGSPeriod').on('input', function () {
                this.value = this.value.replace(/\D/g, '').slice(0, 6);
            });

            $('#form-entry').on('submit', function (e) {
                var val = $('#COGSPeriod').val();
                if (!/^\d{6}$/.test(val)) {
                    e.preventDefault();
                    Swal.fire({
                        title: 'Format Tidak Valid',
                        html: 'COGS Period harus 6 angka dengan format <b>YYYYMM</b>, contoh: 202605.',
                        icon: 'warning'
                    });
                    return false;
                }
                var month = parseInt(val.substr(4, 2), 10);
                if (month < 1 || month > 12) {
                    e.preventDefault();
                    Swal.fire({
                        title: 'Bulan Tidak Valid',
                        html: 'Bulan pada COGS Period harus antara 01 sampai 12.',
                        icon: 'warning'
                    });
                    return false;
                }

                $('#btn-process').prop('disabled', true)
                    .html('<i class="fa fa-spinner fa-spin me-1"></i> Memproses...');
            });
        });
    </script>
@endsection
