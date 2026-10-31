@extends('layouts.report_data')

@section('title')
    {{ $title }}
@endsection

@section('pagetitle')
    {{ $page_title }}
@endsection

@section('content')

    @php
        $qty = function ($value) {
            return $value != 0 ? number_format($value, 0, '.', ',') : '';
        };
        $amount = function ($value) {
            return number_format($value, 2, '.', ',');
        };
    @endphp

    <!-- BEGIN REPORT PARAMETER -->
    <div style="width:100%;">
        <div style="float:left;width:70%;">
            <table>
                <tr>
                    <td class="param-key">MATA UANG</td>
                    <td class="param-value">: {{ $CurrencyName }}</td>
                </tr>
                <tr>
                    <td class="param-key">VALUTA ASING</td>
                    <td class="param-value">: {{ $ValasName }}</td>
                </tr>
                <tr>
                    <td class="param-key">GROUP DATA</td>
                    <td class="param-value">: CURRENCY (PER MATA UANG)</td>
                </tr>
                <tr>
                    <td class="param-key">TANGGAL TRANSAKSI</td>
                    <td class="param-value">: {{ date('d M Y',strtotime($fields['start_date'])) . ' - ' .date('d M Y',strtotime($fields['end_date'])) }}</td>
                </tr>
            </table>
        </div>
    </div>
    <br/>
    <hr>
    <br/>
    <!-- END REPORT PARAMETER -->

    <!-- BEGIN REPORT DATA -->
    <table id="table-report" class="minimalistBlack">
        @forelse($groups as $group)
            <thead>
                <tr class="bg-info">
                    <th class="text-start" colspan="11">{{ strtoupper($group['currency_id'] . ($group['currency_name'] != $group['currency_id'] ? ' - ' . $group['currency_name'] : '')) }}</th>
                </tr>
                <tr>
                    <th rowspan="2">#</th>
                    <th rowspan="2">TANGGAL</th>
                    <th rowspan="2">KETERANGAN</th>
                    <th rowspan="2">NO TRANSAKSI</th>
                    <th rowspan="2">SKU</th>
                    <th rowspan="2">NAMA BARANG</th>
                    <th colspan="2" class="text-center">LEMBAR</th>
                    <th colspan="3" class="text-center">NILAI VALAS ({{ $group['currency_id'] }})</th>
                </tr>
                <tr>
                    <th class="text-center">MASUK</th>
                    <th class="text-center">KELUAR</th>
                    <th class="text-center">MASUK</th>
                    <th class="text-center">KELUAR</th>
                    <th class="text-center">SALDO</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td></td>
                    <td>{{ date('d M Y', strtotime($fields['start_date'] . ' -1 day')) }}</td>
                    <td colspan="4"><strong>SALDO AWAL</strong></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td class="text-right"><strong>{{ $amount($group['opening']) }}</strong></td>
                </tr>
                @foreach($group['rows'] as $i => $row)
                    <tr>
                        <td>{{ $i + 1 }}</td>
                        <td>{{ date('d M Y', strtotime($row->TransactionDate)) }}</td>
                        <td>{{ $row->TransactionTypeName }}</td>
                        <td>
                            @if($row->IDX_Transaction > 0)
                                @if($row->IDX_M_TransactionType == 3)
                                    <a href="{{ url('mc-purchase-order/update') . '/' . $row->IDX_Transaction }}" target="_blank">{{ $row->TransactionNo }}</a>
                                @else
                                    <a href="{{ url('mc-sales-order/update') . '/' . $row->IDX_Transaction }}" target="_blank">{{ $row->TransactionNo }}</a>
                                @endif
                            @else
                                {{ $row->TransactionNo }}
                            @endif
                        </td>
                        <td>{{ $row->ValasSKU }}</td>
                        <td>{{ $row->ValasName }}</td>
                        <td class="text-right">{{ $qty($row->IN_Quantity) }}</td>
                        <td class="text-right">{{ $qty($row->OUT_Quantity) }}</td>
                        <td class="text-right">{{ $row->IN_ForeignAmount != 0 ? $amount($row->IN_ForeignAmount) : '' }}</td>
                        <td class="text-right">{{ $row->OUT_ForeignAmount != 0 ? $amount($row->OUT_ForeignAmount) : '' }}</td>
                        <td class="text-right">{{ $amount($row->Balance) }}</td>
                    </tr>
                @endforeach
                <tr>
                    <td class="text-right" colspan="8"><strong>TOTAL {{ $group['currency_id'] }}</strong></td>
                    <td class="text-right"><strong>{{ $amount(array_sum(array_column($group['rows'], 'IN_ForeignAmount'))) }}</strong></td>
                    <td class="text-right"><strong>{{ $amount(array_sum(array_column($group['rows'], 'OUT_ForeignAmount'))) }}</strong></td>
                    <td class="text-right"><strong>{{ $amount($group['closing']) }}</strong></td>
                </tr>
                <tr>
                    <td colspan="11">&nbsp;</td>
                </tr>
            </tbody>
        @empty
            <tbody>
                <tr><td class="text-center">Tidak ada data untuk parameter ini.</td></tr>
            </tbody>
        @endforelse
    </table>
    <!-- END REPORT DATA -->

@endsection
