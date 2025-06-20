@extends('layouts.pdf')

@section('title')
     Sales Receipt 
@endsection

@section('content')    

    <div style="float:left;width:60%">
        
        <img src="{{ $img_logo }}" width="{{ $img_logo_w }}" height="{{ $img_logo_h }}" />
        <br>
        <table class="noborder">
            <tr class="noborder nopadding">                
                <td class="td-85 bold noborder nopadding param-key">
                    {{-- <span style="display:block;">PT. {{ strtoupper($fields->CompanyName) }}</span> --}}
                    <span style="display:block;">{{ $fields->CompanyName }}</span>
                </td>
            </tr>
            <tr class="noborder nopadding">
                <td class="td-85 bold noborder nopadding param-value">
                    {{-- {{ $fields->CompanyStreet . ' ' . $fields->City . ' ' . $fields->Province . ' ' . $fields->Zip }} --}}
                    <span style="display:block;">{{ $fields->LegalAddress }}</span>
                    
                    <span style="display:block;">{{ $fields->LegalAddressDetail }}</span>
                    
                    <span style="display:block;">{{ "NPWP " . $fields->NPWP}}</span>                    
                </td>
            </tr>            
        </table>  
    </div>

    <div style="float:left;width:40%">
        {{-- <h1>{{ $fields->DocumentTypeDesc }}</h1> --}}
        <h1>KWITANSI</h1>
        <table class="noborder nopadding">
            <tr class="noborder nopadding">
                <td class="td-15 bold noborder nopadding param-key">No</td>
                <td class="td-50 bold noborder nopadding param-value">{{ $fields->InvoiceNo }}</td>
            </tr>
            <tr class="noborder">
                <td class="td-15 bold noborder nopadding param-key">Tanggal</td>
                <td class="td-50 bold noborder nopadding param-value">{{ date('d M Y',strtotime($fields->InvoiceDate)) }}</td>
            </tr>
        </table>
    </div>

    <br>
    <hr>

    <div>
        <table class="noborder nopadding">
            <tr class="noborder nopadding">
                <td class="td-15 bold noborder nopadding param-key">Sudah Diterima Dari</td>
                <td class="td-50 bold noborder nopadding param-value">{{ $fields->PartnerName }}</td>
                {{-- <td class="td-20 bold noborder nopadding param-key">Sales</td>
                <td class="td-50 bold noborder nopadding param-value">{{ $fields->SalesPersonName }}</td> --}}
            </tr>
            <tr class="noborder nopadding">
                <td class="td-15 bold noborder nopadding param-key">Alamat</td>
                <td class="td-50 bold noborder nopadding param-value">{{ $fields->PartnerAddress }}</td>
            </tr>
            <tr class="noborder nopadding"><td td class="noborder nopadding"><br></td></tr>
            <tr class="noborder nopadding">
                <td class="td-15 bold noborder nopadding param-key">Uang Sebesar</td>
                <td class="td-50 bold noborder nopadding param-value">{{ "# " . strtoupper($fields->AmountTerbilang) . " RUPIAH #"  }}</td>
            </tr>
        </table>
    </div>
    
    <br>
    <hr>
    
    <table>

        <tbody>
            @if($fields)

                @php 
                    $seq = 0;
                    $subtotal_untaxed = 0;
                    $subtotal_tax = 0;
                    $witholding = 0;
                    $total = 0;
                @endphp

                @foreach($records_detail as $row)

                    @php

                        $seq += 1;
                        $subtotal_untaxed += $row->Quantity * ($row->UntaxedAmount - $row->DiscountAmount);
                        $subtotal_tax += $row->Quantity * $row->TaxAmount;
                        $witholding += $row->Quantity * $row->PPHAmount;
                        $total += $row->Quantity * ($row->UntaxedAmount - $row->DiscountAmount + $row->TaxAmount);

                    @endphp

                @endforeach

            @endif

            <tr class="noborder">
                <td class="noborder" colspan="5"></td>
            </tr>
            
            <tr class="font-weight-bold noborder">
                <td colspan="4" class="text-left text-secondary noborder">{{ $fields->RemarkHeader }}</td>
                <td class="text-right text-secondary noborder bold">Rp {{ number_format($subtotal_untaxed, 0, '.', ',') }}</td>            
            </tr>

            <tr class="font-weight-bold noborder">
                <td colspan="4" class="text-right text-secondary noborder">PPN</td>
                <td class="text-right text-secondary noborder bold">Rp {{ number_format($subtotal_tax, 0, '.', ',') }}</td>            
            </tr>

            <tr class="font-weight-bold noborder">
                <td colspan="4" class="text-right text-secondary noborder">PPH</td>
                <td class="text-right text-secondary noborder bold">Rp ({{ number_format(ABS($witholding), 0, '.', ',') }})</td>            
            </tr>

            <tr class="font-weight-bold noborder">
                <td colspan="4" class="text-right text-secondary noborder bold">Grand Total</td>
                <td class="text-right text-secondary noborder bold">Rp {{ number_format($total - ABS($witholding), 0, '.', ',') }}</td>            
            </tr>          

            <tr>
                <td colspan='5' class="noborder"></td>
            </tr>
            <tr>
                <td colspan='5' class="noborder"></td>
            </tr>
            <tr>
                <td colspan='5' class="noborder"></td>
            </tr>

        </tbody>
    </table>

    <br>

    <table class="noborder nopadding">
        <tr class="font-weight-bold noborder">
            <td class="noborder">Pembayaran harap ditransfer ke:</td>    
            <td class="text-center text-secondary noborder">{{"Tangerang, " . date('d M Y',strtotime($fields->InvoiceDate)) }}</td>    
        </tr>
        <tr class="font-weight-bold noborder">
            <td class="noborder bold">{{ $fields->CompanyName }}</td>            
        </tr>
        <tr class="font-weight-bold noborder">
            <td class="noborder bold">{{ $fields->BankAccountNumber }}</td>            
        </tr>
        <tr class="font-weight-bold noborder">
            <td class="noborder bold">{{ $fields->BankName }}</td>            
        </tr>
        <tr class="font-weight-bold noborder"><td class="noborder"></td></tr>
        <tr class="font-weight-bold noborder"><td class="noborder"></td></tr>
        <tr class="font-weight-bold noborder"><td class="noborder"></td></tr>
        <tr class="font-weight-bold noborder">
            <td class="noborder"></td>
            <td class="text-center text-secondary noborder bold">Handoko Atmodjo, SE. MM</td>            
        </tr>
        <tr class="font-weight-bold noborder">
            <td class="noborder"></td>
            <td class="text-center text-secondary noborder bold">Direktur Utama</td>             
        </tr>
    </table>

    <br>

    <table>
        <td align = "center" class="param-value">{{"KWITANSI INI DIANGGAP SAH SETELAH DANA MASUK KE REKENING " . $fields->CompanyName}}</td>
    </table>

@endsection