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

                    @if ($errors->any())
                    <div class="alert alert-danger">
                        @foreach ($errors->all() as $error)
                        <span style="display:block;">{{ $error }}</span>
                        @endforeach
                    </div>
                    @endif

                    <form id="form-entry" name="form-entry" action="{{ $url_save_header }}" method="POST" class="needs-validation" novalidate>
                        <input type="hidden" name="_token" value="{{ csrf_token() }}" />
                        <input type="hidden" name="state" value="{{ $state }}" />

                        <div class="d-grid gap-3">
                            <div class="row">
                                <label class="col-sm-3 col-form-label text-secondary">Company</label>
                                <div class="col-sm-9">
                                    <select id="IDX_M_Company" name="IDX_M_Company" class="form-select required" required>
                                        @foreach($dd_company as $key => $val)
                                        <option value="{{ $key }}" {{ (string) $key === (string) $fields->IDX_M_Company ? 'selected' : '' }}>{{ $val }}</option>
                                        @endforeach
                                    </select>
                                </div>
                            </div>
                            <div class="row">
                                <label class="col-sm-3 col-form-label text-secondary">Periode (YYYYMM)</label>
                                <div class="col-sm-9">
                                    <input type="text" id="DeprPeriod" name="DeprPeriod"
                                           class="form-control required"
                                           value="{{ $fields->DeprPeriod ?? '' }}"
                                           placeholder="YYYYMM, contoh: {{ date('Ym') }}"
                                           maxlength="6"
                                           inputmode="numeric"
                                           pattern="\d{6}"
                                           required />
                                    <small class="text-muted">Masukkan 6 digit angka. 4 digit pertama tahun, 2 digit terakhir bulan (01-12).
                                        Hanya aset berstatus <b>Aktif</b> dengan tanggal mulai pakai &le; akhir periode yang akan disusutkan.</small>
                                </div>
                            </div>
                        </div>

                        <hr>

                        <div class="d-flex justify-content-end gap-2">
                            <a href="{{ $url_cancel }}" class="btn btn-light">Batal</a>
                            <button type="submit" id="btn-process" class="btn btn-primary">
                                <i class="fas fa-calculator me-1"></i> Proses Penyusutan
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
            $('#nav-fixed-asset').addClass('mm-active');
            $('#nav-ul-fixed-asset').addClass('mm-show');
            $('#nav-li-fa-depreciation').addClass('mm-active');

            $('#DeprPeriod').on('input', function () {
                this.value = this.value.replace(/\D/g, '').slice(0, 6);
            });

            $('#form-entry').on('submit', function (e) {
                var val = $('#DeprPeriod').val();
                if (!/^\d{6}$/.test(val)) {
                    e.preventDefault();
                    Swal.fire({
                        title: 'Format Tidak Valid',
                        html: 'Periode harus 6 angka dengan format <b>YYYYMM</b>, contoh: {{ date('Ym') }}.',
                        icon: 'warning'
                    });
                    return false;
                }
                var month = parseInt(val.substr(4, 2), 10);
                if (month < 1 || month > 12) {
                    e.preventDefault();
                    Swal.fire({
                        title: 'Bulan Tidak Valid',
                        html: 'Bulan pada periode harus antara 01 sampai 12.',
                        icon: 'warning'
                    });
                    return false;
                }

                $('#btn-process').prop('disabled', true)
                    .html('<i class="fa fa-spinner fa-spin me-1"></i> Memproses...');
                showPageLoader('Memproses penyusutan aset...');
            });
        });
    </script>
@endsection
