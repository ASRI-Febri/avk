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
        $sections = [
            'PO'  => ['title' => 'PENDAPATAN USAHA',       'rows' => [], 'total' => 0],
            'HPP' => ['title' => 'HARGA POKOK PENJUALAN',  'rows' => [], 'total' => 0],
            'PL'  => ['title' => 'PENDAPATAN LAIN-LAIN',   'rows' => [], 'total' => 0],
            'BO'  => ['title' => 'BIAYA OPERASIONAL',      'rows' => [], 'total' => 0],
            'BL'  => ['title' => 'BIAYA LAIN-LAIN',        'rows' => [], 'total' => 0],
        ];

        foreach ($records as $row) {
            $amount = ($row->AccountType == 'IC')
                ? ($row->BEBalanceAmount * -1)
                : $row->BEBalanceAmount;

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

            $sections[$key]['rows'][]  = ['row' => $row, 'amount' => $amount];
            $sections[$key]['total']  += $amount;
        }

        // Perhitungan
        $pendapatan_kotor    = $sections['PO']['total']  - $sections['HPP']['total'];   // Laba Kotor / Gross Profit
        $total_biaya_lain    = $sections['BO']['total']  + $sections['BL']['total'];
        $subtotal_lain       = $sections['PL']['total']  - $total_biaya_lain;           // Pend Lain - (BO + BL)

        $total_pendapatan    = $sections['PO']['total']  + $sections['PL']['total'];
        $total_biaya         = $sections['HPP']['total'] + $sections['BO']['total'] + $sections['BL']['total'];
        $laba_bersih         = $total_pendapatan - $total_biaya;
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
                <th style="width:5%;">#</th>
                <th style="width:15%;">COA</th>
                <th>COA DESCRIPTION</th>
                <th class="text-center" style="width:18%;">AMOUNT</th>
                <th class="text-center" style="width:20%;">SUBTOTAL</th>
            </tr>
        </thead>
        <tbody>

            {{-- ============================================================ --}}
            {{-- BAGIAN 1: PENDAPATAN USAHA - HPP = PENDAPATAN KOTOR           --}}
            {{-- ============================================================ --}}

            @foreach (['PO','HPP'] as $skey)
                @php $sec = $sections[$skey]; @endphp
                <tr class="bg-info">
                    <th class="text-left" colspan="5">{{ $sec['title'] }}</th>
                </tr>

                @if(count($sec['rows']) == 0)
                    <tr>
                        <td class="text-center">-</td>
                        <td></td>
                        <td><em>(tidak ada data)</em></td>
                        <td class="text-right">0.00</td>
                        <td></td>
                    </tr>
                @else
                    @foreach($sec['rows'] as $i => $item)
                        <tr>
                            <td class="text-center">{{ $i + 1 }}</td>
                            <td class="text-center">{{ $item['row']->COA }}</td>
                            <td>{{ $item['row']->COADesc }}</td>
                            <td class="text-right">{{ number_format($item['amount'], 2, '.', ',') }}</td>
                            <td></td>
                        </tr>
                    @endforeach
                @endif

                <tr>
                    <td colspan="3" class="text-right"><span class="total">Total {{ $sec['title'] }}</span></td>
                    <td></td>
                    <td class="text-right"><span class="total">{{ number_format($sec['total'], 2, '.', ',') }}</span></td>
                </tr>
            @endforeach

            <tr>
                <td colspan="4" class="text-right">
                    <strong>PENDAPATAN KOTOR (Pendapatan Usaha - HPP)</strong>
                </td>
                <td class="text-right"><strong>{{ number_format($pendapatan_kotor, 2, '.', ',') }}</strong></td>
            </tr>

            {{-- spacer --}}
            <tr><td colspan="5">&nbsp;</td></tr>

            {{-- ============================================================ --}}
            {{-- BAGIAN 2: PENDAPATAN LAIN-LAIN - (BIAYA OPS + BIAYA LAIN-LAIN)--}}
            {{-- ============================================================ --}}

            @foreach (['PL','BO','BL'] as $skey)
                @php $sec = $sections[$skey]; @endphp
                <tr class="bg-info">
                    <th class="text-left" colspan="5">{{ $sec['title'] }}</th>
                </tr>

                @if(count($sec['rows']) == 0)
                    <tr>
                        <td class="text-center">-</td>
                        <td></td>
                        <td><em>(tidak ada data)</em></td>
                        <td class="text-right">0.00</td>
                        <td></td>
                    </tr>
                @else
                    @foreach($sec['rows'] as $i => $item)
                        <tr>
                            <td class="text-center">{{ $i + 1 }}</td>
                            <td class="text-center">{{ $item['row']->COA }}</td>
                            <td>{{ $item['row']->COADesc }}</td>
                            <td class="text-right">{{ number_format($item['amount'], 2, '.', ',') }}</td>
                            <td></td>
                        </tr>
                    @endforeach
                @endif

                <tr>
                    <td colspan="3" class="text-right"><span class="total">Total {{ $sec['title'] }}</span></td>
                    <td></td>
                    <td class="text-right"><span class="total">{{ number_format($sec['total'], 2, '.', ',') }}</span></td>
                </tr>
            @endforeach

            <tr>
                <td colspan="4" class="text-right">
                    <strong>SUBTOTAL LAIN-LAIN (Pendapatan Lain-lain - (Biaya Operasional + Biaya Lain-lain))</strong>
                </td>
                <td class="text-right"><strong>{{ number_format($subtotal_lain, 2, '.', ',') }}</strong></td>
            </tr>

            {{-- spacer --}}
            <tr><td colspan="5">&nbsp;</td></tr>

            {{-- ============================================================ --}}
            {{-- GRAND TOTAL                                                   --}}
            {{-- ============================================================ --}}
            <tr class="bg-info">
                <th class="text-left" colspan="5">RINGKASAN</th>
            </tr>
            <tr>
                <td colspan="4" class="text-right"><strong>TOTAL PENDAPATAN</strong></td>
                <td class="text-right"><strong>{{ number_format($total_pendapatan, 2, '.', ',') }}</strong></td>
            </tr>
            <tr>
                <td colspan="4" class="text-right"><strong>TOTAL BIAYA</strong></td>
                <td class="text-right"><strong>{{ number_format($total_biaya, 2, '.', ',') }}</strong></td>
            </tr>
            <tr>
                <td colspan="4" class="text-right">
                    <strong>LABA / (RUGI) BERSIH (Total Pendapatan - Total Biaya)</strong>
                </td>
                <td class="text-right">
                    <strong>{{ number_format($laba_bersih, 2, '.', ',') }}</strong>
                </td>
            </tr>
        </tbody>
    </table>
    <!-- END REPORT DATA -->

@endsection
