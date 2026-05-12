@extends('layouts.report_data')

@section('title')
    {{ $title }}
@endsection

@section('pagetitle')
    {{ $page_title }}
@endsection

@section('content')

    {{-- $report comes pre-built from ProfitLossReportBuilder — view has zero business logic --}}

    <!-- REPORT PARAMETER -->
    <div style="width:100%;">
        <div style="float:left;width:70%;">
            <table>
                <tr>
                    <td class="param-key">Profit &amp; Loss Period</td>
                    <td class="param-value">
                        : {{ DateTime::createFromFormat('Ym', $report['period'])->format('M Y') }}
                    </td>
                </tr>
            </table>
        </div>
    </div>
    <br/><hr><br/>

    <!-- REPORT DATA -->
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

            @foreach($report['sections'] as $section)

                {{-- Section header --}}
                <tr class="bg-secondary">
                    <th class="text-left" colspan="5" style="background:#d9edf7;">
                        {{ $section['title'] }}
                    </th>
                </tr>

                {{-- Render every top-level node via the recursive partial --}}
                @foreach($section['nodes'] as $node)
                    @include('accounting.partials._pl_node', ['node' => $node])
                @endforeach

                {{-- Section result --}}
                <tr>
                    <td colspan="4" class="text-right">
                        <strong>{{ $section['result']['label'] }}</strong>
                    </td>
                    <td class="text-right">
                        <strong>{{ number_format($section['result']['amount'], 2, '.', ',') }}</strong>
                    </td>
                </tr>

                {{-- spacer --}}
                <tr><td colspan="5">&nbsp;</td></tr>

            @endforeach

            {{-- Grand total --}}
            <tr class="bg-info">
                <th class="text-left" colspan="5">RINGKASAN</th>
            </tr>
            <tr>
                <td colspan="4" class="text-right"><strong>TOTAL PENDAPATAN</strong></td>
                <td class="text-right">
                    <strong>{{ number_format($report['summary']['total_pendapatan'], 2, '.', ',') }}</strong>
                </td>
            </tr>
            <tr>
                <td colspan="4" class="text-right"><strong>TOTAL BIAYA</strong></td>
                <td class="text-right">
                    <strong>{{ number_format($report['summary']['total_biaya'], 2, '.', ',') }}</strong>
                </td>
            </tr>
            <tr>
                <td colspan="4" class="text-right">
                    <strong>LABA / (RUGI) BERSIH (Total Pendapatan - Total Biaya)</strong>
                </td>
                <td class="text-right">
                    <strong>{{ number_format($report['summary']['laba_bersih'], 2, '.', ',') }}</strong>
                </td>
            </tr>

        </tbody>
    </table>

@endsection
