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
                            Preview transaksi penjualan dengan total pembayaran tunai per nasabah per hari
                            Rp 500.000.000 ke atas. Periksa data di bawah ini, kemudian klik <b>Proses Data</b>
                            untuk menyimpan ke tabel LTKT. Batas waktu lapor 14 hari kerja sejak tanggal transaksi.
                        </span>
                    </div>

                    @if(($processed_rows ?? 0) > 0)
                        <div class="alert alert-warning">
                            Periode ini sudah pernah diproses ({{ $processed_rows }} baris tersimpan).
                            Proses ulang akan <b>menghapus dan mengganti</b> data LTKT periode {{ $PeriodDesc }}.
                        </div>
                    @endif

                    <div class="table-responsive">
                        <table class="table table-bordered table-striped table-sm">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Tanggal</th>
                                    <th>No Transaksi</th>
                                    <th>Kode Nasabah</th>
                                    <th>Nama Nasabah</th>
                                    <th>No KTP</th>
                                    <th class="text-center">Total Penjualan</th>
                                    <th class="text-center">Pembayaran Tunai</th>
                                    <th class="text-center">Total Tunai Harian</th>
                                </tr>
                            </thead>
                            <tbody>
                                @php $no = 0; @endphp
                                @if($records)
                                @foreach($records as $row)
                                    @php $no++; @endphp
                                    <tr>
                                        <td>{{ $no }}</td>
                                        <td>{{ date('d M Y', strtotime($row->TransactionDate)) }}</td>
                                        <td>
                                            <a href="{{ url('mc-sales-order/update') . '/' . $row->IDX_T_SalesOrder }}" target="_blank">{{ $row->SONumber }}</a>
                                        </td>
                                        <td>{{ $row->PartnerID }}</td>
                                        <td>{{ $row->PartnerName }}</td>
                                        <td>{{ $row->SingleIdentityNumber }}</td>
                                        <td class="text-end">{{ number_format($row->TotalSalesAmount,2,'.',',') }}</td>
                                        <td class="text-end">{{ number_format($row->PaymentCashAmount,2,'.',',') }}</td>
                                        <td class="text-end">{{ number_format($row->DailyCashAmount,2,'.',',') }}</td>
                                    </tr>
                                @endforeach
                                @endif

                                @if($no == 0)
                                    <tr>
                                        <td colspan="9" class="text-center text-muted">
                                            Tidak ada transaksi yang memenuhi kriteria LTKT pada periode {{ $PeriodDesc }}.
                                        </td>
                                    </tr>
                                @endif
                            </tbody>
                        </table>
                    </div>

                    <hr>

                    <form id="form-process" name="form-process" action="{{ $url_process }}" method="POST">
                        <input type="hidden" name="_token" value="{{ csrf_token() }}" />
                        <input type="hidden" name="LTKTPeriod" value="{{ $LTKTPeriod }}" />

                        <div class="d-flex justify-content-end gap-2">
                            <a href="{{ $url_cancel }}" class="btn btn-light">Batal</a>
                            <button type="submit" id="btn-process" class="btn btn-primary" {{ $no == 0 ? 'disabled' : '' }}>
                                <i class="fas fa-database me-1"></i> Proses Data ({{ $no }} transaksi)
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

            $('#form-process').on('submit', function (e) {
                e.preventDefault();
                var form = this;

                Swal.fire({
                    title: 'Proses Data LTKT?',
                    html: 'Data LTKT periode <b>{{ $PeriodDesc }}</b> akan disimpan.<br>Data lama pada periode yang sama akan diganti.',
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonText: 'Ya, Proses',
                    cancelButtonText: 'Batal'
                }).then(function (result) {
                    if (result.isConfirmed) {
                        $('#btn-process').prop('disabled', true)
                            .html('<i class="fa fa-spinner fa-spin me-1"></i> Memproses...');
                        showPageLoader('Memproses data LTKT...');
                        form.submit();
                    }
                });
            });
        });
    </script>
@endsection
