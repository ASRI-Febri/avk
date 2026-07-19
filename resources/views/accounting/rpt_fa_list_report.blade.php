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
                    <td class="param-key">PROFIT CENTER</td>
                    <td class="param-value">: {{ strtoupper($fields['BranchDesc'] ?: 'ALL') }}</td>
                </tr>
                <tr>
                    <td class="param-key">PER TANGGAL</td>
                    <td class="param-value">: {{ date('d M Y', strtotime($fields['cutoff_date'])) }}</td>
                </tr>
            </table>
        </div>
    </div>
    <br/><hr><br/>
    <!-- END REPORT PARAMETER -->

    <!-- BEGIN REPORT DATA -->
    <table id="table-report" class="minimalistBlack">
        @php
            $group_number = 0;
            $group_a1 = '';
            $group_a2 = '';

            $zero = ['cost' => 0, 'accum' => 0, 'book' => 0];
            $group_total = $zero;
            $grand_total = $zero;
        @endphp
        <thead>
            <tr>
                <th>#</th>
                <th>KODE ASET</th>
                <th>NAMA ASET</th>
                <th>CABANG</th>
                <th class="text-center">TGL PEROLEHAN</th>
                <th class="text-center">UMUR (BLN)</th>
                <th class="text-center">METODE</th>
                <th class="text-center">HARGA PEROLEHAN</th>
                <th class="text-center">AKUM. PENYUSUTAN</th>
                <th class="text-center">NILAI BUKU</th>
                <th class="text-center">STATUS</th>
            </tr>
        </thead>
        <tbody>
        @if(count($records) === 0)
            <tr><td colspan="11" class="text-center"><em>Tidak ada data aset untuk parameter ini.</em></td></tr>
        @endif
        @foreach ($records as $row)

            @php
                $group_a1 = trim($row->CategoryName);
            @endphp

            @if($group_a1 <> $group_a2)

                @if($group_a2 !== '')
                    <tr>
                        <td class="text-right" colspan="7"><strong>SUB TOTAL {{ strtoupper($group_a2) }}</strong></td>
                        <td class="text-right"><strong>{{ number_format($group_total['cost'],2,'.',',') }}</strong></td>
                        <td class="text-right"><strong>{{ number_format($group_total['accum'],2,'.',',') }}</strong></td>
                        <td class="text-right"><strong>{{ number_format($group_total['book'],2,'.',',') }}</strong></td>
                        <td></td>
                    </tr>
                @endif

                <tr class="bg-info">
                    <th class="text-left" colspan="11">{{ strtoupper($group_a1) }}</th>
                </tr>

                @php
                    $group_number = 0;
                    $group_total = $zero;
                    $group_a2 = $group_a1;
                @endphp

            @endif

            @php
                $group_number += 1;
                $group_total['cost']  += $row->AcquisitionCost;
                $group_total['accum'] += $row->AccumDepr;
                $group_total['book']  += $row->BookValue;
                $grand_total['cost']  += $row->AcquisitionCost;
                $grand_total['accum'] += $row->AccumDepr;
                $grand_total['book']  += $row->BookValue;
            @endphp

            <tr>
                <td class="text-center">{{ $group_number }}</td>
                <td>{{ trim($row->AssetCode) }}</td>
                <td>{{ trim($row->AssetName) }}</td>
                <td>{{ $row->BranchName }}</td>
                <td class="text-center">{{ date('d/m/Y', strtotime($row->AcquisitionDate)) }}</td>
                <td class="text-center">{{ $row->UsefulLifeMonth }}</td>
                <td class="text-center">{{ $row->DeprMethodDesc }}</td>
                <td class="text-right">{{ number_format($row->AcquisitionCost,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->AccumDepr,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->BookValue,2,'.',',') }}</td>
                <td class="text-center">{{ $row->AssetStatusDesc }}</td>
            </tr>

        @endforeach

        @if($group_a2 !== '')
            <tr>
                <td class="text-right" colspan="7"><strong>SUB TOTAL {{ strtoupper($group_a2) }}</strong></td>
                <td class="text-right"><strong>{{ number_format($group_total['cost'],2,'.',',') }}</strong></td>
                <td class="text-right"><strong>{{ number_format($group_total['accum'],2,'.',',') }}</strong></td>
                <td class="text-right"><strong>{{ number_format($group_total['book'],2,'.',',') }}</strong></td>
                <td></td>
            </tr>
        @endif

        <tr>
            <td class="text-right" colspan="7"><strong>TOTAL</strong></td>
            <td class="text-right"><strong>{{ number_format($grand_total['cost'],2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($grand_total['accum'],2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($grand_total['book'],2,'.',',') }}</strong></td>
            <td></td>
        </tr>
        </tbody>
    </table>
    <!-- END REPORT DATA -->

@endsection
