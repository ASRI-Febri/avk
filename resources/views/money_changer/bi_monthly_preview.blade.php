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
                    <h3 class="card-title">{{ $form_sub_title }} - Periode {{ $PeriodDesc }} (Form B0001)</h3>
                    <div class="card-addon">
                        <a href="{{ $url_cancel }}" class="btn btn-secondary">
                            <i class="fas fa-arrow-left me-1"></i> Ganti Periode
                        </a>
                    </div>
                </div>

                <div class="card-body">
                    <div class="alert alert-label-info">
                        <span class="text-muted">
                            Sumber angka:
                            @if($source == 'saved')
                                <b>data tersimpan</b> (hasil simpan terakhir).
                            @elseif($has_cogs === 1)
                                <b>hasil Perhitungan HPP periode ini</b> — konsisten dengan closing bulanan,
                                jurnal HPP, neraca, dan laba rugi.
                            @else
                                <b>hitungan langsung dari transaksi</b> (belum tersimpan).
                            @endif
                            Semua kolom bisa dikoreksi. Saldo akhir dihitung otomatis = saldo awal + pembelian - penjualan.
                            Setelah <b>Simpan Data</b>, tombol <b>Download TXT</b> menghasilkan file
                            <b>{{ $txt_name }}</b> siap upload ke website Bank Indonesia.
                        </span>
                    </div>

                    @if($source == 'computed' && $has_cogs === 0)
                        <div class="alert alert-warning">
                            <b>Perhitungan HPP periode {{ $PeriodDesc }} belum diproses.</b>
                            Angka di bawah dihitung langsung dari transaksi memakai metode yang sama dengan HPP,
                            tetapi belum final. Agar laporan BI konsisten dengan neraca dan laba rugi:
                            proses <a href="{{ url('mc-cogs-calculation/create') }}" target="_blank">Perhitungan HPP</a>
                            untuk periode ini terlebih dahulu, lalu klik <b>Hitung Ulang dari Transaksi</b> /
                            preview ulang periode ini.
                        </div>
                    @endif

                    @php
                        $no_bi_rate = [];
                        if ($source == 'computed' && $records) {
                            foreach ($records as $r) {
                                if (isset($r->RateSource) && trim($r->RateSource) != 'BI') {
                                    $no_bi_rate[] = $r->CurrencyID;
                                }
                            }
                        }
                    @endphp
                    @if(count($no_bi_rate) > 0)
                        <div class="alert alert-warning">
                            <b>Kurs tengah BI belum tersedia</b> untuk valuta:
                            <b>{{ implode(', ', $no_bi_rate) }}</b> pada tanggal akhir bulan periode ini —
                            sementara memakai kurs master (rata-rata kurs jual/beli internal).
                            Upload file Kurs Transaksi dari website BI di menu
                            <a href="{{ url('mc-bi-middle-rate') }}" target="_blank">Kurs Tengah BI</a>,
                            lalu preview ulang periode ini.
                        </div>
                    @endif

                    @if(!empty($result['saved']))
                        <div class="alert alert-success">
                            <b>{{ $result['saved'] }}</b> baris valuta tersimpan untuk periode {{ $PeriodDesc }}.
                            Silakan download file txt di tombol kanan bawah.
                        </div>
                    @endif
                    @if(!empty($result['error']))
                        <div class="alert alert-danger">{{ $result['error'] }}</div>
                    @endif

                    @if($has_saved && $source == 'saved')
                        <form action="{{ $url_preview }}" method="POST" class="mb-3" data-loader="Menghitung ulang dari transaksi...">
                            <input type="hidden" name="_token" value="{{ csrf_token() }}" />
                            <input type="hidden" name="PeriodYear" value="{{ substr($ReportPeriod,0,4) }}" />
                            <input type="hidden" name="PeriodMonth" value="{{ substr($ReportPeriod,4,2) }}" />
                            <input type="hidden" name="recalc" value="1" />
                            <button type="submit" class="btn btn-sm btn-outline-secondary" data-loader-text="Menghitung ulang...">
                                <i class="fas fa-sync me-1"></i> Hitung Ulang dari Transaksi (abaikan data tersimpan)
                            </button>
                        </form>
                    @endif

                    <form id="form-grid" action="{{ $url_save }}" method="POST">
                        <input type="hidden" name="_token" value="{{ csrf_token() }}" />
                        <input type="hidden" name="ReportPeriod" value="{{ $ReportPeriod }}" />

                        <div class="table-responsive">
                            <table class="table table-bordered table-sm" id="grid-bi">
                                <thead>
                                    <tr class="text-center">
                                        <th>Lapor</th>
                                        <th>Valuta</th>
                                        <th>Saldo Awal Valas</th>
                                        <th>Saldo Awal Rp</th>
                                        <th>Pembelian Valas</th>
                                        <th>Pembelian Rp</th>
                                        <th>Penjualan Valas</th>
                                        <th>Penjualan Rp</th>
                                        <th>Saldo Akhir Valas</th>
                                        <th>Kurs Tengah</th>
                                        <th>Saldo Akhir Rp</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @php
                                        $i = 0;

                                        // Angka ditampilkan dengan pemisah ribuan dan desimal.
                                        // Aman untuk input yang bisa dikoreksi: BIMonthlyController::num()
                                        // membuang koma sebelum menyimpan, dan toNum() di bawah juga.
                                        $fmt = function ($value, $dec = 2) {
                                            return number_format((float) $value, $dec, '.', ',');
                                        };
                                    @endphp
                                    @if($records)
                                    @foreach($records as $row)
                                        <tr>
                                            <td class="text-center align-middle">
                                                <input type="checkbox" name="rows[{{ $i }}][include]" value="1" checked />
                                                <input type="hidden" name="rows[{{ $i }}][CurrencyID]" value="{{ $row->CurrencyID }}" />
                                            </td>
                                            <td class="align-middle" style="white-space:nowrap;">
                                                <b>{{ $row->CurrencyID }}</b> <small class="text-muted">{{ $row->CurrencyName ?? '' }}</small>
                                            </td>
                                            <td><input type="text" class="form-control form-control-sm text-end num" name="rows[{{ $i }}][OpeningForeign]" value="{{ $fmt($row->OpeningForeign) }}" /></td>
                                            <td><input type="text" class="form-control form-control-sm text-end num" name="rows[{{ $i }}][OpeningIDR]" value="{{ $fmt($row->OpeningIDR) }}" /></td>
                                            <td><input type="text" class="form-control form-control-sm text-end num" name="rows[{{ $i }}][BuyForeign]" value="{{ $fmt($row->BuyForeign) }}" /></td>
                                            <td><input type="text" class="form-control form-control-sm text-end num" name="rows[{{ $i }}][BuyIDR]" value="{{ $fmt($row->BuyIDR) }}" /></td>
                                            <td><input type="text" class="form-control form-control-sm text-end num" name="rows[{{ $i }}][SellForeign]" value="{{ $fmt($row->SellForeign) }}" /></td>
                                            <td><input type="text" class="form-control form-control-sm text-end num" name="rows[{{ $i }}][SellIDR]" value="{{ $fmt($row->SellIDR) }}" /></td>
                                            <td><input type="text" class="form-control form-control-sm text-end closing-f" data-ccy="{{ $row->CurrencyID }}" value="{{ $fmt($row->ClosingForeign) }}" readonly tabindex="-1" /></td>
                                            <td><input type="text" class="form-control form-control-sm text-end num rate" name="rows[{{ $i }}][MiddleRate]" value="{{ $fmt($row->MiddleRate, 4) }}" /></td>
                                            <td><input type="text" class="form-control form-control-sm text-end closing-r" value="{{ $fmt($row->ClosingIDR) }}" readonly tabindex="-1" /></td>
                                        </tr>
                                        @php $i++; @endphp
                                    @endforeach
                                    @endif

                                    @if($i == 0)
                                        <tr>
                                            <td colspan="11" class="text-center text-muted">
                                                Tidak ada data transaksi maupun saldo awal untuk periode {{ $PeriodDesc }}.
                                                Pastikan Perhitungan HPP bulan sebelumnya sudah diproses.
                                            </td>
                                        </tr>
                                    @endif
                                </tbody>
                            </table>
                        </div>

                        <hr>

                        <div class="d-flex justify-content-end gap-2">
                            <a href="{{ $url_cancel }}" class="btn btn-light">Batal</a>
                            <button type="submit" id="btn-save" class="btn btn-primary" {{ $i == 0 ? 'disabled' : '' }}>
                                <i class="fas fa-database me-1"></i> Simpan Data
                            </button>
                            <a href="{{ $url_download }}" class="btn btn-success {{ $has_saved ? '' : 'disabled' }}" id="btn-download">
                                <i class="fas fa-file-download me-1"></i> Download TXT ({{ $txt_name }})
                            </a>
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
            $('#nav-report').addClass('mm-active');
            $('#nav-ul-report').addClass('mm-show');
            $('#nav-li-rpt-bi-monthly').addClass('mm-active');

            function toNum(v) {
                v = parseFloat(String(v).replace(/,/g, ''));
                return isNaN(v) ? 0 : v;
            }

            // Tampilan angka: pemisah ribuan koma, desimal titik
            function fmtNum(v, dec) {
                if (dec === undefined) dec = 2;
                return toNum(v).toLocaleString('en-US', {
                    minimumFractionDigits: dec,
                    maximumFractionDigits: dec
                });
            }

            // HITUNG ULANG SALDO AKHIR SAAT ANGKA DIUBAH (RUMUS FORM B0001)
            function recalcRow(tr) {
                var opening = toNum(tr.find('input[name*="[OpeningForeign]"]').val());
                var buy = toNum(tr.find('input[name*="[BuyForeign]"]').val());
                var sell = toNum(tr.find('input[name*="[SellForeign]"]').val());
                var rate = toNum(tr.find('input[name*="[MiddleRate]"]').val());
                var ccy = tr.find('.closing-f').data('ccy');

                var closing = opening + buy - sell;
                var closingIdr = (ccy === 'JPY') ? (closing * rate) / 100 : closing * rate;

                tr.find('.closing-f').val(fmtNum(closing));
                tr.find('.closing-r').val(fmtNum(closingIdr));
            }

            $('#grid-bi').on('input', 'input.num', function () {
                recalcRow($(this).closest('tr'));
            });

            // Saat diklik, pemisah ribuan dilepas supaya angka mudah diketik ulang;
            // begitu pindah kolom, tampilannya diformat lagi.
            $('#grid-bi').on('focus', 'input.num', function () {
                var v = toNum($(this).val());
                $(this).val(v === 0 ? '' : v);
                $(this).select();
            });

            $('#grid-bi').on('blur', 'input.num', function () {
                var dec = $(this).hasClass('rate') ? 4 : 2;
                $(this).val(fmtNum($(this).val(), dec));
                recalcRow($(this).closest('tr'));
            });

            $('#form-grid').on('submit', function (e) {
                e.preventDefault();
                var form = this;
                var total = $('input[name*="[include]"]:checked').length;

                Swal.fire({
                    title: 'Simpan Laporan Bulanan BI?',
                    html: '<b>' + total + '</b> baris valuta periode <b>{{ $PeriodDesc }}</b> akan disimpan.' +
                        '<br>Data tersimpan sebelumnya pada periode yang sama akan diganti.',
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonText: 'Ya, Simpan',
                    cancelButtonText: 'Batal'
                }).then(function (result) {
                    if (result.isConfirmed) {
                        $('#btn-save').prop('disabled', true)
                            .html('<i class="fa fa-spinner fa-spin me-1"></i> Menyimpan...');
                        showPageLoader('Menyimpan laporan bulanan BI...');
                        form.submit();
                    }
                });
            });
        });
    </script>
@endsection
