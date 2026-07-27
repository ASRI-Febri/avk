@extends('layouts.master')

@section('topbar-title')
    {{ $form_title }}
@endsection

@section('title')
    {{ $form_title }}
@endsection

@section('content')

    <div class="row">
        <div class="col-xl-12 col-md-12 col-sm-12">
            <div class="card">
                <div class="card-header card-header-bordered">
                    <h3 class="card-title">{{ $form_sub_title }} - Periode {{ $PeriodDesc }}</h3>
                    <div class="card-addon">
                        <a href="{{ $url_cancel }}" class="btn btn-secondary">
                            <i class="fas fa-arrow-left me-1"></i> Ganti Periode
                        </a>
                    </div>
                </div>

                <div class="card-body">
                    <div class="alert alert-label-info">
                        <span class="text-muted">
                            Seluruh transaksi penjualan periode {{ $PeriodDesc }} (tidak ada batasan nominal).
                            Centang transaksi yang ditetapkan sebagai <b>TKM (Transaksi Keuangan Mencurigakan)</b>
                            dan isi indikatornya, lalu klik <b>Proses Data</b>. Transaksi yang sudah pernah
                            ditetapkan sebagai TKM otomatis tercentang. Batas waktu lapor 3 hari sejak
                            tanggal penetapan TKM.
                        </span>
                    </div>

                    <form id="form-process" name="form-process" action="{{ $url_process }}" method="POST">
                        <input type="hidden" name="_token" value="{{ csrf_token() }}" />
                        <input type="hidden" name="LTKMPeriod" value="{{ $LTKMPeriod }}" />

                        <div class="form-group row mb-3">
                            <label class="col-sm-3 col-form-label text-secondary">Tanggal Penetapan TKM</label>
                            <div class="col-sm-3">
                                <input type="date" id="TKMDate" name="TKMDate" class="form-control required" value="{{ $TKMDate }}" required />
                            </div>
                        </div>

                        <div class="table-responsive">
                            <table class="table table-bordered table-striped table-sm">
                                <thead>
                                    <tr>
                                        <th class="text-center">
                                            <input type="checkbox" id="check-all" title="Pilih Semua" />
                                        </th>
                                        <th>#</th>
                                        <th>Tanggal</th>
                                        <th>No Transaksi</th>
                                        <th>Kode Nasabah</th>
                                        <th>Nama Nasabah</th>
                                        <th class="text-center">DTTOT</th>
                                        <th class="text-center">Total Penjualan</th>
                                        <th class="text-center">Pembayaran Tunai</th>
                                        <th class="text-center">Total Tunai Harian</th>
                                        <th style="min-width:250px;">Indikator / Alasan TKM</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @php $no = 0; @endphp
                                    @if($records)
                                    @foreach($records as $row)
                                        @php
                                            $no++;
                                            $checked = $row->InLTKM == 1;
                                            $indicator = $row->TKMIndicator;

                                            if (!$checked && trim($row->IsDTTOT) == 'Y') {
                                                $checked = true;
                                                $indicator = 'Nasabah terdaftar dalam DTTOT';
                                            }
                                        @endphp
                                        <tr class="{{ trim($row->IsDTTOT) == 'Y' ? 'table-danger' : '' }}">
                                            <td class="text-center">
                                                <input type="checkbox" class="check-tkm" name="selected[]"
                                                    value="{{ $row->IDX_T_SalesOrder }}" {{ $checked ? 'checked' : '' }} />
                                            </td>
                                            <td>{{ $no }}</td>
                                            <td>{{ date('d M Y', strtotime($row->TransactionDate)) }}</td>
                                            <td>
                                                <a href="{{ url('mc-sales-order/update') . '/' . $row->IDX_T_SalesOrder }}" target="_blank">{{ $row->SONumber }}</a>
                                            </td>
                                            <td>{{ $row->PartnerID }}</td>
                                            <td>{{ $row->PartnerName }}</td>
                                            <td class="text-center">{{ trim($row->IsDTTOT) == 'Y' ? 'Y' : '' }}</td>
                                            <td class="text-end">{{ number_format($row->TotalSalesAmount,2,'.',',') }}</td>
                                            <td class="text-end">{{ number_format($row->PaymentCashAmount,2,'.',',') }}</td>
                                            <td class="text-end">{{ number_format($row->DailyCashAmount,2,'.',',') }}</td>
                                            <td>
                                                <input type="text" class="form-control form-control-sm"
                                                    name="TKMIndicator[{{ $row->IDX_T_SalesOrder }}]"
                                                    value="{{ $indicator }}" maxlength="1000"
                                                    placeholder="Indikator / alasan mencurigakan" />
                                            </td>
                                        </tr>
                                    @endforeach
                                    @endif

                                    @if($no == 0)
                                        <tr>
                                            <td colspan="11" class="text-center text-muted">
                                                Tidak ada transaksi penjualan pada periode {{ $PeriodDesc }}.
                                            </td>
                                        </tr>
                                    @endif
                                </tbody>
                            </table>
                        </div>

                        <hr>

                        <div class="d-flex justify-content-end gap-2">
                            <a href="{{ $url_cancel }}" class="btn btn-light">Batal</a>
                            <button type="submit" id="btn-process" class="btn btn-primary" {{ $no == 0 ? 'disabled' : '' }}>
                                <i class="fas fa-database me-1"></i> Proses Data
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
            $('#nav-li-ltkm').addClass('mm-active');

            $('#check-all').on('change', function () {
                $('.check-tkm').prop('checked', $(this).is(':checked'));
            });

            $('#form-process').on('submit', function (e) {
                e.preventDefault();
                var form = this;
                var total = $('.check-tkm:checked').length;

                var message = total > 0
                    ? 'Sebanyak <b>' + total + '</b> transaksi akan ditetapkan sebagai TKM periode <b>{{ $PeriodDesc }}</b>.'
                    : 'Tidak ada transaksi yang dicentang. Seluruh data LTKM periode <b>{{ $PeriodDesc }}</b> akan <b>dihapus</b>.';

                Swal.fire({
                    title: 'Proses Data LTKM?',
                    html: message + '<br>Data LTKM lama pada periode yang sama akan diganti.',
                    icon: total > 0 ? 'question' : 'warning',
                    showCancelButton: true,
                    confirmButtonText: 'Ya, Proses',
                    cancelButtonText: 'Batal'
                }).then(function (result) {
                    if (result.isConfirmed) {
                        $('#btn-process').prop('disabled', true)
                            .html('<i class="fa fa-spinner fa-spin me-1"></i> Memproses...');
                        showPageLoader('Memproses data LTKM...');
                        form.submit();
                    }
                });
            });
        });
    </script>
@endsection
