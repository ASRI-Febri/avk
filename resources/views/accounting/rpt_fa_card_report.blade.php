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
                @if(!empty($asset_info))
                <tr>
                    <td class="param-key">KODE ASET</td>
                    <td class="param-value">: {{ trim($asset_info->AssetCode) }}</td>
                </tr>
                <tr>
                    <td class="param-key">NAMA ASET</td>
                    <td class="param-value">: {{ trim($asset_info->AssetName) }}</td>
                </tr>
                <tr>
                    <td class="param-key">KATEGORI</td>
                    <td class="param-value">: {{ trim($asset_info->CategoryName) }}</td>
                </tr>
                <tr>
                    <td class="param-key">HARGA PEROLEHAN</td>
                    <td class="param-value">: {{ number_format((float) $asset_info->AcquisitionCost,2,'.',',') }}</td>
                </tr>
                <tr>
                    <td class="param-key">UMUR / METODE</td>
                    <td class="param-value">: {{ $asset_info->UsefulLifeMonth }} bulan /
                        {{ trim($asset_info->DeprMethod) == 'SL' ? 'Garis Lurus' : 'Saldo Menurun' }}</td>
                </tr>
                <tr>
                    <td class="param-key">STATUS</td>
                    <td class="param-value">: {{ trim($asset_info->AssetStatusDesc) }}</td>
                </tr>
                @endif
            </table>
        </div>
    </div>
    <br/><hr><br/>
    <!-- END REPORT PARAMETER -->

    <!-- BEGIN REPORT DATA -->
    <table id="table-report" class="minimalistBlack">
        <thead>
            <tr>
                <th>#</th>
                <th class="text-center">TANGGAL</th>
                <th class="text-center">TIPE</th>
                <th>KETERANGAN</th>
                <th class="text-center">NILAI</th>
                <th class="text-center">AKUM. PENYUSUTAN</th>
                <th class="text-center">NILAI BUKU</th>
            </tr>
        </thead>
        <tbody>
        @if(count($records) === 0)
            <tr><td colspan="7" class="text-center"><em>Belum ada riwayat untuk aset ini.</em></td></tr>
        @endif
        @foreach ($records as $i => $row)
            <tr>
                <td class="text-center">{{ $i + 1 }}</td>
                <td class="text-center">{{ date('d/m/Y', strtotime($row->EventDate)) }}</td>
                <td class="text-center">{{ $row->EventType }}</td>
                <td>{{ $row->EventDesc }}</td>
                <td class="text-right">{{ $row->Amount !== null ? number_format($row->Amount,2,'.',',') : '-' }}</td>
                <td class="text-right">{{ $row->AccumAfter !== null ? number_format($row->AccumAfter,2,'.',',') : '-' }}</td>
                <td class="text-right">{{ $row->BookValueAfter !== null ? number_format($row->BookValueAfter,2,'.',',') : '-' }}</td>
            </tr>
        @endforeach
        </tbody>
    </table>
    <!-- END REPORT DATA -->

@endsection
