@extends('layouts.report_data')

@section('title')
    {{ $title }}
@endsection

@section('pagetitle')
    {{ $page_title }}
@endsection

@section('content')

    @php
        // ============================================================
        // Klasifikasi baris dari USP_GL_R_StatementOfChangesInEquity
        //   RowType = 'EQUITY'    -> akun ekuitas (Saldo Awal/Penambahan/Pengurangan/Saldo Akhir)
        //   RowType = 'NETINCOME' -> Laba/(Rugi) Bersih Periode Berjalan
        // ============================================================
        $equityRows = [];
        $netIncome  = 0;

        foreach ($records as $row) {
            if (trim($row->RowType) === 'NETINCOME') {
                $netIncome = (float) $row->EndBalance;
                continue;
            }
            $equityRows[] = $row;
        }

        $totalBegin      = 0;
        $totalAdditions  = 0;
        $totalReductions = 0;
        $totalEnd        = 0;

        foreach ($equityRows as $row) {
            $totalBegin      += (float) $row->BeginBalance;
            $totalAdditions  += (float) $row->Additions;
            $totalReductions += (float) $row->Reductions;
            $totalEnd        += (float) $row->EndBalance;
        }

        // Total perubahan & saldo akhir ekuitas (termasuk laba bersih periode berjalan)
        $totalChange   = ($totalAdditions - $totalReductions) + $netIncome;
        $endingEquity  = $totalBegin + $totalChange;

        $periodLabel = $fields['Period'];
        $dt = DateTime::createFromFormat('Ym', $fields['Period']);
        if ($dt) { $periodLabel = $dt->format('M Y'); }
    @endphp

    <!-- BEGIN REPORT PARAMETER -->
    <div style="width:100%;">
        <div style="float:left;width:70%;">
            <table>
                <tr>
                    <td class="param-key">Periode</td>
                    <td class="param-value">: {{ $periodLabel }}</td>
                </tr>
                <tr>
                    <td class="param-key">Metode</td>
                    <td class="param-value">: Movement Approach (basis Trial Balance)</td>
                </tr>
            </table>
        </div>
    </div>
    <br/>
    <hr>
    <br/>
    <!-- END REPORT PARAMETER -->

    <!-- BEGIN REPORT DATA -->
    <table id="table-report" class="minimalistBlack" style="width:100%;">
        <thead>
            <tr>
                <th style="width:4%;">#</th>
                <th style="width:12%;">COA</th>
                <th>KETERANGAN</th>
                <th class="text-center" style="width:16%;">SALDO AWAL</th>
                <th class="text-center" style="width:16%;">PENAMBAHAN</th>
                <th class="text-center" style="width:16%;">PENGURANGAN</th>
                <th class="text-center" style="width:16%;">SALDO AKHIR</th>
            </tr>
        </thead>
        <tbody>

            <tr class="bg-info">
                <th class="text-left" colspan="7">SALDO EKUITAS</th>
            </tr>

            @if(count($equityRows) == 0)
                <tr>
                    <td class="text-center">-</td>
                    <td></td>
                    <td><em>(tidak ada data ekuitas)</em></td>
                    <td class="text-right">0.00</td>
                    <td class="text-right">0.00</td>
                    <td class="text-right">0.00</td>
                    <td class="text-right">0.00</td>
                </tr>
            @else
                @foreach($equityRows as $i => $row)
                    <tr>
                        <td class="text-center">{{ $i + 1 }}</td>
                        <td class="text-center">{{ $row->COA }}</td>
                        <td>{{ $row->COADesc }}</td>
                        <td class="text-right">{{ number_format($row->BeginBalance, 2, '.', ',') }}</td>
                        <td class="text-right">{{ number_format($row->Additions, 2, '.', ',') }}</td>
                        <td class="text-right">{{ number_format($row->Reductions, 2, '.', ',') }}</td>
                        <td class="text-right">{{ number_format($row->EndBalance, 2, '.', ',') }}</td>
                    </tr>
                @endforeach
            @endif

            {{-- Laba/(Rugi) Bersih Periode Berjalan --}}
            <tr>
                <td class="text-center">{{ count($equityRows) + 1 }}</td>
                <td></td>
                <td>Laba/(Rugi) Bersih Periode Berjalan</td>
                <td class="text-right">0.00</td>
                <td class="text-right">{{ number_format($netIncome, 2, '.', ',') }}</td>
                <td class="text-right">0.00</td>
                <td class="text-right">{{ number_format($netIncome, 2, '.', ',') }}</td>
            </tr>

            {{-- ============================================================ --}}
            {{-- TOTAL                                                        --}}
            {{-- ============================================================ --}}
            <tr class="bg-info">
                <td colspan="3" class="text-right"><strong>TOTAL PERUBAHAN EKUITAS</strong></td>
                <td class="text-right"><strong>{{ number_format($totalBegin, 2, '.', ',') }}</strong></td>
                <td class="text-right"><strong>{{ number_format($totalAdditions + $netIncome, 2, '.', ',') }}</strong></td>
                <td class="text-right"><strong>{{ number_format($totalReductions, 2, '.', ',') }}</strong></td>
                <td class="text-right"><strong>{{ number_format($endingEquity, 2, '.', ',') }}</strong></td>
            </tr>

            <tr><td colspan="7">&nbsp;</td></tr>

            {{-- ============================================================ --}}
            {{-- RINGKASAN                                                    --}}
            {{-- ============================================================ --}}
            <tr class="bg-info">
                <th class="text-left" colspan="7">RINGKASAN PERUBAHAN EKUITAS</th>
            </tr>
            <tr>
                <td colspan="6" class="text-right">Total Saldo Awal Ekuitas</td>
                <td class="text-right">{{ number_format($totalBegin, 2, '.', ',') }}</td>
            </tr>
            <tr>
                <td colspan="6" class="text-right">Penambahan Modal (Setoran)</td>
                <td class="text-right">{{ number_format($totalAdditions, 2, '.', ',') }}</td>
            </tr>
            <tr>
                <td colspan="6" class="text-right">Pengurangan Modal (Prive/Dividen)</td>
                <td class="text-right">({{ number_format($totalReductions, 2, '.', ',') }})</td>
            </tr>
            <tr>
                <td colspan="6" class="text-right">Laba/(Rugi) Bersih Periode Berjalan</td>
                <td class="text-right">{{ number_format($netIncome, 2, '.', ',') }}</td>
            </tr>
            <tr>
                <td colspan="6" class="text-right"><strong>KENAIKAN / (PENURUNAN) BERSIH EKUITAS</strong></td>
                <td class="text-right"><strong>{{ number_format($totalChange, 2, '.', ',') }}</strong></td>
            </tr>
            <tr>
                <td colspan="6" class="text-right"><strong>TOTAL SALDO AKHIR EKUITAS</strong></td>
                <td class="text-right"><strong>{{ number_format($endingEquity, 2, '.', ',') }}</strong></td>
            </tr>
        </tbody>
    </table>
    <!-- END REPORT DATA -->

@endsection
