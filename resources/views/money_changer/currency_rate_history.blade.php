@extends('layouts.master')

@section('title', $title ?? 'Riwayat Kurs')

@section('content')

    @php
        $history  = $history ?? [];
        $currency = $currency ?? null;
        $rate = function ($nilai) { return number_format((float) $nilai, 2, ',', '.'); };
    @endphp

    <div class="row">
        <div class="col-lg-9">
            <div class="card">
                <div class="card-body">
                    <h5 class="card-title mb-1">
                        Riwayat Kurs
                        @if($currency)
                            — {{ $currency->CurrencyID }} ({{ $currency->CurrencyName }})
                        @endif
                    </h5>
                    <p class="text-muted mb-3">
                        @if($currency)
                            Rate berlaku sekarang: beli <strong>{{ $rate($currency->BuyRate) }}</strong>,
                            jual <strong>{{ $rate($currency->SellRate) }}</strong>.
                        @endif
                        Baris di bawah menampilkan nilai sebelum dan sesudah setiap perubahan, terbaru di atas.
                    </p>

                    @if(count($history))
                        <div class="table-responsive">
                            <table class="table table-sm table-bordered align-middle mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th style="width:150px;">Waktu</th>
                                        <th style="width:80px;">Kode</th>
                                        <th class="text-end">Rate Beli Lama</th>
                                        <th class="text-end">Rate Beli Baru</th>
                                        <th class="text-end">Rate Jual Lama</th>
                                        <th class="text-end">Rate Jual Baru</th>
                                        <th style="width:140px;">Sumber</th>
                                        <th style="width:140px;">User</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @foreach($history as $h)
                                        <tr>
                                            <td>{{ date('d/m/Y H:i', strtotime($h->ChangeDate)) }}</td>
                                            <td>{{ $h->CurrencyID }}</td>
                                            <td class="text-end text-muted">{{ $rate($h->OldBuyRate) }}</td>
                                            <td class="text-end fw-bold">{{ $rate($h->NewBuyRate) }}</td>
                                            <td class="text-end text-muted">{{ $rate($h->OldSellRate) }}</td>
                                            <td class="text-end fw-bold">{{ $rate($h->NewSellRate) }}</td>
                                            <td>{{ $h->ChangeSource }}</td>
                                            <td>{{ $h->UCreate }}</td>
                                        </tr>
                                    @endforeach
                                </tbody>
                            </table>
                        </div>
                    @else
                        <div class="alert alert-light mb-0">Belum ada perubahan rate yang tercatat.</div>
                    @endif
                </div>

                <div class="card-footer">
                    <a href="{{ url('mc-currency-rate') }}" class="btn btn-light">
                        <i class="fas fa-arrow-left me-1"></i> Kembali ke Update Kurs
                    </a>
                </div>
            </div>
        </div>
    </div>

@endsection

@section('script')
<script>
    $(function () { $('#nav-li-currency-rate').addClass('mm-active'); });
</script>
@endsection
