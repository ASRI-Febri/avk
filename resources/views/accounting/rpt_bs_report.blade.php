@extends('layouts.report_data')

@section('title')
    {{ $title }}
@endsection

@section('pagetitle')
    {{ $page_title }}
@endsection

@section('content')

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_M_Company" name="IDX_M_Company" value="{{ $fields['IDX_M_Company'] }}"/>
    <input type="hidden" id="IDX_M_Branch" name="IDX_M_Branch" value="{{ $fields['IDX_M_Branch'] }}"/>

    @php
        // Tiga kolom per baris, dihitung dari kolom mentah SP (BB / Debet / Kredit):
        //  - prior   : saldo per akhir bulan sebelumnya / M-1 (BBBalanceAmount)
        //  - current : mutasi periode berjalan (BDebetAmount - BCreditAmount)
        //  - ending  : prior + current
        // Sign flip: Liabilitas & Ekuitas ditampilkan positif (dikali -1) secara konsisten.
        $zero = ['prior' => 0.0, 'current' => 0.0, 'ending' => 0.0];

        $amounts_of = function ($row) {
            $sign = ($row->AccountType === 'AS') ? 1 : -1;
            $prior   = $sign * (float) $row->BBBalanceAmount;
            $current = $sign * ((float) $row->BDebetAmount - (float) $row->BCreditAmount);
            return ['prior' => $prior, 'current' => $current, 'ending' => $prior + $current];
        };

        $total_asset       = $zero;
        $total_liabilities = $zero;
        $total_equity      = $zero;

        // Label kolom dinamis dari periode terpilih
        $bulan_id = [1=>'Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
        $fmt_id = function ($ts) use ($bulan_id) {
            return date('j', $ts) . ' ' . $bulan_id[(int) date('n', $ts)] . ' ' . date('Y', $ts);
        };
        $ts_start = strtotime($fields['start_date']);
        $ts_end   = strtotime($fields['end_date']);
        $label_prior   = 'Per ' . $fmt_id(strtotime('-1 day', $ts_start));
        $label_current = 'Mutasi';
        $label_ending  = 'Per ' . $fmt_id($ts_end);
    @endphp

    <!-- BEGIN REPORT PARAMETER -->
    <div style="width:100%;">
        <div style="float:left;width:70%;">
            <table>
                <tr>
                    <td class="param-key">COMPANY</td>
                    <td class="param-value">: {{ strtoupper($fields['CompanyDesc']) }}</td>
                </tr>
                <tr>
                    <td class="param-key">PROFIT CENTER</td>
                    <td class="param-value">: {{ strtoupper($fields['BranchDesc']) }}</td>
                </tr>
                <tr>
                    <td class="param-key">AS OF</td>
                    <td class="param-value">: {{ date('d M Y',strtotime($fields['end_date'])) }}</td>
                </tr>
            </table>
        </div>

    </div>
    <br/>
    <hr>
    <br/>
    <!-- END REPORT PARAMETER -->

    <!-- BEGIN REPORT DATA -->
    <table id="table-report" class="minimalistBlack">
        <thead>
            <tr>
                <th>ASSET</th>
                <th>LIABILITIES &amp; EQUITY</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td style="vertical-align:top;">
                    <!-- ASSET -->
                    <table style="border:0;width:100%;">
                    <tr>
                        <td style="border:0;">&nbsp;</td>
                        <td class="width-200 text-center" style="border:0;"><strong>{{ $label_prior }}</strong></td>
                        <td class="width-200 text-center" style="border:0;"><strong>{{ $label_current }}</strong></td>
                        <td class="width-200 text-center" style="border:0;"><strong>{{ $label_ending }}</strong></td>
                    </tr>
                    @foreach ($records as $row)
                        @if($row->AccountType == 'AS')
                            @php
                                $a = $amounts_of($row);
                                foreach ($a as $col => $val) { $total_asset[$col] += $val; }
                            @endphp
                            <tr>
                                <td class="width-300" style="border:0">{{ $row->COAGroup1Name1 }}</td>
                                <td class="width-200 text-right" style="border:0">{{ number_format($a['prior'],2,'.',',') }}</td>
                                <td class="width-200 text-right" style="border:0">{{ number_format($a['current'],2,'.',',') }}</td>
                                <td class="width-200 text-right" style="border:0">{{ number_format($a['ending'],2,'.',',') }}</td>
                            </tr>
                        @endif
                    @endforeach
                    <tr>
                        <td class="text-right"><strong>TOTAL ASSET</strong></td>
                        <td class="text-right"><strong>{{ number_format($total_asset['prior'],2,'.',',') }}</strong></td>
                        <td class="text-right"><strong>{{ number_format($total_asset['current'],2,'.',',') }}</strong></td>
                        <td class="text-right"><strong>{{ number_format($total_asset['ending'],2,'.',',') }}</strong></td>
                    </tr>
                    </table>
                </td>
                <td style="vertical-align:top;">
                    <!-- LIABILITY -->
                    <table style="border:0; width:100%;">
                    <tr>
                        <td style="border:0;">&nbsp;</td>
                        <td class="width-200 text-center" style="border:0;"><strong>{{ $label_prior }}</strong></td>
                        <td class="width-200 text-center" style="border:0;"><strong>{{ $label_current }}</strong></td>
                        <td class="width-200 text-center" style="border:0;"><strong>{{ $label_ending }}</strong></td>
                    </tr>
                    @foreach ($records as $row)
                        @if($row->AccountType == 'LI')
                            @php
                                $a = $amounts_of($row);
                                foreach ($a as $col => $val) { $total_liabilities[$col] += $val; }
                            @endphp
                            <tr>
                                <td class="width-300" style="border:0">{{ $row->COAGroup1Name1 }}</td>
                                <td class="width-200 text-right" style="border:0">{{ number_format($a['prior'],2,'.',',') }}</td>
                                <td class="width-200 text-right" style="border:0">{{ number_format($a['current'],2,'.',',') }}</td>
                                <td class="width-200 text-right" style="border:0">{{ number_format($a['ending'],2,'.',',') }}</td>
                            </tr>
                        @endif
                    @endforeach
                    <tr>
                        <td class="text-right"><strong>TOTAL LIABILITIES</strong></td>
                        <td class="text-right"><strong>{{ number_format($total_liabilities['prior'],2,'.',',') }}</strong></td>
                        <td class="text-right"><strong>{{ number_format($total_liabilities['current'],2,'.',',') }}</strong></td>
                        <td class="text-right"><strong>{{ number_format($total_liabilities['ending'],2,'.',',') }}</strong></td>
                    </tr>
                    </table>

                    <!-- EQUITY -->
                    <table style="border:0;width:100%;">
                    @foreach ($records as $row)
                        @if($row->AccountType == 'EQ')
                            @php
                                $a = $amounts_of($row);
                                foreach ($a as $col => $val) { $total_equity[$col] += $val; }
                            @endphp
                            <tr>
                                <td class="width-300" style="border:0">{{ $row->COAGroup1Name1 }}</td>
                                <td class="width-200 text-right" style="border:0">{{ number_format($a['prior'],2,'.',',') }}</td>
                                <td class="width-200 text-right" style="border:0">{{ number_format($a['current'],2,'.',',') }}</td>
                                <td class="width-200 text-right" style="border:0">{{ number_format($a['ending'],2,'.',',') }}</td>
                            </tr>
                        @endif
                    @endforeach
                    <tr>
                        <td class="text-right"><strong>TOTAL EQUITY</strong></td>
                        <td class="text-right"><strong>{{ number_format($total_equity['prior'],2,'.',',') }}</strong></td>
                        <td class="text-right"><strong>{{ number_format($total_equity['current'],2,'.',',') }}</strong></td>
                        <td class="text-right"><strong>{{ number_format($total_equity['ending'],2,'.',',') }}</strong></td>
                    </tr>
                    <tr>
                        <td class="text-right"><strong>TOTAL LIABILITIES &amp; EQUITY</strong></td>
                        <td class="text-right"><strong>{{ number_format($total_liabilities['prior'] + $total_equity['prior'],2,'.',',') }}</strong></td>
                        <td class="text-right"><strong>{{ number_format($total_liabilities['current'] + $total_equity['current'],2,'.',',') }}</strong></td>
                        <td class="text-right"><strong>{{ number_format($total_liabilities['ending'] + $total_equity['ending'],2,'.',',') }}</strong></td>
                    </tr>
                    </table>
                </td>
            </tr>
        </tbody>
    </table>
    <!-- END REPORT DATA -->

@endsection

<script src="{{ URL::asset('public/js/router.js') }}"></script>

<script>

    function getScrollPosition()
    {
        var scroll = $(window).scrollTop();
        $("#scroll-position").val(scroll);
    }

    function getDetail(IDX_M_Company, IDX_M_Branch, start_date, end_date, IDX_M_COA)
    {
        url = "{{ url('ac-rpt-tb/get-detail') }}";

        var data = {
            "_token": "{{ csrf_token() }}",
            "IDX_M_Company": IDX_M_Company,
            "IDX_M_Branch": IDX_M_Branch,
            "start_date": start_date,
            "end_date": end_date,
            "IDX_M_COA": IDX_M_COA,
            "CompanyDesc": "{{ strtoupper($fields['CompanyDesc']) }}",
            "BranchDesc": "{{ strtoupper($fields['BranchDesc']) }}",
        }

        $.ajax({
            url: url,
            type: 'post',
            data: data,
            success: function(response){

                // Add response in Modal body
                var w = window.open();
                $(w.document.body).html(response);

            }
        });

    }
</script>
