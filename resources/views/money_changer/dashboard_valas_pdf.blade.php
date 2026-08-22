@extends('layouts.pdf')

@section('title')
    Stok Valas {{ date('d M Y', strtotime($as_of_date)) }}
@endsection

@section('content')

    <div style="float:left;width:60%">
        <table class="noborder">
            <tr class="noborder nopadding">
                <td class="td-85 bold noborder nopadding param-key">
                    <span style="display:block;">PT. {{ strtoupper($company_name) }}</span>
                </td>
            </tr>
        </table>
    </div>

    <div style="float:left;width:40%">
        <h2>Stok Valas — Persiapan &amp; Penutupan Harian</h2>
        <table class="noborder nopadding">
            <tr class="noborder nopadding">
                <td class="td-20 bold noborder nopadding param-key">Tanggal</td>
                <td class="td-50 bold noborder nopadding param-value">: {{ date('d M Y', strtotime($as_of_date)) }}</td>
            </tr>
            <tr class="noborder nopadding">
                <td class="td-20 bold noborder nopadding param-key">Waktu Cetak</td>
                <td class="td-50 bold noborder nopadding param-value">: {{ date('d M Y H:i') }}</td>
            </tr>
            <tr class="noborder nopadding">
                <td class="td-20 bold noborder nopadding param-key">Dicetak Oleh</td>
                <td class="td-50 bold noborder nopadding param-value">: {{ $user_name }}</td>
            </tr>
        </table>
    </div>

    <br>

    <table>
        <thead>
            <tr>
                <td class="bold td-10">NO</td>
                <td class="bold td-25">VALAS</td>
                <td class="bold text-right td-10">QTY SISTEM</td>
                <td class="bold text-right td-10">QTY FISIK</td>
                <td class="bold text-right td-15">JUMLAH VALAS</td>
                <td class="bold text-right td-15">RATE RATA-RATA</td>
                <td class="bold text-right td-15">JUMLAH IDR</td>
            </tr>
        </thead>
        <tbody>
            @if($records_stock)

                @php
                    $row_number = 0;

                    $group_a1 = '';
                    $group_a2 = '';

                    $group_valas_amount = 0;
                    $group_base_amount = 0;
                    $total_base_amount = 0;

                    $prev_currency_id = '';
                @endphp

                @foreach($records_stock as $row)

                    @php
                        $row_number += 1;
                        $group_a1 = $row->CurrencyID;

                        $total_base_amount += ($row->EB_Quantity * $row->ValasChangeNumber * $row->AverageValue);
                    @endphp

                    {{-- Ganti mata uang: tutup dulu subtotal mata uang sebelumnya --}}
                    @if($group_a1 <> $group_a2)

                        @if($row_number > 1)
                            <tr>
                                <td class="text-right" colspan="4"><strong>TOTAL {{ $prev_currency_id }}</strong></td>
                                <td class="text-right"><strong>{{ $prev_currency_id . ' ' . number_format($group_valas_amount, 2, '.', ',') }}</strong></td>
                                <td></td>
                                <td class="text-right"><strong>{{ 'IDR ' . number_format($group_base_amount, 2, '.', ',') }}</strong></td>
                            </tr>
                        @endif

                        @php
                            $group_valas_amount = 0;
                            $group_base_amount = 0;
                            $group_a2 = $group_a1;
                        @endphp
                    @endif

                    @php
                        $group_valas_amount += ($row->EB_Quantity * $row->ValasChangeNumber);
                        $group_base_amount += ($row->EB_Quantity * $row->ValasChangeNumber * $row->AverageValue);
                        $prev_currency_id = $row->CurrencyID;
                    @endphp

                    <tr>
                        <td>{{ $row_number }}</td>
                        <td>{{ $row->ValasName }}</td>
                        <td class="text-right">{{ number_format($row->EB_Quantity, 0, '.', ',') }}</td>
                        {{-- Sengaja dikosongkan: diisi tangan saat hitung fisik --}}
                        <td>&nbsp;</td>
                        <td class="text-right">{{ $row->CurrencyID . ' ' . number_format($row->EB_Quantity * $row->ValasChangeNumber, 0, '.', ',') }}</td>
                        <td class="text-right">{{ 'IDR ' . number_format($row->AverageValue, 2, '.', ',') }}</td>
                        <td class="text-right">{{ 'IDR ' . number_format($row->EB_Quantity * $row->ValasChangeNumber * $row->AverageValue, 2, '.', ',') }}</td>
                    </tr>
                @endforeach

                <tr>
                    <td class="text-right" colspan="4"><strong>TOTAL {{ $prev_currency_id }}</strong></td>
                    <td class="text-right"><strong>{{ $prev_currency_id . ' ' . number_format($group_valas_amount, 2, '.', ',') }}</strong></td>
                    <td></td>
                    <td class="text-right"><strong>{{ 'IDR ' . number_format($group_base_amount, 2, '.', ',') }}</strong></td>
                </tr>
                <tr>
                    <td class="text-right" colspan="4"><strong>GRAND TOTAL IDR</strong></td>
                    <td></td>
                    <td></td>
                    <td class="text-right"><strong>{{ 'IDR ' . number_format($total_base_amount, 2, '.', ',') }}</strong></td>
                </tr>
            @else
                <tr>
                    <td colspan="7" class="text-center">Tidak ada stok valas per tanggal ini.</td>
                </tr>
            @endif
        </tbody>
    </table>

    <br>

    <table>
        <thead>
            <tr>
                <td class="bold w-50 td-50">Catatan</td>
                <td class="bold w-20 td-15 text-center">Teller</td>
                <td class="bold w-20 td-15 text-center">Manajer Umum</td>
                <td class="bold w-20 td-15 text-center">Direktur</td>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td class="w-50">
                    Harap periksa dan hitung kembali jumlah masing-masing valas
                    <br>
                    <br>
                    <br>
                    <br>
                </td>
                <td class="w-15">&nbsp;</td>
                <td class="w-15">&nbsp;</td>
                <td class="w-15">&nbsp;</td>
            </tr>
        </tbody>
    </table>

@endsection
