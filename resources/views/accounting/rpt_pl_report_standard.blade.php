@extends('layouts.report_data')

@section('title')
    {{ $title }}
@endsection

@section('pagetitle')
    {{ $page_title }}
@endsection

@section('content')

    @php
        // Klasifikasi berdasarkan COAGroupDesc (dengan fallback COAGroupID utk EX non-HPP)
        //  - "Pendapatan Usaha"         -> Pendapatan Operasional (PO)  [IC]
        //  - "Harga Pokok Penjualan"    -> HPP                          [EX]
        //  - IC lain                    -> Pendapatan Lain-lain (PL)
        //  - EX dengan COAGroupID 6xxx  -> Biaya Operasional (BO)
        //  - EX lain (mis. 8xxx)        -> Biaya Lain-lain (BL)
        //
        // Setiap baris dihitung dalam 3 kolom:
        //  - prior   : awal tahun s/d bulan sebelum periode (BBBalanceAmount)
        //  - current : mutasi periode berjalan (BDebetAmount - BCreditAmount)
        //  - ytd     : year-to-date s/d akhir periode (BEBalanceAmount)
        $zero = ['prior' => 0, 'current' => 0, 'ytd' => 0];

        $sections = [
            'PO'  => ['title' => 'PENDAPATAN USAHA',       'rows' => [], 'total' => $zero],
            'HPP' => ['title' => 'HARGA POKOK PENJUALAN',  'rows' => [], 'total' => $zero],
            'PL'  => ['title' => 'PENDAPATAN LAIN-LAIN',   'rows' => [], 'total' => $zero],
            'BO'  => ['title' => 'BIAYA OPERASIONAL',      'rows' => [], 'total' => $zero],
            'BL'  => ['title' => 'BIAYA LAIN-LAIN',        'rows' => [], 'total' => $zero],
        ];

        foreach ($records as $row) {
            $sign = ($row->AccountType == 'IC') ? -1 : 1;

            $amounts = [
                'prior'   => $sign * (float) $row->BBBalanceAmount,
                'current' => $sign * ((float) $row->BDebetAmount - (float) $row->BCreditAmount),
                'ytd'     => $sign * (float) $row->BEBalanceAmount,
            ];

            $desc  = trim($row->COAGroupDesc ?? '');
            $first = substr(trim($row->COAGroupID ?? ''), 0, 1);

            if ($row->AccountType == 'IC') {
                $key = ($desc === 'Pendapatan Usaha') ? 'PO' : 'PL';
            } else {
                if ($desc === 'Harga Pokok Penjualan') {
                    $key = 'HPP';
                } else if ($first === '6') {
                    $key = 'BO';
                } else {
                    $key = 'BL';
                }
            }

            $sections[$key]['rows'][] = ['row' => $row, 'amounts' => $amounts];
            foreach ($amounts as $col => $val) {
                $sections[$key]['total'][$col] += $val;
            }
        }

        // Perhitungan per kolom (prior / current / ytd)
        $pendapatan_kotor = $zero;
        $subtotal_lain    = $zero;
        $total_pendapatan = $zero;
        $total_biaya      = $zero;
        $laba_bersih      = $zero;

        foreach (array_keys($zero) as $col) {
            $pendapatan_kotor[$col] = $sections['PO']['total'][$col] - $sections['HPP']['total'][$col];
            $total_biaya_lain       = $sections['BO']['total'][$col] + $sections['BL']['total'][$col];
            $subtotal_lain[$col]    = $sections['PL']['total'][$col] - $total_biaya_lain;

            $total_pendapatan[$col] = $sections['PO']['total'][$col]  + $sections['PL']['total'][$col];
            $total_biaya[$col]      = $sections['HPP']['total'][$col] + $sections['BO']['total'][$col] + $sections['BL']['total'][$col];
            $laba_bersih[$col]      = $total_pendapatan[$col] - $total_biaya[$col];
        }

        // Label kolom dinamis dari periode terpilih (YYYYMM)
        $bulan_id = [1=>'Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
        $p_year  = (int) substr($fields['Period'], 0, 4);
        $p_month = (int) substr($fields['Period'], 4, 2);

        $label_current = ($bulan_id[$p_month] ?? '?') . ' ' . $p_year;
        if ($p_month <= 1) {
            $label_prior = '-';
        } elseif ($p_month == 2) {
            $label_prior = 'Jan ' . $p_year;
        } else {
            $label_prior = 'Jan - ' . $bulan_id[$p_month - 1] . ' ' . $p_year;
        }
        $label_ytd = 'YTD ' . $label_current;
    @endphp

    <!-- BEGIN REPORT PARAMETER -->
    <div style="width:100%;">
        <div style="float:left;width:70%;">
            <table>
                <tr>
                    <td class="param-key">Profit &amp; Loss Period</td>
                    <td class="param-value">: {{ DateTime::createFromFormat('Ym', $fields['Period'])->format('M Y') }}</td>
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
                <th rowspan="2" style="width:4%;">#</th>
                <th rowspan="2" style="width:12%;">COA</th>
                <th rowspan="2">COA DESCRIPTION</th>
                <th colspan="3" class="text-center" style="width:48%;">AMOUNT</th>
            </tr>
            <tr>
                <th class="text-center" style="width:16%;">{{ $label_prior }}</th>
                <th class="text-center" style="width:16%;">{{ $label_current }}</th>
                <th class="text-center" style="width:16%;">{{ $label_ytd }}</th>
            </tr>
        </thead>
        <tbody>

            {{-- ============================================================ --}}
            {{-- BAGIAN 1: PENDAPATAN USAHA - HPP = PENDAPATAN KOTOR           --}}
            {{-- ============================================================ --}}

            @foreach (['PO','HPP'] as $skey)
                @php $sec = $sections[$skey]; @endphp
                <tr class="bg-info">
                    <th class="text-left" colspan="6">{{ $sec['title'] }}</th>
                </tr>

                @if(count($sec['rows']) == 0)
                    <tr>
                        <td class="text-center">-</td>
                        <td></td>
                        <td><em>(tidak ada data)</em></td>
                        <td class="text-right">0.00</td>
                        <td class="text-right">0.00</td>
                        <td class="text-right">0.00</td>
                    </tr>
                @else
                    @foreach($sec['rows'] as $i => $item)
                        <tr>
                            <td class="text-center">{{ $i + 1 }}</td>
                            <td class="text-center">{{ $item['row']->COA }}</td>
                            <td>{{ $item['row']->COADesc }}</td>
                            <td class="text-right">{{ number_format($item['amounts']['prior'], 2, '.', ',') }}</td>
                            <td class="text-right">{{ number_format($item['amounts']['current'], 2, '.', ',') }}</td>
                            <td class="text-right">{{ number_format($item['amounts']['ytd'], 2, '.', ',') }}</td>
                        </tr>
                    @endforeach
                @endif

                <tr>
                    <td colspan="3" class="text-right"><span class="total">Total {{ $sec['title'] }}</span></td>
                    <td class="text-right"><span class="total">{{ number_format($sec['total']['prior'], 2, '.', ',') }}</span></td>
                    <td class="text-right"><span class="total">{{ number_format($sec['total']['current'], 2, '.', ',') }}</span></td>
                    <td class="text-right"><span class="total">{{ number_format($sec['total']['ytd'], 2, '.', ',') }}</span></td>
                </tr>
            @endforeach

            <tr>
                <td colspan="3" class="text-right">
                    <strong>PENDAPATAN KOTOR (Pendapatan Usaha - HPP)</strong>
                </td>
                <td class="text-right"><strong>{{ number_format($pendapatan_kotor['prior'], 2, '.', ',') }}</strong></td>
                <td class="text-right"><strong>{{ number_format($pendapatan_kotor['current'], 2, '.', ',') }}</strong></td>
                <td class="text-right"><strong>{{ number_format($pendapatan_kotor['ytd'], 2, '.', ',') }}</strong></td>
            </tr>

            {{-- spacer --}}
            <tr><td colspan="6">&nbsp;</td></tr>

            {{-- ============================================================ --}}
            {{-- BAGIAN 2: PENDAPATAN LAIN-LAIN - (BIAYA OPS + BIAYA LAIN-LAIN)--}}
            {{-- ============================================================ --}}

            @foreach (['PL','BO','BL'] as $skey)
                @php $sec = $sections[$skey]; @endphp
                <tr class="bg-info">
                    <th class="text-left" colspan="6">{{ $sec['title'] }}</th>
                </tr>

                @if(count($sec['rows']) == 0)
                    <tr>
                        <td class="text-center">-</td>
                        <td></td>
                        <td><em>(tidak ada data)</em></td>
                        <td class="text-right">0.00</td>
                        <td class="text-right">0.00</td>
                        <td class="text-right">0.00</td>
                    </tr>
                @else
                    @foreach($sec['rows'] as $i => $item)
                        <tr>
                            <td class="text-center">{{ $i + 1 }}</td>
                            <td class="text-center">{{ $item['row']->COA }}</td>
                            <td>{{ $item['row']->COADesc }}</td>
                            <td class="text-right">{{ number_format($item['amounts']['prior'], 2, '.', ',') }}</td>
                            <td class="text-right">{{ number_format($item['amounts']['current'], 2, '.', ',') }}</td>
                            <td class="text-right">{{ number_format($item['amounts']['ytd'], 2, '.', ',') }}</td>
                        </tr>
                    @endforeach
                @endif

                <tr>
                    <td colspan="3" class="text-right"><span class="total">Total {{ $sec['title'] }}</span></td>
                    <td class="text-right"><span class="total">{{ number_format($sec['total']['prior'], 2, '.', ',') }}</span></td>
                    <td class="text-right"><span class="total">{{ number_format($sec['total']['current'], 2, '.', ',') }}</span></td>
                    <td class="text-right"><span class="total">{{ number_format($sec['total']['ytd'], 2, '.', ',') }}</span></td>
                </tr>
            @endforeach

            <tr>
                <td colspan="3" class="text-right">
                    <strong>SUBTOTAL LAIN-LAIN (Pendapatan Lain-lain - (Biaya Operasional + Biaya Lain-lain))</strong>
                </td>
                <td class="text-right"><strong>{{ number_format($subtotal_lain['prior'], 2, '.', ',') }}</strong></td>
                <td class="text-right"><strong>{{ number_format($subtotal_lain['current'], 2, '.', ',') }}</strong></td>
                <td class="text-right"><strong>{{ number_format($subtotal_lain['ytd'], 2, '.', ',') }}</strong></td>
            </tr>

            {{-- spacer --}}
            <tr><td colspan="6">&nbsp;</td></tr>

            {{-- ============================================================ --}}
            {{-- GRAND TOTAL                                                   --}}
            {{-- ============================================================ --}}
            <tr class="bg-info">
                <th class="text-left" colspan="3">RINGKASAN</th>
                <th class="text-center">{{ $label_prior }}</th>
                <th class="text-center">{{ $label_current }}</th>
                <th class="text-center">{{ $label_ytd }}</th>
            </tr>
            <tr>
                <td colspan="3" class="text-right"><strong>TOTAL PENDAPATAN</strong></td>
                <td class="text-right"><strong>{{ number_format($total_pendapatan['prior'], 2, '.', ',') }}</strong></td>
                <td class="text-right"><strong>{{ number_format($total_pendapatan['current'], 2, '.', ',') }}</strong></td>
                <td class="text-right"><strong>{{ number_format($total_pendapatan['ytd'], 2, '.', ',') }}</strong></td>
            </tr>
            <tr>
                <td colspan="3" class="text-right"><strong>TOTAL BIAYA</strong></td>
                <td class="text-right"><strong>{{ number_format($total_biaya['prior'], 2, '.', ',') }}</strong></td>
                <td class="text-right"><strong>{{ number_format($total_biaya['current'], 2, '.', ',') }}</strong></td>
                <td class="text-right"><strong>{{ number_format($total_biaya['ytd'], 2, '.', ',') }}</strong></td>
            </tr>
            <tr>
                <td colspan="3" class="text-right">
                    <strong>LABA / (RUGI) BERSIH (Total Pendapatan - Total Biaya)</strong>
                </td>
                <td class="text-right"><strong>{{ number_format($laba_bersih['prior'], 2, '.', ',') }}</strong></td>
                <td class="text-right"><strong>{{ number_format($laba_bersih['current'], 2, '.', ',') }}</strong></td>
                <td class="text-right"><strong>{{ number_format($laba_bersih['ytd'], 2, '.', ',') }}</strong></td>
            </tr>
        </tbody>
    </table>
    <!-- END REPORT DATA -->

@endsection
