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
                    <td class="param-key">TAHUN PAJAK</td>
                    <td class="param-value">: {{ $fields['TaxYear'] }}</td>
                </tr>
                <tr>
                    <td class="param-key">FORMAT</td>
                    <td class="param-value">: Daftar Penyusutan Fiskal (Lampiran Khusus 1A SPT Tahunan PPh Badan)</td>
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

            $zero = ['cost' => 0, 'begin' => 0, 'depr' => 0, 'end' => 0];
            $group_total = $zero;
            $grand_total = $zero;
        @endphp
        <thead>
            <tr>
                <th rowspan="2">#</th>
                <th rowspan="2">KODE ASET</th>
                <th rowspan="2">JENIS HARTA</th>
                <th rowspan="2" class="text-center">BLN/THN PEROLEHAN</th>
                <th rowspan="2" class="text-center">HARGA PEROLEHAN</th>
                <th rowspan="2" class="text-center">NILAI SISA BUKU FISKAL AWAL TAHUN</th>
                <th colspan="2" class="text-center">METODE PENYUSUTAN</th>
                <th rowspan="2" class="text-center">PENYUSUTAN FISKAL {{ $fields['TaxYear'] }}</th>
                <th rowspan="2" class="text-center">NILAI SISA BUKU FISKAL AKHIR TAHUN</th>
            </tr>
            <tr>
                <th class="text-center">KOMERSIAL</th>
                <th class="text-center">FISKAL</th>
            </tr>
        </thead>
        <tbody>
        @if(count($records) === 0)
            <tr><td colspan="10" class="text-center"><em>Tidak ada aset dengan kelompok fiskal untuk tahun pajak ini.</em></td></tr>
        @endif
        @foreach ($records as $row)

            @php
                $group_a1 = trim($row->FiscalGroupDesc);
            @endphp

            @if($group_a1 <> $group_a2)

                @if($group_a2 !== '')
                    <tr>
                        <td class="text-right" colspan="4"><strong>SUB TOTAL {{ strtoupper($group_a2) }}</strong></td>
                        <td class="text-right"><strong>{{ number_format($group_total['cost'],2,'.',',') }}</strong></td>
                        <td class="text-right"><strong>{{ number_format($group_total['begin'],2,'.',',') }}</strong></td>
                        <td colspan="2"></td>
                        <td class="text-right"><strong>{{ number_format($group_total['depr'],2,'.',',') }}</strong></td>
                        <td class="text-right"><strong>{{ number_format($group_total['end'],2,'.',',') }}</strong></td>
                    </tr>
                @endif

                <tr class="bg-info">
                    <th class="text-left" colspan="10">{{ strtoupper($group_a1) }}</th>
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
                $group_total['begin'] += $row->FiscalBookValueBegin;
                $group_total['depr']  += $row->FiscalDeprCurrentYear;
                $group_total['end']   += $row->FiscalBookValueEnd;
                $grand_total['cost']  += $row->AcquisitionCost;
                $grand_total['begin'] += $row->FiscalBookValueBegin;
                $grand_total['depr']  += $row->FiscalDeprCurrentYear;
                $grand_total['end']   += $row->FiscalBookValueEnd;
            @endphp

            <tr>
                <td class="text-center">{{ $group_number }}</td>
                <td>{{ trim($row->AssetCode) }}</td>
                <td>{{ trim($row->AssetName) }}</td>
                <td class="text-center">{{ $row->AcquisitionMonthYear }}</td>
                <td class="text-right">{{ number_format($row->AcquisitionCost,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->FiscalBookValueBegin,2,'.',',') }}</td>
                <td class="text-center">{{ $row->DeprMethodDesc }}</td>
                <td class="text-center">{{ $row->FiscalMethodDesc }}</td>
                <td class="text-right">{{ number_format($row->FiscalDeprCurrentYear,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->FiscalBookValueEnd,2,'.',',') }}</td>
            </tr>

        @endforeach

        @if($group_a2 !== '')
            <tr>
                <td class="text-right" colspan="4"><strong>SUB TOTAL {{ strtoupper($group_a2) }}</strong></td>
                <td class="text-right"><strong>{{ number_format($group_total['cost'],2,'.',',') }}</strong></td>
                <td class="text-right"><strong>{{ number_format($group_total['begin'],2,'.',',') }}</strong></td>
                <td colspan="2"></td>
                <td class="text-right"><strong>{{ number_format($group_total['depr'],2,'.',',') }}</strong></td>
                <td class="text-right"><strong>{{ number_format($group_total['end'],2,'.',',') }}</strong></td>
            </tr>
        @endif

        <tr>
            <td class="text-right" colspan="4"><strong>TOTAL</strong></td>
            <td class="text-right"><strong>{{ number_format($grand_total['cost'],2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($grand_total['begin'],2,'.',',') }}</strong></td>
            <td colspan="2"></td>
            <td class="text-right"><strong>{{ number_format($grand_total['depr'],2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($grand_total['end'],2,'.',',') }}</strong></td>
        </tr>
        </tbody>
    </table>
    <!-- END REPORT DATA -->

@endsection
