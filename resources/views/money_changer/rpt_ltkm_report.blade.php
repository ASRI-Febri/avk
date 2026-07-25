@extends('layouts.report_data')

@section('title')
    {{ $title }}
@endsection

@section('pagetitle')
    {{ $page_title }}
@endsection

@section('content')

    <!-- BEGIN REPORT PARAMETER -->
    <div style="width:100%;">
        <div style="float:left;width:70%;">
            <table>
                <tr>
                    <td class="param-key">PERIODE</td>
                    <td class="param-value">: {{ $PeriodDesc }} ({{ $LTKMPeriod }})</td>
                </tr>
                <tr>
                    <td class="param-key">KRITERIA</td>
                    <td class="param-value">: Transaksi yang ditetapkan sebagai TKM (tidak ada batasan nominal)</td>
                </tr>
                <tr>
                    <td class="param-key">BATAS LAPOR</td>
                    <td class="param-value">: 3 hari sejak ditetapkan sebagai TKM</td>
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
        @php
            $row_number = 0;
            $total_sales = 0;
            $total_cash = 0;
        @endphp
        <thead>
            <tr>
                <th>#</th>
                <th>TANGGAL</th>
                <th>NO TRANSAKSI</th>
                <th>KODE NASABAH</th>
                <th>NAMA NASABAH</th>
                <th>NO KTP</th>
                <th>ALAMAT</th>
                <th class="text-center">DTTOT</th>
                <th class="text-center">TOTAL PENJUALAN</th>
                <th class="text-center">PEMBAYARAN TUNAI</th>
                <th class="text-center">TANGGAL TKM</th>
                <th>INDIKATOR</th>
                <th class="text-center">BATAS LAPOR</th>
            </tr>
        </thead>
        <tbody>
        @if($records)
        @foreach($records as $row)
            @php
                $row_number++;
                $total_sales += $row->TotalSalesAmount;
                $total_cash += $row->PaymentCashAmount;
            @endphp
            <tr>
                <td>{{ $row_number }}</td>
                <td>{{ date('d M Y', strtotime($row->TransactionDate)) }}</td>
                <td>
                    <a href="{{ url('mc-sales-order/update') . '/' . $row->IDX_T_SalesOrder }}" target="_blank">{{ $row->SONumber }}</a>
                </td>
                <td style="mso-number-format:'\@';">{{ $row->PartnerID }}</td>
                <td>{{ $row->PartnerName }}</td>
                <td style="mso-number-format:'\@';">{{ $row->SingleIdentityNumber }}</td>
                <td>{{ $row->Street }}</td>
                <td class="text-center">{{ trim($row->IsDTTOT) == 'Y' ? 'Y' : '' }}</td>
                <td class="text-right">{{ number_format($row->TotalSalesAmount,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->PaymentCashAmount,2,'.',',') }}</td>
                <td>{{ $row->TKMDate ? date('d M Y', strtotime($row->TKMDate)) : '' }}</td>
                <td>{{ $row->TKMIndicator }}</td>
                <td>{{ $row->ReportDueDate ? date('d M Y', strtotime($row->ReportDueDate)) : '' }}</td>
            </tr>
        @endforeach
        @endif

        @if($row_number == 0)
            <tr>
                <td colspan="13" class="text-center">
                    Tidak ada data LTKM untuk periode {{ $PeriodDesc }}. Jalankan Proses LTKM terlebih dahulu.
                </td>
            </tr>
        @else
            <tr>
                <td class="text-right" colspan="8"><strong>TOTAL</strong></td>
                <td class="text-right"><strong>{{ number_format($total_sales,2,'.',',') }}</strong></td>
                <td class="text-right"><strong>{{ number_format($total_cash,2,'.',',') }}</strong></td>
                <td></td>
                <td></td>
                <td></td>
            </tr>
        @endif
        </tbody>
    </table>
    <!-- END REPORT DATA -->

@endsection
