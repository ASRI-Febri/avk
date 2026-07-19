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
            $total = [
                'reg_cost' => 0, 'gl_cost' => 0, 'diff_cost' => 0,
                'reg_accum' => 0, 'gl_accum' => 0, 'diff_accum' => 0,
            ];
            $all_balanced = true;
        @endphp
        <thead>
            <tr>
                <th rowspan="2">#</th>
                <th rowspan="2">KATEGORI</th>
                <th rowspan="2" class="text-center">JML ASET</th>
                <th colspan="3" class="text-center">HARGA PEROLEHAN (AKUN ASET)</th>
                <th colspan="3" class="text-center">AKUMULASI PENYUSUTAN</th>
            </tr>
            <tr>
                <th class="text-center">REGISTER</th>
                <th class="text-center">SALDO GL</th>
                <th class="text-center">SELISIH</th>
                <th class="text-center">REGISTER</th>
                <th class="text-center">SALDO GL</th>
                <th class="text-center">SELISIH</th>
            </tr>
        </thead>
        <tbody>
        @if(count($records) === 0)
            <tr><td colspan="9" class="text-center"><em>Tidak ada data untuk direkonsiliasi.</em></td></tr>
        @endif
        @foreach ($records as $i => $row)
            @php
                $total['reg_cost']   += $row->RegisterCost;
                $total['gl_cost']    += $row->GLAssetBalance;
                $total['diff_cost']  += $row->DiffAsset;
                $total['reg_accum']  += $row->RegisterAccum;
                $total['gl_accum']   += $row->GLAccumBalance;
                $total['diff_accum'] += $row->DiffAccum;

                $row_balanced = (abs($row->DiffAsset) < 0.01 && abs($row->DiffAccum) < 0.01);
                if (!$row_balanced) { $all_balanced = false; }
            @endphp
            <tr>
                <td class="text-center">{{ $i + 1 }}</td>
                <td>
                    {{ trim($row->CategoryCode) }} - {{ trim($row->CategoryName) }}<br>
                    <small>Aset: {{ $row->COAAsset }}</small><br>
                    <small>Akum: {{ $row->COAAccum }}</small>
                </td>
                <td class="text-center">{{ $row->AssetCount }}</td>
                <td class="text-right">{{ number_format($row->RegisterCost,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->GLAssetBalance,2,'.',',') }}</td>
                <td class="text-right">
                    @if(abs($row->DiffAsset) < 0.01)
                        <span style="color:green;">0.00</span>
                    @else
                        <span style="color:red;"><strong>{{ number_format($row->DiffAsset,2,'.',',') }}</strong></span>
                    @endif
                </td>
                <td class="text-right">{{ number_format($row->RegisterAccum,2,'.',',') }}</td>
                <td class="text-right">{{ number_format($row->GLAccumBalance,2,'.',',') }}</td>
                <td class="text-right">
                    @if(abs($row->DiffAccum) < 0.01)
                        <span style="color:green;">0.00</span>
                    @else
                        <span style="color:red;"><strong>{{ number_format($row->DiffAccum,2,'.',',') }}</strong></span>
                    @endif
                </td>
            </tr>
        @endforeach
        <tr>
            <td class="text-right" colspan="3"><strong>TOTAL</strong></td>
            <td class="text-right"><strong>{{ number_format($total['reg_cost'],2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($total['gl_cost'],2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($total['diff_cost'],2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($total['reg_accum'],2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($total['gl_accum'],2,'.',',') }}</strong></td>
            <td class="text-right"><strong>{{ number_format($total['diff_accum'],2,'.',',') }}</strong></td>
        </tr>
        <tr>
            <td colspan="9" class="text-center">
                @if($all_balanced && count($records) > 0)
                    <strong style="color:green;">SELURUH KATEGORI BALANCED — register aset sinkron dengan GL.</strong>
                @elseif(count($records) > 0)
                    <strong style="color:red;">ADA SELISIH — periksa kategori bertanda merah.
                    Kemungkinan penyebab: jurnal perolehan aset lama belum diinput / saldo awal migrasi belum sama dengan saldo akun GL /
                    satu akun COA dipakai lebih dari satu kategori (bandingkan gabungan).</strong>
                @endif
            </td>
        </tr>
        </tbody>
    </table>
    <!-- END REPORT DATA -->

@endsection
