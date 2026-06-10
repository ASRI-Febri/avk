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
        // Klasifikasi baris dari USP_GL_R_CashflowStatement
        //   Section 1 = Operasi (SubGroup 11 = Laba bersih, 12 = Modal kerja)
        //   Section 2 = Investasi
        //   Section 3 = Pendanaan
        //   RowType BEGINCASH / ENDCASH = ringkasan kas
        // ============================================================
        $operating = [
            11 => ['title' => 'Laba/(Rugi) Bersih',                    'rows' => [], 'total' => 0],
            12 => ['title' => 'Perubahan Modal Kerja & Penyesuaian',   'rows' => [], 'total' => 0],
        ];
        $investing = ['title' => 'Aktivitas Investasi',  'rows' => [], 'total' => 0];
        $financing = ['title' => 'Aktivitas Pendanaan',  'rows' => [], 'total' => 0];

        $beginCash = 0;
        $endCashSP = 0;

        foreach ($records as $row) {
            if (trim($row->RowType) === 'BEGINCASH') { $beginCash = (float) $row->CashFlowAmount; continue; }
            if (trim($row->RowType) === 'ENDCASH')   { $endCashSP = (float) $row->CashFlowAmount; continue; }

            $amount = (float) $row->CashFlowAmount;

            if ((int) $row->Section === 1) {
                $sg = ((int) $row->SubGroup === 11) ? 11 : 12;
                $operating[$sg]['rows'][] = ['row' => $row, 'amount' => $amount];
                $operating[$sg]['total'] += $amount;
            } else if ((int) $row->Section === 2) {
                $investing['rows'][] = ['row' => $row, 'amount' => $amount];
                $investing['total'] += $amount;
            } else if ((int) $row->Section === 3) {
                $financing['rows'][] = ['row' => $row, 'amount' => $amount];
                $financing['total'] += $amount;
            }
        }

        $netOperating = $operating[11]['total'] + $operating[12]['total'];
        $netInvesting = $investing['total'];
        $netFinancing = $financing['total'];

        $netChange    = $netOperating + $netInvesting + $netFinancing;
        $endCash      = $beginCash + $netChange;

        $periodLabel = $fields['Period'];
        $dt = DateTime::createFromFormat('Ym', $fields['Period']);
        if ($dt) { $periodLabel = $dt->format('M Y'); }
    @endphp

    <!-- BEGIN REPORT PARAMETER -->
    <div style="width:100%;">
        <div style="float:left;width:70%;">
            <table>
                <tr>
                    <td class="param-key">Cashflow Period</td>
                    <td class="param-value">: {{ $periodLabel }}</td>
                </tr>
                <tr>
                    <td class="param-key">Metode</td>
                    <td class="param-value">: Tidak Langsung (PSAK 2)</td>
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
                <th>KETERANGAN</th>
                <th class="text-center" style="width:18%;">JUMLAH</th>
                <th class="text-center" style="width:20%;">SUBTOTAL</th>
            </tr>
        </thead>
        <tbody>

            {{-- ============================================================ --}}
            {{-- AKTIVITAS OPERASI                                            --}}
            {{-- ============================================================ --}}
            <tr class="bg-info">
                <th class="text-left" colspan="5">ARUS KAS DARI AKTIVITAS OPERASI</th>
            </tr>

            @foreach ([11, 12] as $sg)
                @php $sec = $operating[$sg]; @endphp
                <tr>
                    <td></td>
                    <td colspan="4"><strong>{{ $sec['title'] }}</strong></td>
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
                    <td colspan="3" class="text-right"><span class="total">Subtotal {{ $sec['title'] }}</span></td>
                    <td></td>
                    <td class="text-right"><span class="total">{{ number_format($sec['total'], 2, '.', ',') }}</span></td>
                </tr>
            @endforeach

            <tr>
                <td colspan="4" class="text-right"><strong>Kas Bersih dari Aktivitas Operasi</strong></td>
                <td class="text-right"><strong>{{ number_format($netOperating, 2, '.', ',') }}</strong></td>
            </tr>

            <tr><td colspan="5">&nbsp;</td></tr>

            {{-- ============================================================ --}}
            {{-- AKTIVITAS INVESTASI                                          --}}
            {{-- ============================================================ --}}
            <tr class="bg-info">
                <th class="text-left" colspan="5">ARUS KAS DARI AKTIVITAS INVESTASI</th>
            </tr>

            @if(count($investing['rows']) == 0)
                <tr>
                    <td class="text-center">-</td>
                    <td></td>
                    <td><em>(tidak ada data)</em></td>
                    <td class="text-right">0.00</td>
                    <td></td>
                </tr>
            @else
                @foreach($investing['rows'] as $i => $item)
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
                <td colspan="4" class="text-right"><strong>Kas Bersih dari Aktivitas Investasi</strong></td>
                <td class="text-right"><strong>{{ number_format($netInvesting, 2, '.', ',') }}</strong></td>
            </tr>

            <tr><td colspan="5">&nbsp;</td></tr>

            {{-- ============================================================ --}}
            {{-- AKTIVITAS PENDANAAN                                          --}}
            {{-- ============================================================ --}}
            <tr class="bg-info">
                <th class="text-left" colspan="5">ARUS KAS DARI AKTIVITAS PENDANAAN</th>
            </tr>

            @if(count($financing['rows']) == 0)
                <tr>
                    <td class="text-center">-</td>
                    <td></td>
                    <td><em>(tidak ada data)</em></td>
                    <td class="text-right">0.00</td>
                    <td></td>
                </tr>
            @else
                @foreach($financing['rows'] as $i => $item)
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
                <td colspan="4" class="text-right"><strong>Kas Bersih dari Aktivitas Pendanaan</strong></td>
                <td class="text-right"><strong>{{ number_format($netFinancing, 2, '.', ',') }}</strong></td>
            </tr>

            <tr><td colspan="5">&nbsp;</td></tr>

            {{-- ============================================================ --}}
            {{-- RINGKASAN                                                    --}}
            {{-- ============================================================ --}}
            <tr class="bg-info">
                <th class="text-left" colspan="5">RINGKASAN ARUS KAS</th>
            </tr>
            <tr>
                <td colspan="4" class="text-right"><strong>KENAIKAN / (PENURUNAN) BERSIH KAS &amp; SETARA KAS</strong></td>
                <td class="text-right"><strong>{{ number_format($netChange, 2, '.', ',') }}</strong></td>
            </tr>
            <tr>
                <td colspan="4" class="text-right">Kas dan Setara Kas Awal Periode</td>
                <td class="text-right">{{ number_format($beginCash, 2, '.', ',') }}</td>
            </tr>
            <tr>
                <td colspan="4" class="text-right"><strong>KAS DAN SETARA KAS AKHIR PERIODE</strong></td>
                <td class="text-right"><strong>{{ number_format($endCash, 2, '.', ',') }}</strong></td>
            </tr>
        </tbody>
    </table>
    <!-- END REPORT DATA -->

@endsection
