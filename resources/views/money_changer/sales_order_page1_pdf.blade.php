 

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
            <tr>
                <td colspan="4" class="bold text-right">TOTAL</td>
                <td class="bold text-right">{{ $row->BaseCurrencyID }} {{ number_format($subtotal_base_amount, 2, '.', ',') }}</td>
            </tr>
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