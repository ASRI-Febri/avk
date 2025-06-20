@extends('layouts.pdf')

@section('title')
    {{ $fields->DocumentTypeDesc }}
@endsection

@section('content')    

    <div style="float:left;width:60%">
        
        <img src="{{ $img_logo }}" width="{{ $img_logo_w }}" height="{{ $img_logo_h }}" />
        <br>
        <table class="noborder">
            <tr class="noborder nopadding">                
                <td class="td-85 bold noborder nopadding param-key">
                    <span style="display:block;">PT. {{ strtoupper($fields->CompanyDesc) }}</span>
                </td>
            </tr>
            <tr class="noborder nopadding">
                <td class="td-85 bold noborder nopadding param-value">
                    {{-- {{ $fields->CompanyStreet . ' ' . $fields->City . ' ' . $fields->Province . ' ' . $fields->Zip }} --}}
                    <span style="display:block;">Ruko Dynasty Walk Kav. 29B #18</span>
                    
                    <span style="display:block;">Jl. Jalur Sutera, Alam Sutera Tangerang Banten 15320</span>
                    
                    <span style="display:block;">Phone: {{ $fields->CompanyPhone }} Ext: 3870</span>                    
                </td>
            </tr>            
        </table>  
    </div>

    <div style="float:left;width:40%">
        <h1>{{ $fields->DocumentTypeDesc }}</h1>
        <table class="noborder nopadding">
            <tr class="noborder nopadding">
                <td class="td-20 bold noborder nopadding param-key">Receive ID</td>
                <td class="td-50 bold noborder nopadding param-value">{{ $fields->ReceiveID }}</td>
            </tr>
            <tr class="noborder nopadding">
                <td class="td-20 bold noborder nopadding param-key">No Voucher</td>
                <td class="td-50 bold noborder nopadding param-value">{{ $fields->VoucherNoManual }}</td>
            </tr>
            <tr class="noborder">
                <td class="td-20 bold noborder nopadding param-key">Date</td>
                <td class="td-50 bold noborder nopadding param-value">{{ date('d M Y',strtotime($fields->ReceiveDate)) }}</td>
            </tr>
        </table>
        
    </div>

    <br>
    <hr>

    <div>
        <table class="noborder nopadding">
            <tr class="noborder nopadding">
                <td class="td-20 bold noborder nopadding param-key">Rekening</td>
                <td class="td-70 bold noborder nopadding param-value">{{ $fields->FinancialAccountID . ' - ' . $fields->FinancialAccountDesc }}</td>
                <td class="td-30 bold noborder nopadding param-key">Tanggal Validasi</td>
                <td class="td-50 bold noborder nopadding param-value">{{ date('d M Y',strtotime($fields->ApprovalDate)) }}</td>
            </tr>
            <tr class="noborder nopadding">
                <td class="td-20 bold noborder nopadding param-key">Diterima Dari</td>
                <td class="td-70 bold noborder nopadding param-value">{{ $fields->PartnerName }}</td>
                <td class="td-30 bold noborder nopadding param-key">No Transaksi</td>
                <td class="td-50 bold noborder nopadding param-value">{{ $fields->ReceiveID }}</td>
            </tr>
            <tr class="noborder nopadding">
                <td class="td-20 bold noborder nopadding param-key">Jumlah</td>
                <td class="td-50 bold noborder nopadding param-value">{{ 'Rp. ' . number_format($fields->ReceiveAmount, 2, '.', ',') }}</td>
            </tr>
        </table>
        <br>
        <table>
            <td align = "center" class="param-value">{{"# " . strtoupper($fields->AmountTerbilang) . " RUPIAH #" }}</td>
        </table>
    </div>

    <br>

    <table style="page-break-before:avoid;">
        <tbody>

            @php

                echo '<tr style="height:25px;">
                            <td align="center"><strong>ACCOUNT</strong></td>								                            
                            <td align="center"><strong>LOCATION</strong></td>			
                            <td align="center"><strong>JOURNAL DESCRIPTION</strong></td>						
                            <td align="center"><strong>DEBET</strong></td>
                            <td align="center"><strong>CREDIT</strong></td>
                        </tr>';

            @endphp

            @if($fields)

                @php 
                    $row_number = 0;
                    $group_debet = 0;
                    $group_credit = 0;

                    $subtotal_debet = 0;
                    $subtotal_credit = 0;

                    $group1 = '';
			        $group2 = '';

                    foreach ($records_detail as $row) :

                        $row_number += 1;

                        $group1 = $row->JournalType;

                        if ($row_number == 1) {
                            $group_name = $row->JournalType;
                            $group_prev_name = $row->JournalType;
                        } else {
                            $group_name = $row->JournalType;
                        }

                        if ($group1 <> $group2) {
                            if ($row_number > 1) {
                                echo '<tr>
                                                <td colspan= "3" align="right"><strong>TOTAL (RP) : </strong>&nbsp;</td>								
                                                <td align="right"><strong>' . number_format($group_debet, 0, '.', ',') . '</strong>&nbsp;</td>
                                                <td align="right"><strong>' . number_format($group_credit, 0, '.', ',') . '</strong>&nbsp;</td>
                                            </tr>';

                                echo'<tr>
                                            <td colspan="5"></td>
                                        </tr>';

                                echo '<tr style="height:25px;">
                                    <td align="center"><strong>ACCOUNT</strong></td>	
                                    <td align="center"><strong>LOCATION</strong></td>							                            
                                    <td align="center"><strong>JOURNAL DESCRIPTION</strong></td>								
                                    <td align="center"><strong>DEBET</strong></td>
                                    <td align="center"><strong>CREDIT</strong></td>
                                </tr>';

                                $group_prev_name = $group_name;
                            }

                            $group_number = 0; //Reset Group Number	                    			
                            $group_debet = 0;
                            $group_credit = 0;

                            $group2 = $group1;
                        }

                        $group_debet += floor($row->BDebetAmount);
                        $group_credit += floor($row->BCreditAmount);

                        $total_debet = $row->BDebetAmount;
                        $total_credit = $row->BCreditAmount;

                        $subtotal_debet += ($total_debet);
                        $subtotal_credit += ($total_credit);

                        echo '<tr>                                
                                        <td align="left">&nbsp;' . $row->COAID . ' - ' . $row->COADesc . '</td>
                                        <td align="center">&nbsp;' . $row->ProjectID . '</td>
                                        <td align="left">&nbsp;' . $row->JournalDesc . '</td>
                                        <td align="right">' . number_format(floor($row->BDebetAmount), 0, '.', ',') . '&nbsp;</td>
                                        <td align="right">' . number_format(floor($row->BCreditAmount), 0, '.', ',') . '&nbsp;</td>									
                                    </tr>';

                    endforeach;

                    echo '<tr>
                                    <td colspan= "3" align="right"><strong>TOTAL (RP) : </strong>&nbsp;</td>								
                                    <td align="right"><strong>' . number_format($group_debet, 0, '.', ',') . '</strong>&nbsp;</td>
                                    <td align="right"><strong>' . number_format($group_credit, 0, '.', ',') . '</strong>&nbsp;</td>
                                </tr>';
                @endphp

            @endif
    </table>

    <br><br><br><br>

    @php

        echo '<table cellspacing="0" cellpadding="1" border="1" nobr="true">
                                <tr style="height:25px;">
                                    <td align="left">Dibuat:</td>
                                    <td align="left">Kasir:</td>
                                    <td align="left">Diperiksa:</td>
                                    <td align="left">Disetujui:</td>
                                    <td align="left">Diterima:</td>								
                                </tr>
                                <tr style="height:25px;">
                                    <td align="left">Tanggal:</td>
                                    <td align="left">Tanggal:</td>
                                    <td align="left">Tanggal:</td>
                                    <td align="left">Tanggal:</td>
                                    <td align="left">Tanggal:</td>								
                                </tr>
                                <tr>
                                    <td height="50" align="center">&nbsp;</td>
                                    <td align="center">&nbsp;</td>
                                    <td align="center">&nbsp;</td>
                                    <td align="center">&nbsp;</td>
                                    <td align="center">&nbsp;</td>								
                                </tr>
                                <tr>
                                    <td align="center">' . $fields->UCreate . '</td>
                                    <td align="center">&nbsp;</td>
                                    <td align="center">&nbsp;</td>
                                    <td align="center">&nbsp;</td>
                                    <td align="center">&nbsp;</td>								
                                </tr>';

    @endphp

@endsection