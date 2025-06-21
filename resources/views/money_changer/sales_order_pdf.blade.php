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
                    <span style="display:block;">Phone: {{ $fields->WhatsappNo }} </span>                   
                </td>
            </tr>            
        </table>  
    </div>

    <div style="float:left;width:40%">
        <h2>Sales Order</h2>
        <table class="noborder nopadding">
            <tr class="noborder nopadding">
                <td class="td-10 bold noborder nopadding param-key">No Nota</td>
                <td class="td-50 bold noborder nopadding param-value">{{ $fields->SONumber }}</td>
            </tr>
            <tr class="noborder">
                <td class="td-10 bold noborder nopadding param-key">Date</td>
                <td class="td-50 bold noborder nopadding param-value">{{ date('d M Y',strtotime($fields->SODate)) }}</td>
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

    <div style="float:left;width:40%">
        <span class="bold" style="display:block;">Customer</span>
        <span style="display:block;">{{ $fields->PartnerName }}</span>
        {{-- <span style="display:block;">{{ $fields->PartnerStreet }}</span> --}}
        {{-- <span style="display:block;">Phone: {{ $fields->PartnerPhone }}</span> --}}
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
                <td class="bold">Our Order Reference</td>
                <td class="bold">Your Order Reference</td>
                <td class="bold">Validated By</td>
            </tr>
        </thead>
        <tbody>
            <tr>                
                <td>{{ $fields->SONumber }}</td>
                <td>{{ $fields->ReferenceNo }}</td>
                <td>{{ $fields->UCreateName }}</td>
            </tr>
        </tbody>        
    </table>

    <br>

    <table class="table noborder">
    <thead>
        <tr style="border-bottom: 0.5px;">        
            <th class="noborder" style="border-bottom: 1px solid;">No</th>    
            <th class="noborder" style="border-bottom: 1px solid;" scope="col">Description</th>            
            <th class="noborder text-right" style="border-bottom: 1px solid;" scope="col" class="text-left">Qty</th>
            <th class="noborder text-right" style="border-bottom: 1px solid;" scope="col" class="text-right">Foreign Amount</th>            
            <th class="noborder text-right" style="border-bottom: 1px solid;" scope="col" class="text-right">Rate</th>
            <th class="noborder text-right" style="border-bottom: 1px solid;" scope="col" class="text-right">Base Amount</th>           
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
                $subtotal_base_amount += ($row->BaseCurrencyAmount);
                
            @endphp

            <tr class="noborder">
                <td class="text-center noborder">{{ $seq }}</td>
                <td class="noborder">
                    <span style="display:block;">{{ $row->ValasSKU }}</span>
                    <span style="display:block;">{{ $row->ValasName }}</span>
                    <span style="display:block;">{{ $row->DetailNotes }}</span>
                </td>
                <td class="text-right noborder">{{ number_format($row->Quantity,0,'.',',') }}</td>
                {{-- <td>
                    <span>{{ $row->Quantity . ' ' . $row->UoMName }}</span>
                    <hr>
                    <span>PRICE : Rp {{ number_format($row->ForeignAmount, 2, '.', ',') }}<span>       
                    <br>
                    <span>DISC : Rp {{ number_format($row->DiscountAmount, 2, '.', ',') }}</span>    
                    <br>
                    <span>NETT : Rp {{ number_format($row->ForeignAmount - $row->DiscountAmount, 2, '.', ',') }}</span>    
                    <hr>
                    <span>DPP : Rp {{ number_format($row->UntaxedAmount, 2, '.', ',') }}</span>      
                    <br>
                    <span>VAT : Rp {{ number_format($row->TaxAmount, 2, '.', ',') }}</span> 
                </td> --}}
                <td class="text-right noborder">{{ $row->ForeignCurrencyID . ' ' . number_format($row->ForeignAmount, 2, '.', ',') }}</td>
                <td class="text-right noborder">{{ number_format($row->ExchangeRate, 2, '.', ',') }}</td>
                <td class="text-right noborder">{{ $row->BaseCurrencyID . ' ' . number_format($row->BaseCurrencyAmount, 2, '.', ',') }}</td>
            </tr>

        @endforeach

        <tr class="noborder">
            <td class="noborder" colspan="6"><hr style="border: 0.5px;"></td>
        </tr>
        
        <tr class="font-weight-bold noborder">
            <td colspan="2" rowspan="2">
                Catatan:
                <br/>
                Transaksi tidak dapat dibatalkan
            </td>
            <td colspan="3" class="text-right text-secondary noborder bold">Sub Total</td>
            <td class="text-right text-secondary noborder bold">{{ $row->ForeignCurrencyID . ' ' . number_format($subtotal_foreign_amount, 2, '.', ',') }}</td>            
        </tr>
        <tr class="font-weight-bold noborder">
            <td colspan="3" class="text-right text-secondary noborder bold">Sub Total</td>
            <td class="text-right text-secondary noborder bold">{{ $row->BaseCurrencyID . ' ' . number_format($subtotal_base_amount, 2, '.', ',') }}</td>            
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