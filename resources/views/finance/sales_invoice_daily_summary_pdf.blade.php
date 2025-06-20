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
        <h1>REKAP HARIAN</h1>
        <table class="noborder nopadding">
            <tr class="noborder nopadding">
                <td class="td-15 bold noborder nopadding param-key">No Invoice</td>
                <td class="td-50 bold noborder nopadding param-value">{{ $fields->InvoiceNo }}</td>
            </tr>
            <tr class="noborder nopadding">
                <td class="td-15 bold noborder nopadding param-key">Upload ID</td>
                <td class="td-50 bold noborder nopadding param-value">{{ $fields->ReferenceNo }}</td>
            </tr>
            <tr class="noborder">
                <td class="td-15 bold noborder nopadding param-key">Tanggal</td>
                <td class="td-50 bold noborder nopadding param-value">{{ date('d M Y',strtotime($fields->InvoiceDate)) }}</td>
            </tr>
        </table>
    </div>

    <br>
    <hr>

    @include('parking.partial_sales_detail')

    <br>

    @include('parking.partial_member_detail')

    

@endsection