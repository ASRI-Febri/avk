@extends('layouts.pdf')

@section('title')
    {{ $fields->TransactionDate }}
@endsection

@section('content')    

    <div style="float:left;width:60%">
        
        {{-- <img src="{{ $img_logo }}" width="{{ $img_logo_w }}" height="{{ $img_logo_h }}" />
        <br> --}}
        <table class="noborder">
            <tr class="noborder nopadding">                
                <td class="td-85 bold noborder nopadding param-key">
                    <span style="display:block;">PT. {{ strtoupper($fields->CompanyName) }}</span>
                </td>
            </tr>                     
        </table>  
    </div>

    <div style="float:left;width:40%">
        <h2>Form Persiapan & Penutupan Harian</h2>
        <table class="noborder nopadding">
            <tr class="noborder nopadding">
                <td class="td-20 bold noborder nopadding param-key">Teller</td>
                <td class="td-50 bold noborder nopadding param-value">: {{ $fields->TellerID . ' - ' . $fields->TellerName }}</td>
            </tr>
            <tr class="noborder">
                <td class="td-20 bold noborder nopadding param-key">Tanggal</td>
                <td class="td-50 bold noborder nopadding param-value">: {{ date('d M Y',strtotime($fields->TransactionDate)) }}</td>
            </tr>
        </table>
        
    </div>

    <br>   
   
    <table>
        <thead>
            <tr>   
                <td class="bold">NO</td>
                <td class="bold">KETERANGAN</td>
                <td class="bold text-right">AWAL</td>
                <td class="bold text-right">BELI</td>
                <td class="bold text-right">JUAL</td>
                <td class="bold text-right">AKHIR</td>
            </tr>
        </thead>
        <tbody>
    @if($records_detail)

        @php 
            $seq = 0; 
            $row_number = 0;

            $group_number = 0;
            $group_a1 = '';    
            $group_a2 = '';

            $prev_group = '';

            $subtotal_open_qty = 0;
			$subtotal_in_qty = 0;
            $subtotal_out_qty = 0;			
            $subtotal_close_qty = 0;
        @endphp

        @foreach($records_detail as $row)

            @php 
                $seq += 1;          
                $row_number += 1;      
                $group_a1 = $row->IDX_M_Currency;                                
                              
            @endphp

            @if($group_a1 <> $group_a2)

                @if($row_number > 1)
                    <tr>
                        <td colspan="2" class="text-right"><strong>SUB TOTAL {{  $prev_group }}</strong></td>
                        <td class="text-right"><strong>{{ $prev_group . ' ' . number_format($subtotal_open_qty, 2, '.', ',') }}</strong></td>
                        <td class="text-right"><strong>{{ $prev_group . ' ' . number_format($subtotal_in_qty, 2, '.', ',') }}</strong></td>
                        <td class="text-right"><strong>{{ $prev_group . ' ' . number_format($subtotal_out_qty, 2, '.', ',') }}</strong></td>
                        <td class="text-right"><strong>{{ $prev_group . ' ' . number_format($subtotal_close_qty, 2, '.', ',') }}</strong></td>
                    </tr>
                @endif

                @php
                    $group_number = 0;
                    $subtotal_open_qty = 0;
                    $subtotal_in_qty = 0;
                    $subtotal_out_qty = 0;
                    $subtotal_close_qty = 0;

                    $prev_group = $row->CurrencyID; 

                    $group_a2 = $group_a1;
                @endphp 
                
            @endif 

            @php 
                $group_number += 1;

                $subtotal_open_qty += ($row->OpenValue);
                $subtotal_in_qty += ($row->InValue);
                $subtotal_out_qty += ($row->OutValue);
                $subtotal_close_qty += ($row->CloseValue);
            @endphp

            <tr>
                <td>{{ $seq }}</td>
                
                <td>                    
                    <span style="display:block">{{ $row->CurrencyName }}</span>                    
                    <span style="display:block">{{ $row->CurrencyID . ' - ' . $row->ValasChangeName }}</span>   
                </td>                
                
                <td class="text-right">
                    <span style="display:block">{{ 'QTY: ' . number_format($row->OpenQty, 2, '.', ',') }}</span>
                    <span style="display:block">{{ $row->CurrencyID . ' ' . number_format($row->OpenValue, 2, '.', ',') }}</span>
                </td>
                <td class="text-right">
                    <span style="display:block">{{ 'QTY: ' . number_format($row->InQty, 2, '.', ',') }}</span>
                    <span style="display:block">{{ $row->CurrencyID . ' ' . number_format($row->InValue, 2, '.', ',') }}</span>
                </td>
                <td class="text-right">
                    <span style="display:block">{{ 'QTY: ' . number_format($row->OutQty, 2, '.', ',') }}</span>
                    <span style="display:block">{{ $row->CurrencyID . ' ' . number_format($row->OutValue, 2, '.', ',') }}</span>
                </td>
                <td class="text-right">
                    <span style="display:block">{{ 'QTY: ' . number_format($row->CloseQty, 2, '.', ',') }}</span>
                    <span style="display:block">{{ $row->CurrencyID . ' ' . number_format($row->CloseValue, 2, '.', ',') }}</span>
                </td>

                {{-- <td class="text-right">{{ $row->CurrencyID . ' ' . number_format($row->OpenQty * $row->ValasChangeNumber, 2, '.', ',') }}</td>
                <td class="text-right">{{ number_format($row->CloseQty, 2, '.', ',') }}</td>
                <td class="text-right">{{ $row->CurrencyID . ' ' . number_format($row->CloseQty * $row->ValasChangeNumber, 2, '.', ',') }}</td> --}}

                @if(!isset($show_action) || $show_action == TRUE)
                <td class="text-center">
                    @if($row->TransactionStatus == 'O')
                    <div class="input-group-prepend text-center">
                        <x-btn-edit-detail :id="$row->IDX_T_OpenCloseDailyDetail" />
                        <x-btn-delete-detail :id="$row->IDX_T_OpenCloseDailyDetail" :label="$row->ValasName" function="deleteDetailValas" />                    
                    </div>
                    @endif
                </td>
                @endif
            </tr>
        @endforeach
               
        <tr class="font-weight-bold">
            <td colspan="2" class="text-right"><strong>SUB TOTAL {{ $row->CurrencyID }}</strong></td>
            <td class="text-right"><strong>{{ $row->CurrencyID . ' ' . number_format($subtotal_open_qty, 2, '.', ',') }}</strong></td>
            <td class="text-right"><strong>{{ $row->CurrencyID . ' ' . number_format($subtotal_in_qty, 2, '.', ',') }}</strong></td>
            <td class="text-right"><strong>{{ $row->CurrencyID . ' ' . number_format($subtotal_out_qty, 2, '.', ',') }}</strong></td>
            <td class="text-right"><strong>{{ $row->CurrencyID . ' ' . number_format($subtotal_close_qty, 2, '.', ',') }}</strong></td>
        </tr>

    @endif
    </tbody>      
    </table>
    

    <br>

    <table>
        <thead>
            <tr>                
                <td class="bold w-50 td-50">Catatan</td>
                <td class="bold w-20 td-15 text-center">Teller</td>
                <td class="bold w-20 td-15 text-center">Manajer Umum</td>
                <td class="bold w-20 td-15 text-center">Direktur</td>
            </tr>
        </thead>
        <tbody>
            <tr>                
                <td class="w-50">
                    Harap periksa dan hitung kembali jumlah masing-masing valas
                    <br>
                    <br>
                    <br>
                    <br>
                </td>
                <td class="w-15">&nbsp;</td>
                <td class="w-15">&nbsp;</td>
                <td class="w-15">&nbsp;</td>
            </tr>
        </tbody>        
    </table>

   
   

@endsection