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
                    <td class="param-key">COMPANY</td>
                    <td class="param-value">: {{ strtoupper($fields['CompanyDesc'] ?? '') }}</td>
                </tr>
                <tr>
                    <td class="param-key">PERIODE</td>
                    <td class="param-value">: {{ DateTime::createFromFormat('Ym', $fields['Period'])->format('M Y') }}</td>
                </tr>
            </table>
        </div>
    </div>
    <br/><hr><br/>
    <!-- END REPORT PARAMETER -->

    <!-- BEGIN REPORT DATA -->
    <table id="table-report" class="minimalistBlack">
        @php
            $total_depr = 0;
            $total_fiscal = 0;
        @endphp
        <thead>
            <tr>
                <th>#</th>
                <th>KODE ASET</th>
                <th>NAMA ASET</th>
                <th>KATEGORI</th>
                <th>CABANG</th>
                <th class="text-center">METODE</th>
                <th class="text-center">HARGA PEROLEHAN</th>
                <th class="text-center">PENYUSUTAN KOMERSIAL</th>
                <th class="text-center">PENYUSUTAN FISKAL</th>
                <th class="text-center">AKUM. SETELAH</th>
                <th class="text-center">NILAI BUKU SETELAH</th>
            </tr>
        </thead>
        <tbody>
        @if(count($records) === 0)
            <tr><td colspan="11" class="text-center"><em>Belum ada perhitungan penyusutan untuk periode ini.</em></td></tr>
        @endif
        @foreach ($records as $i => $row)
            @php
                $total_depr += $row->DeprAmount;
                $total_fiscal += $row->FiscalDeprAmount;
            @endphp
            <tr>
                <td class="text-center">{{ $i + 1 }}</td>
                <td>{{ trim($row->AssetCode) }}</td>
                <td>{{ trim($row->AssetName) }}</td>
                <td>{{ $row->CategoryName }}</td>
                <td>{{ $row->BranchName }}</td>
                <td class="text-center">{{ $row->DeprMethodDesc }}</td>
                <td class="text-right">{{ number_format($row->AcquisitionCost,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->DeprAmount,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->FiscalDeprAmount,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->AccumDeprAfter,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->BookValueAfter,2,'.',',') }}</td>
            </tr>
        @endforeach
        <tr>
            <td class="text-right" colspan="7"><strong>TOTAL</strong></td>
            <td class="text-right"><strong>{{ number_format($total_depr,2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($total_fiscal,2,'.',',') }}</strong></td>
            <td></td>
            <td></td>
        </tr>
        </tbody>
    </table>
    <!-- END REPORT DATA -->

@endsection
