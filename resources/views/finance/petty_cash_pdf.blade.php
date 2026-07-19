@extends('layouts.pdf')

@section('title')
    {{ $fields->DocumentTypeDesc }}
@endsection

@section('content')

    <div style="float:left;width:60%">

        <img src="{{ $img_logo }}" width="{{ $img_logo_w }}" style="display:block;" />
        <br>
        <table class="noborder">
            <tr class="noborder nopadding">
                <td class="td-85 bold noborder nopadding param-key">
                    <span style="display:block;">PT. {{ strtoupper($fields->CompanyDesc) }}</span>
                </td>
            </tr>
        </table>
    </div>

    <div style="float:left;width:40%">
        <h1>{{ $fields->DocumentTypeDesc }}</h1>
        <table class="noborder nopadding">
            <tr class="noborder nopadding">
                <td class="td-20 bold noborder nopadding param-key">Transaction ID</td>
                <td class="td-50 bold noborder nopadding param-value">{{ $fields->TransactionID }}</td>
            </tr>
            <tr class="noborder">
                <td class="td-20 bold noborder nopadding param-key">Opening Date</td>
                <td class="td-50 bold noborder nopadding param-value">{{ date('d M Y', strtotime($fields->OpeningDate)) }}</td>
            </tr>
            <tr class="noborder">
                <td class="td-20 bold noborder nopadding param-key">Status</td>
                <td class="td-50 bold noborder nopadding param-value">{{ $fields->StatusDesc }}</td>
            </tr>
        </table>

    </div>

    <br>
    <hr>

    <div>
        <table class="noborder nopadding">
            <tr class="noborder nopadding">
                <td class="td-20 bold noborder nopadding param-key">Cabang</td>
                <td class="td-70 bold noborder nopadding param-value">{{ $fields->BranchName }}</td>
            </tr>
            <tr class="noborder nopadding">
                <td class="td-20 bold noborder nopadding param-key">Kasir</td>
                <td class="td-70 bold noborder nopadding param-value">{{ $fields->CashierName }}</td>
            </tr>
            <tr class="noborder nopadding">
                <td class="td-20 bold noborder nopadding param-key">Keterangan</td>
                <td class="td-70 bold noborder nopadding param-value">{{ $fields->TransactionDesc }}</td>
            </tr>
        </table>
    </div>

    <br>

    <table style="page-break-before:avoid;">
        <tbody>

            @php
                echo '<tr style="height:25px;">
                            <td align="center"><strong>NO</strong></td>
                            <td align="center"><strong>TANGGAL</strong></td>
                            <td align="center"><strong>TIPE</strong></td>
                            <td align="center"><strong>NO REFERENSI</strong></td>
                            <td align="center"><strong>DIBAYARKAN KE</strong></td>
                            <td align="center"><strong>KETERANGAN</strong></td>
                            <td align="center"><strong>JUMLAH</strong></td>
                        </tr>';
            @endphp

            @if($records_detail)

                @php
                    $seq = 0;
                    $total = 0;

                    foreach ($records_detail as $row) :

                        $seq += 1;
                        $total += $row->PettyCashAmount;

                        echo '<tr>
                                        <td align="center">' . $seq . '</td>
                                        <td align="center">&nbsp;' . date('d M Y', strtotime($row->TransactionDate)) . '</td>
                                        <td align="left">&nbsp;' . $row->DocumentTypeDesc . '</td>
                                        <td align="left">&nbsp;' . $row->ReferenceNo . '</td>
                                        <td align="left">&nbsp;' . $row->PartnerName . '</td>
                                        <td align="left">&nbsp;' . $row->DetailDesc . '</td>
                                        <td align="right">' . number_format($row->PettyCashAmount, 2, '.', ',') . '&nbsp;</td>
                                    </tr>';

                    endforeach;

                    echo '<tr>
                                    <td colspan="6" align="right"><strong>TOTAL (RP) : </strong>&nbsp;</td>
                                    <td align="right"><strong>' . number_format($total, 2, '.', ',') . '</strong>&nbsp;</td>
                                </tr>';
                @endphp

            @endif
    </table>

    <br>
    <table>
        <td align="center" class="param-value">{{ "# " . strtoupper($fields->AmountTerbilang) . " RUPIAH #" }}</td>
    </table>

    <br><br><br><br>

    @php
        echo '<table cellspacing="0" cellpadding="1" border="1" nobr="true">
                                <tr style="height:25px;">
                                    <td align="left">Dibuat:</td>
                                    <td align="left">Diperiksa:</td>
                                    <td align="left">Disetujui:</td>
                                </tr>
                                <tr style="height:25px;">
                                    <td align="left">Tanggal:</td>
                                    <td align="left">Tanggal:</td>
                                    <td align="left">Tanggal:</td>
                                </tr>
                                <tr>
                                    <td height="50" align="center">&nbsp;</td>
                                    <td align="center">&nbsp;</td>
                                    <td align="center">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td align="center">' . $fields->UCreate . '</td>
                                    <td align="center">&nbsp;</td>
                                    <td align="center">&nbsp;</td>
                                </tr>';
    @endphp

@endsection
