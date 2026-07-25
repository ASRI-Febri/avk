@extends('layouts.master')

@section('topbar-title')
    {{ $form_title }}
@endsection

@section('title')
    {{ $form_title }}
@endsection

@section('content')

    <div class="row">
        <div class="col-xl-10 col-md-12 col-sm-12">
            <div class="card">
                <div class="card-header card-header-bordered">
                    <h3 class="card-title">{{ $form_sub_title }}</h3>
                    <div class="card-addon">
                        <a href="{{ url('mc-bi-monthly') }}" class="btn btn-info">
                            <i class="fas fa-file-alt me-1"></i> Laporan Bulanan BI
                        </a>
                    </div>
                </div>

                <div class="card-body">
                    <div class="alert alert-label-info">
                        <span class="text-muted">
                            Upload file Excel <b>Kurs Transaksi</b> hasil download dari website Bank Indonesia
                            (contoh: <b>Kurs Transaksi 31-Mar-2026.xlsx</b>). Pilih periode bulan &amp; tahun —
                            kurs disimpan pada <b>tanggal akhir bulan</b> periode tersebut. Kurs tengah dihitung
                            otomatis = (kurs jual + kurs beli) / 2 dan dipakai sebagai kurs pada Laporan Bulanan BI.
                        </span>
                    </div>

                    @if(!empty($error))
                    <div class="alert alert-danger">{{ $error }}</div>
                    @endif

                    {{-- ============================ HASIL SIMPAN ============================ --}}
                    @if(!empty($result))
                    <div class="alert {{ $result['failed'] > 0 ? 'alert-warning' : 'alert-success' }}">
                        <b>Hasil upload:</b> {{ $result['success'] }} kurs tersimpan
                        @if($result['date'] !== '') untuk tanggal <b>{{ date('d M Y', strtotime($result['date'])) }}</b> @endif,
                        {{ $result['failed'] }} gagal.
                        @if(count($result['messages']))
                            <hr>
                            @foreach($result['messages'] as $msg)
                                <span style="display:block;">{{ $msg }}</span>
                            @endforeach
                        @endif
                    </div>
                    @endif

                    {{-- ============================ STEP 1: UPLOAD ============================ --}}
                    @if($state == 'upload')
                    <form action="{{ url('mc-bi-middle-rate/preview') }}" method="POST" enctype="multipart/form-data">
                        <input type="hidden" name="_token" value="{{ csrf_token() }}" />

                        <div class="d-grid gap-3">
                            <div class="form-group row">
                                <label class="col-sm-3 col-form-label text-secondary">Periode (Akhir Bulan)</label>
                                <div class="col-sm-4">
                                    <select id="PeriodMonth" name="PeriodMonth" class="form-control" required>
                                        @foreach($dd_month as $key => $value)
                                            <option value="{{ $key }}" {{ $PeriodMonth == $key ? 'selected' : '' }}>{{ $value }}</option>
                                        @endforeach
                                    </select>
                                </div>
                                <div class="col-sm-3">
                                    <select id="PeriodYear" name="PeriodYear" class="form-control" required>
                                        @foreach($dd_year as $key => $value)
                                            <option value="{{ $key }}" {{ $PeriodYear == $key ? 'selected' : '' }}>{{ $value }}</option>
                                        @endforeach
                                    </select>
                                </div>
                            </div>
                            <div class="form-group row">
                                <label class="col-sm-3 col-form-label text-secondary">File Excel Kurs BI</label>
                                <div class="col-sm-7">
                                    <input type="file" id="file_import" name="file_import" class="form-control" accept=".xlsx,.xls" required />
                                    <small class="text-muted">File asli dari website BI tanpa diubah susunannya.</small>
                                </div>
                            </div>
                        </div>

                        <hr>
                        <div class="d-flex justify-content-end gap-2">
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-search me-1"></i> Upload &amp; Preview
                            </button>
                        </div>
                    </form>

                    {{-- ==================== KURS TERSIMPAN ==================== --}}
                    @if(count($saved_dates) > 0)
                        <hr>
                        <div class="row">
                            <div class="col-md-4">
                                <h5 class="mb-3">Periode Tersimpan</h5>
                                <table class="table table-sm table-bordered">
                                    <thead>
                                        <tr><th>Tanggal</th><th class="text-center">Valuta</th></tr>
                                    </thead>
                                    <tbody>
                                        @foreach($saved_dates as $d)
                                            <tr>
                                                <td>
                                                    <a href="{{ url('mc-bi-middle-rate') . '?ViewDate=' . date('Y-m-d', strtotime($d->RateDate)) }}">
                                                        {{ date('d M Y', strtotime($d->RateDate)) }}
                                                    </a>
                                                </td>
                                                <td class="text-center">{{ $d->TotalCurrency }}</td>
                                            </tr>
                                        @endforeach
                                    </tbody>
                                </table>
                            </div>
                            <div class="col-md-8">
                                @if(count($saved_rates) > 0)
                                    <h5 class="mb-3">
                                        Kurs Tengah BI — {{ date('d M Y', strtotime($saved_rates[0]->RateDate)) }}
                                        <small class="text-muted">({{ $saved_rates[0]->FileName }})</small>
                                    </h5>
                                    <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
                                        <table class="table table-sm table-bordered table-striped">
                                            <thead>
                                                <tr>
                                                    <th>Valuta</th>
                                                    <th class="text-center">Nilai</th>
                                                    <th class="text-end">Kurs Jual</th>
                                                    <th class="text-end">Kurs Beli</th>
                                                    <th class="text-end">Kurs Tengah</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                @foreach($saved_rates as $r)
                                                    <tr>
                                                        <td><b>{{ $r->CurrencyID }}</b> <small class="text-muted">{{ $r->CurrencyName }}</small></td>
                                                        <td class="text-center">{{ $r->RateUnit }}</td>
                                                        <td class="text-end">{{ number_format($r->SellRate, 4, '.', ',') }}</td>
                                                        <td class="text-end">{{ number_format($r->BuyRate, 4, '.', ',') }}</td>
                                                        <td class="text-end"><b>{{ number_format($r->MiddleRate, 4, '.', ',') }}</b></td>
                                                    </tr>
                                                @endforeach
                                            </tbody>
                                        </table>
                                    </div>
                                @endif
                            </div>
                        </div>
                    @endif
                    @endif

                    {{-- ============================ STEP 2: PREVIEW ============================ --}}
                    @if($state == 'preview')

                    <div class="alert {{ $error_count > 0 ? 'alert-warning' : 'alert-success' }}">
                        File <b>{{ $file_name }}</b>:
                        <b>{{ $valid_count }}</b> kurs valid siap disimpan untuk tanggal
                        <b>{{ date('d M Y', strtotime($RateDate)) }}</b>,
                        <b>{{ $error_count }}</b> baris bermasalah (tidak akan disimpan).
                        @if($existing_count > 0)
                            <br>Kurs tanggal ini sudah pernah tersimpan ({{ $existing_count }} valuta) —
                            akan <b>dihapus dan diganti</b> dengan isi file ini.
                        @endif
                    </div>

                    @if($date_mismatch)
                        <div class="alert alert-danger">
                            <b>Perhatian:</b> judul file menyebut tanggal
                            <b>{{ date('d M Y', strtotime($TitleDate)) }}</b>, sedangkan periode yang Anda pilih
                            adalah <b>{{ date('d M Y', strtotime($RateDate)) }}</b>.
                            Pastikan file dan periode sudah sesuai sebelum menyimpan.
                        </div>
                    @endif

                    <div class="table-responsive" style="max-height: 450px; overflow-y: auto;">
                        <table class="table table-sm table-bordered table-striped">
                            <thead>
                                <tr>
                                    <th>Valuta</th>
                                    <th class="text-center">Nilai</th>
                                    <th class="text-end">Kurs Jual</th>
                                    <th class="text-end">Kurs Beli</th>
                                    <th class="text-end">Kurs Tengah</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                            @foreach($preview as $item)
                                <tr class="{{ count($item['errors']) ? 'table-danger' : '' }}">
                                    <td><b>{{ $item['CurrencyID'] }}</b></td>
                                    <td class="text-center">{{ $item['RateUnit'] }}</td>
                                    <td class="text-end">{{ number_format($item['SellRate'], 4, '.', ',') }}</td>
                                    <td class="text-end">{{ number_format($item['BuyRate'], 4, '.', ',') }}</td>
                                    <td class="text-end"><b>{{ number_format($item['MiddleRate'], 4, '.', ',') }}</b></td>
                                    <td>
                                        @if(count($item['errors']))
                                            <span class="text-danger">{{ implode('; ', $item['errors']) }}</span>
                                        @else
                                            <span class="text-success">OK</span>
                                        @endif
                                    </td>
                                </tr>
                            @endforeach
                            </tbody>
                        </table>
                    </div>

                    <hr>

                    <form id="form-save" action="{{ url('mc-bi-middle-rate/save') }}" method="POST">
                        <input type="hidden" name="_token" value="{{ csrf_token() }}" />

                        <div class="d-flex justify-content-end gap-2">
                            <a href="{{ url('mc-bi-middle-rate') }}" class="btn btn-light">Upload Ulang</a>
                            <button type="submit" id="btn-save" class="btn btn-primary" {{ $valid_count == 0 ? 'disabled' : '' }}>
                                <i class="fas fa-database me-1"></i> Simpan Kurs ({{ $valid_count }} valuta)
                            </button>
                        </div>
                    </form>
                    @endif
                </div>
            </div>
        </div>
    </div>

@endsection

@section('script')
    <script>
        $(document).ready(function () {
            $('#nav-li-bi-middle-rate').addClass('mm-active');

            $('#form-save').on('submit', function (e) {
                e.preventDefault();
                var form = this;

                Swal.fire({
                    title: 'Simpan Kurs Tengah BI?',
                    html: 'Kurs tanggal <b>{{ isset($RateDate) ? date('d M Y', strtotime($RateDate)) : '' }}</b> akan disimpan.' +
                        '<br>Kurs lama pada tanggal yang sama akan diganti.',
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonText: 'Ya, Simpan',
                    cancelButtonText: 'Batal'
                }).then(function (result) {
                    if (result.isConfirmed) {
                        $('#btn-save').prop('disabled', true)
                            .html('<i class="fa fa-spinner fa-spin me-1"></i> Menyimpan...');
                        form.submit();
                    }
                });
            });
        });
    </script>
@endsection
