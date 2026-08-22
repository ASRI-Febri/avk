@extends('layouts.master')

@section('title', $title ?? 'Update Kurs')

@section('content')

    @php
        $records = $records ?? [];
        $history = $history ?? [];
        $result  = $result ?? null;

        $rate = function ($nilai) { return number_format((float) $nilai, 2, ',', '.'); };
    @endphp

    {{-- Ringkasan hasil simpan sebelumnya (redirect dari /mc-currency-rate/save) --}}
    @if($result)
        <div class="row">
            <div class="col-12">
                @if(count($result['tersimpan']))
                    <div class="alert alert-success">
                        <strong>{{ count($result['tersimpan']) }} mata uang diperbarui.</strong>
                        Rate lama sudah tersimpan sebagai riwayat.
                        <div class="table-responsive mt-2">
                            <table class="table table-sm table-bordered bg-white mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th>Mata Uang</th>
                                        <th class="text-end">Rate Beli Lama</th>
                                        <th class="text-end">Rate Beli Baru</th>
                                        <th class="text-end">Rate Jual Lama</th>
                                        <th class="text-end">Rate Jual Baru</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @foreach($result['tersimpan'] as $u)
                                        <tr>
                                            <td>{{ $u['CurrencyID'] }}</td>
                                            <td class="text-end text-muted">{{ $rate($u['OldBuyRate']) }}</td>
                                            <td class="text-end fw-bold">{{ $rate($u['NewBuyRate']) }}</td>
                                            <td class="text-end text-muted">{{ $rate($u['OldSellRate']) }}</td>
                                            <td class="text-end fw-bold">{{ $rate($u['NewSellRate']) }}</td>
                                        </tr>
                                    @endforeach
                                </tbody>
                            </table>
                        </div>
                    </div>
                @elseif(!count($result['gagal']) && !count($result['bentrok']))
                    <div class="alert alert-info">Tidak ada rate yang berubah, jadi tidak ada yang disimpan.</div>
                @endif

                @if(count($result['bentrok']))
                    <div class="alert alert-warning">
                        <strong>Dilewati karena sudah diubah orang lain:</strong>
                        {{ implode(', ', $result['bentrok']) }}.
                        Rate di layar ini sudah dimuat ulang; periksa lalu simpan kembali bila memang perlu diubah.
                    </div>
                @endif

                @if(count($result['gagal']))
                    <div class="alert alert-danger">
                        <strong>Gagal disimpan:</strong>
                        <ul class="mb-0">
                            @foreach($result['gagal'] as $g)
                                <li>{{ $g }}</li>
                            @endforeach
                        </ul>
                    </div>
                @endif
            </div>
        </div>
    @endif

    <form action="{{ $url_save }}" method="POST" id="form-currency-rate">
        @csrf

        <div class="row">
            <div class="col-lg-8">
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title mb-1">Rate Beli / Rate Jual</h5>
                        <p class="text-muted mb-3">
                            Ubah nilai pada kolom yang perlu diperbarui, baris lain biarkan apa adanya.
                            Saat disimpan, rate baru masuk ke master mata uang dan rate sebelumnya
                            tercatat di riwayat.
                        </p>

                        <div class="table-responsive">
                            <table class="table table-sm table-bordered align-middle mb-0" id="tbl-rate">
                                <thead class="table-light">
                                    <tr>
                                        <th style="width:40px;" class="text-center">No</th>
                                        <th style="width:90px;">Kode</th>
                                        <th>Nama Valas</th>
                                        <th style="width:170px;" class="text-end">Rate Beli</th>
                                        <th style="width:170px;" class="text-end">Rate Jual</th>
                                        <th style="width:150px;">Terakhir Diubah</th>
                                        <th style="width:70px;" class="text-center">Riwayat</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @forelse($records as $i => $row)
                                        <tr>
                                            <td class="text-center">{{ $i + 1 }}</td>
                                            <td>
                                                <strong>{{ $row->CurrencyID }}</strong>
                                                <input type="hidden" name="IDX_M_Currency[]" value="{{ $row->IDX_M_Currency }}">
                                                {{-- Nilai saat form dibuka, dipakai mendeteksi perubahan orang lain --}}
                                                <input type="hidden" name="BuyRateAwal[]" value="{{ number_format((float) $row->BuyRate, 4, '.', '') }}">
                                                <input type="hidden" name="SellRateAwal[]" value="{{ number_format((float) $row->SellRate, 4, '.', '') }}">
                                            </td>
                                            <td>
                                                {{ $row->CurrencyName }}
                                                @if($row->CountryName !== '')
                                                    <small class="text-muted d-block">{{ $row->CountryName }}</small>
                                                @endif
                                            </td>
                                            <td>
                                                <input type="text" name="BuyRate[]" class="form-control form-control-sm text-end rate-input"
                                                    data-awal="{{ number_format((float) $row->BuyRate, 4, '.', '') }}"
                                                    value="{{ number_format((float) $row->BuyRate, 2, ',', '.') }}"
                                                    inputmode="decimal" autocomplete="off">
                                            </td>
                                            <td>
                                                <input type="text" name="SellRate[]" class="form-control form-control-sm text-end rate-input"
                                                    data-awal="{{ number_format((float) $row->SellRate, 4, '.', '') }}"
                                                    value="{{ number_format((float) $row->SellRate, 2, ',', '.') }}"
                                                    inputmode="decimal" autocomplete="off">
                                            </td>
                                            <td>
                                                @if($row->DModified)
                                                    <small>{{ date('d/m/Y H:i', strtotime($row->DModified)) }}</small>
                                                    <small class="text-muted d-block">{{ $row->UModified }}</small>
                                                @else
                                                    <small class="text-muted">-</small>
                                                @endif
                                            </td>
                                            <td class="text-center">
                                                <a href="{{ url('mc-currency-rate/history/' . $row->IDX_M_Currency) }}"
                                                    class="btn btn-sm btn-light" title="Riwayat {{ $row->CurrencyID }}">
                                                    <i class="fas fa-history"></i>
                                                </a>
                                            </td>
                                        </tr>
                                    @empty
                                        <tr>
                                            <td colspan="7" class="text-center text-muted">Belum ada mata uang aktif.</td>
                                        </tr>
                                    @endforelse
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div class="card-footer d-flex justify-content-between align-items-center">
                        <span class="text-muted" id="info-perubahan">Belum ada perubahan.</span>
                        <div>
                            <a href="{{ $url_cancel }}" class="btn btn-light">Batal</a>
                            <button type="submit" class="btn btn-primary" id="btn-simpan">
                                <i class="fas fa-save me-1"></i> Simpan Kurs
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            {{-- ===================== PERUBAHAN TERAKHIR ===================== --}}
            <div class="col-lg-4">
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title mb-1">Perubahan Terakhir</h5>
                        <p class="text-muted mb-3">30 perubahan rate terakhir dari seluruh mata uang.</p>

                        @if(count($history))
                            <div class="table-responsive">
                                <table class="table table-sm table-bordered align-middle mb-0">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Waktu</th>
                                            <th>Kode</th>
                                            <th class="text-end">Beli</th>
                                            <th class="text-end">Jual</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        @foreach($history as $h)
                                            <tr>
                                                <td>
                                                    <small>{{ date('d/m/Y H:i', strtotime($h->ChangeDate)) }}</small>
                                                    <small class="text-muted d-block">{{ $h->UCreate }} &middot; {{ $h->ChangeSource }}</small>
                                                </td>
                                                <td>{{ $h->CurrencyID }}</td>
                                                <td class="text-end">
                                                    <small class="text-muted d-block text-decoration-line-through">{{ $rate($h->OldBuyRate) }}</small>
                                                    {{ $rate($h->NewBuyRate) }}
                                                </td>
                                                <td class="text-end">
                                                    <small class="text-muted d-block text-decoration-line-through">{{ $rate($h->OldSellRate) }}</small>
                                                    {{ $rate($h->NewSellRate) }}
                                                </td>
                                            </tr>
                                        @endforeach
                                    </tbody>
                                </table>
                            </div>
                        @else
                            <div class="alert alert-light mb-0">Belum ada riwayat perubahan rate.</div>
                        @endif
                    </div>
                </div>
            </div>
        </div>
    </form>

@endsection

@section('script')
<script>
$(function () {

    $('#nav-li-currency-rate').addClass('mm-active');

    // Baris yang diubah ditandai supaya operator tahu persis apa yang akan tersimpan.
    function angka(teks) {
        teks = $.trim(String(teks));
        if (teks === '') return null;

        var koma  = teks.lastIndexOf(',');
        var titik = teks.lastIndexOf('.');

        if (koma > -1 && (titik === -1 || koma > titik)) {
            // Gaya Indonesia: 18.000,50
            teks = teks.replace(/\./g, '').replace(',', '.');
        } else if (koma === -1 && /^\d{1,3}(\.\d{3})+$/.test(teks)) {
            // 18.000 tanpa desimal: titik di sini pemisah ribuan, bukan desimal
            teks = teks.replace(/\./g, '');
        } else {
            teks = teks.replace(/,/g, '');
        }

        return isNaN(parseFloat(teks)) ? null : parseFloat(teks);
    }

    function tandai() {
        var berubah = 0;

        $('#tbl-rate tbody tr').each(function () {
            var $baris = $(this);
            var $input = $baris.find('.rate-input');

            if (!$input.length) return;

            var ubah = false;
            $input.each(function () {
                var baru = angka(this.value);
                var awal = parseFloat($(this).data('awal'));

                if (baru === null) {
                    $(this).addClass('is-invalid');
                    ubah = true;
                    return;
                }

                $(this).removeClass('is-invalid');
                if (Math.abs(baru - awal) >= 0.00005) ubah = true;
            });

            $baris.toggleClass('table-warning', ubah);
            if (ubah) berubah++;
        });

        $('#info-perubahan').text(berubah === 0
            ? 'Belum ada perubahan.'
            : berubah + ' mata uang akan diperbarui.');
    }

    // Tampilan angka disamakan dengan format Indonesia (18.000,50). Yang dikirim
    // ke server tetap teks ini; controller sudah mengurai kedua gaya penulisan.
    function format(nilai) {
        return nilai.toLocaleString('id-ID', { minimumFractionDigits: 2, maximumFractionDigits: 4 });
    }

    $('#tbl-rate').on('input', '.rate-input', tandai);

    $('#tbl-rate').on('blur', '.rate-input', function () {
        var nilai = angka(this.value);
        if (nilai !== null) {
            this.value = format(nilai);
        }
        tandai();
    });

    // Saat difokus, pemisah ribuan dilepas supaya angka mudah ditimpa ketik.
    $('#tbl-rate').on('focus', '.rate-input', function () {
        var nilai = angka(this.value);
        if (nilai !== null) {
            this.value = String(nilai).replace('.', ',');
        }
        this.select();
    });

    tandai();

    // Rate jual di bawah rate beli hampir selalu salah ketik, jadi dikonfirmasi
    // dulu; tetap boleh dilanjutkan karena aturannya bisa berbeda per kasus.
    $('#form-currency-rate').on('submit', function (e) {
        var salah = [];

        $('#tbl-rate tbody tr').each(function () {
            var kode = $.trim($(this).find('td:eq(1) strong').text());
            var beli = angka($(this).find('input[name="BuyRate[]"]').val());
            var jual = angka($(this).find('input[name="SellRate[]"]').val());

            if (beli !== null && jual !== null && jual < beli) salah.push(kode);
        });

        if (salah.length === 0) return true;

        e.preventDefault();

        Swal.fire({
            title: 'Rate jual lebih rendah dari rate beli',
            html: 'Terjadi pada: <b>' + salah.join(', ') + '</b>.<br>Tetap simpan?',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonText: 'Tetap Simpan',
            cancelButtonText: 'Periksa Lagi'
        }).then(function (pilih) {
            if (pilih.isConfirmed) {
                $('#form-currency-rate')[0].submit();
            }
        });

        return false;
    });
});
</script>
@endsection
