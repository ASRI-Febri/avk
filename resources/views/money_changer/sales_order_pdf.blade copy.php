@extends('layouts.pdf')

@section('title')
    {{ $fields->SONumber }}
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
            <tr class="noborder nopadding">
                <td class="td-85 bold noborder nopadding param-value">
                    <span style="display:block;">{{ $fields->LegalAddress }}</span>
                    
                    <span style="display:block;">Phone: {{ $fields->Phone }} </span>  
                    <span style="display:block;">Whatsapp: {{ $fields->WhatsappNo }} </span>                   
                </td>
            </tr>            
        </table>  
    </div>

    <div style="float:left;width:40%">
        <h2>Nota Transaksi Valas</h2>
        <table class="noborder nopadding">
            <tr class="noborder nopadding">
                <td class="td-20 bold noborder nopadding param-key">No Transaksi</td>
                <td class="td-50 bold noborder nopadding param-value">: {{ $fields->SONumber }}</td>
            </tr>
            <tr class="noborder">
                <td class="td-20 bold noborder nopadding param-key">Tanggal</td>
                <td class="td-50 bold noborder nopadding param-value">: {{ date('d M Y',strtotime($fields->SODate)) }}</td>
            </tr>
        </table>
        
    </div>

    <br>

    {{-- <div style="float:left; width:50%">
        <p><strong>Vendor</strong></p>
        <p>{{ $fields->PartnerName }}</p>
        <p>{{ $fields->PartnerStreet }}</p>
        <p>{{ $fields->PartnerPhone }}</p>
    </div>

    <div style="float:left; width:50%; margin-bottom:5px;">       
        <p><strong>Shipping Address</strong></p>
        <p>{{ $fields->ShippingAddress }}</p>
    </div>

    <br/> --}}

    {{-- <div style="float:left;width:60%">
        <span class="bold" style="display:block;">Shipping Address</span>
        <span>{{ $fields->ShippingAddress }}</span>

        @if($fields->IDX_M_Project > 1)
        <br><br>
        <tr class="noborder">
            <td class="td-50 noborder param-value">Project {{ $fields->ProjectName }}</td>
            
        </tr>
        @endif
    </div> --}}

    <div style="float:left;width:25%">
        <span class="bold" style="display:block;">Customer</span>
        <span style="display:block;">{{ $fields->PartnerName }}</span>
        
    </div>
    <div style="float:left;width:25%">
        <span class="bold" style="display:block;">No KTP</span>
        <span style="display:block;">{{ $fields->SingleIdentityNumber }}</span>
        
    </div>
    <div style="float:left;width:25%">
        <span class="bold" style="display:block;">Sumber Dana</span>
        <span style="display:block;">{{ $fields->FundSource }}</span>
        
    </div>
    <div style="float:left;width:25%">
        <span class="bold" style="display:block;">Tujuan Transaksi</span>
        <span style="display:block;">{{ $fields->TransactionPurpose }}</span>
        
    </div>

    {{-- <br>

    <table class="noborder nopadding">
        <tr class="noborder nopadding">
            <td class="td-50 bold noborder nopadding param-key">Vendor</td>
            <td class="td-50 bold noborder nopadding param-key">Shipping Address</td>
        </tr>
        <tr class="noborder">
            <td class="td-50 noborder nopadding param-value">{{ $fields->PartnerName }}</td>
            <td class="td-50 noborder nopadding param-value">{{ $fields->ShippingAddress }}</td>
        </tr>
        <tr class="noborder">
            <td class="td-50 noborder nopadding param-value">{{ $fields->PartnerStreet }}</td>
            <td class="td-50 noborder nopadding param-key">PO Description</td>
        </tr>
        <tr class="noborder">
            <td class="td-50 noborder nopadding param-value">{{ $fields->PartnerPhone }}</td>
            <td class="td-50 noborder nopadding param-value">{{ $fields->PODescription }}</td>
        </tr>
        @if($fields->IDX_M_Project > 1)
        <tr class="noborder">
            <td class="td-50 noborder param-value">Project {{ $fields->ProjectName }}</td>
            
        </tr>
        @endif
    </table> --}}

    <br>

   
   
    <table>
        <thead>
            <tr>   
                <td class="bold">Jual/Beli</td>
                <td class="bold">Keterangan</td>
                <td class="bold text-right">Nilai Tukar</td>
                <td class="bold text-right">Nilai Valas</td>
                <td class="bold text-right">Nilai Rupiah</td>
            </tr>
        </thead>
        <tbody>
            @if($records_detail)
            @foreach($records_detail as $row)
            <tr>   
                <td>{{ $row->TransactionTypeName }}</td>
                <td>
                    {{ $row->ValasSKU }} X {{ number_format($row->Quantity,0,'.',',') }}
                </td>
                <td class="text-right">
                    {{ number_format($row->ExchangeRate, 2, '.', ',') }}
                </td>  
                <td class="text-right">
                    {{ $row->ForeignCurrencyID . ' ' . number_format($row->ForeignAmount, 2, '.', ',') }}
                </td> 
                <td class="text-right">
                    {{ $row->BaseCurrencyID . ' ' . number_format($row->ForeignAmount  * $row->ExchangeRate, 2, '.', ',') }}
                </td>                   
            </tr>
            @endforeach
            @endif
        </tbody>        
    </table>
    

    <br>

    <table>
        <thead>
            <tr>                
                <td class="bold w-50 td-50">Catatan</td>
                <td class="bold w-20 td-25 text-center">Teller</td>
                <td class="bold w-20 td-25 text-center">Customer</td>
            </tr>
        </thead>
        <tbody>
            <tr>                
                <td class="w-50">
                    Harap periksa kembali transaksi Anda, pengaduan setelah meninggalkan loket tidak akan kami layani.
                    <br>
                    Sesuai ketentuan Bank Indonesia PIB No 12/3/210 dan PBI No 18/20/2016, Customer wajib memberikan 
                    foto copy kartu identitas diri dan setiap transaksi minimum 25.000 USD, Customer wajib memberikan 
                    informasi tujuan transaksi (underlying)
                </td>
                <td class="w-20">&nbsp;</td>
                <td class="w-20">&nbsp;</td>
            </tr>
        </tbody>        
    </table>

    <br>

    <table class="table noborder">
    <thead>
        <tr style="border-bottom: 0.5px;">        
            <th class="noborder w-5" style="border-bottom: 1px solid; width: 5%;">No</th>    
            <th class="noborder w-20" style="border-bottom: 1px solid; width: 20%;" scope="col">Description</th>            
            <th class="noborder text-right w-10" style="border-bottom: 1px solid; width: 10%;" scope="col" class="text-left">Qty</th>
            <th class="noborder text-right w-20" style="border-bottom: 1px solid; width: 10%;" scope="col" class="text-right">Foreign Amount</th>            
            <th class="noborder text-right w-20" style="border-bottom: 1px solid; width: 10%;" scope="col" class="text-right">Rate</th>
            <th class="noborder text-right w-20" style="border-bottom: 1px solid; width: 10%;" scope="col" class="text-right">Base Amount</th>           
        </tr>
    </thead>
    <tbody>
    @if($records_detail)

        @php 
            $seq = 0; 

            $subtotal_foreign_amount = 0;
            $subtotal_base_amount = 0;			
             
        @endphp

        @foreach($records_detail as $row)

            @php 
                $seq += 1;
                $url_delete = url('mc-sales-order-detail/delete/'.$row->IDX_T_SalesOrderDetail); 

                $subtotal_foreign_amount += ($row->ForeignAmount);
                $subtotal_base_amount += ($row->ForeignAmount  * $row->ExchangeRate);
                
            @endphp

            <tr class="noborder">
                <td class="text-center noborder w-5">{{ $seq }}</td>
                <td class="noborder w-20">
                    <span style="display:block;">{{ $row->ValasSKU }}</span>
                    <span style="display:block;">{{ $row->ValasName }}</span>
                    <span style="display:block;">{{ $row->DetailNotes }}</span>
                </td>
                <td class="text-right noborder w-10">{{ number_format($row->Quantity,0,'.',',') }}</td>              
                <td class="text-right noborder">{{ $row->ForeignCurrencyID . ' ' . number_format($row->ForeignAmount, 2, '.', ',') }}</td>
                <td class="text-right noborder">{{ number_format($row->ExchangeRate, 2, '.', ',') }}</td>
                <td class="text-right noborder">{{ $row->BaseCurrencyID . ' ' . number_format($row->ForeignAmount  * $row->ExchangeRate, 2, '.', ',') }}</td>
            </tr>

        @endforeach

       <tr class="noborder">
            <td class="noborder" colspan="6"><hr style="border: 0.5px;"></td>
        </tr>
        
        <tr class="font-weight-bold noborder">
            <td colspan="4" rowspan="2" class="noborder">
                Catatan:
                <br/>
                Harap periksa kembali transaksi Anda, pengaduan setelah meninggalkan loket tidak akan kami layani.
                <br>
                Sesuai ketentuan Bank Indonesia PIB No 12/3/210 dan PBI No 18/20/2016, Customer wajib memberikan foto copy 
                kartu identitas diri dan setiap transaksi minimum 25.000 USD, Customer wajib memberikan informasi 
                tujuan transaksi (underlying)
            </td>            
            <td colspan="2" class="text-right text-secondary noborder bold">TOTAL {{ $row->BaseCurrencyID }} {{ number_format($subtotal_base_amount, 2, '.', ',') }}</td>   
        </tr>
    @endif
    </tbody>
    </table>
    
    <br>
    
    {{-- <table class="noborder nomargin" cellspacing="0">
        <tr class="noborder nomargin">     
            <td class="td-25 noborder nomargin" style="text-align: center;"></td>            
            <td class="td-100 noborder nomargin" colspan="4" style="text-align: center;">Disetujui Oleh,</td> 
           
        </tr>
        <tr class="noborder nomargin"> 
            <td class="noborder" colspan="4" height="90px;" style="">&nbsp;</td>
        </tr>
        <tr class="noborder nomargin">     
            <td class="td-35 noborder nomargin" style="text-align: center;">
                (
                @for($i=0; $i < 20; $i++)    
                    &nbsp;
                @endfor
                )
            </td>
            <td class="td-30 noborder nomargin" colspan="2" style="text-align: center;">
                (
                @for($i=0; $i < 25; $i++)    
                    &nbsp;
                @endfor
                )
            </td>
            <td class="td-35 noborder nomargin" colspan="2" style="text-align: center;">
                (
                @for($i=0; $i < 25; $i++)    
                    &nbsp;
                @endfor
                )
            </td>
        </tr>
        <tr class="noborder nomargin">     
            <td class="td-35 noborder nomargin" style="text-align: center;">Supplier / Kontraktor Project</td>
            <td class="td-30 noborder nomargin" colspan="2" style="text-align: center;"></td>
            <td class="td-35 noborder nomargin" colspan="2" style="text-align: center;">Direktur</td>
        </tr>
    </table> --}}
    


    {{-- <table class="noborder">
        <tr class="noborder">
            <td class="td-15 bold noborder">Company</td>
            <td class="td-35 noborder">{{ $fields->CompanyName }}</td>
            <td class="td-15 bold noborder">Branch</td>
            <td class="td-35 noborder">{{ $fields->BranchName }}</td>
        </tr>
        <tr class="noborder">            
            <td class="td-15 bold noborder">Order No</td>
            <td class="td-35 noborder">{{ $fields->PONumber }}</td>
            <td class="td-15 bold noborder">Vendor</td>
            <td class="td-35 noborder">{{ $fields->PartnerName }}</td>
        </tr>
        <tr class="noborder">            
            <td class="td-15 bold noborder">Order Date</td>
            <td class="td-35 noborder">{{ date('d M Y',strtotime($fields->PODate)) }}</td>
            <td class="td-15 bold noborder">Expected Date</td>
            <td class="td-35 noborder">{{ date('d M Y',strtotime($fields->POExpectedDate)) }}</td>           
        </tr>        
        <tr class="noborder">       
            <td class="td-15 bold noborder">Notes</td>
            <td class="td-35 noborder">{{ $fields->PODescription }}</td>                 
        </tr>
        <tr class="noborder">
                        
        </tr>
    </table> --}}
    <br>
   
    

@endsection