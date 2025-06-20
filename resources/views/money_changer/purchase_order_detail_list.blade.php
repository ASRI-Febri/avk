<table class="table table-bordered">
    <thead>
        <tr>
            <th scope="col">#</th>
            <th scope="col">Nama Valas</th>
            
            <th scope="col" class="text-left">Nilai Pembelian</th>
            <th scope="col" class="text-end">Nilai Tukar</th>            
            <th scope="col" class="text-end">Total</th>

            @if(!isset($show_action) || $show_action == TRUE)
            <th scope="col" class="text-center">Action</th>
            @endif
        </tr>
    </thead>
    <tbody>
    @if($records_detail)

        @php 
            $seq = 0; 

            $subtotal_foreign_amount = 0;
			$subtotal_idr = 0;
            $subtotal_untaxed = 0;			
            $subtotal_tax = 0;
        @endphp

        @foreach($records_detail as $row)

            @php 
                $seq += 1;
                $url_delete = url('mc-purchase-order-detail/delete/'.$row->IDX_T_PurchaseOrderDetail); 
                                               
                $subtotal_foreign_amount += ($row->ForeignAmount);
                $subtotal_idr += ($row->ForeignAmount  * $row->ExchangeRate);
                              
            @endphp

            <tr>
                <td>{{ $seq }}</td>
                <td>                    
                    <span>{{ $row->ValasSKU }}</span>
                    <br>
                    <span>{{ $row->ValasChangeName }}</span>   
                    <br>
                    <span>{{ $row->DetailNotes }}</span> 
                </td>                
                <td>    
                    <span>Nilai Pembelian :  {{ $row->ForeignCurrencyID . ' ' . number_format($row->ForeignAmount, 2, '.', ',') }}<span>       
                    <br>
                    <span>Quantity : {{ number_format($row->Quantity, 2, '.', ',') }}</span>    
                    <br>
                    <span>Total : {{ $row->BaseCurrencyID . ' ' . number_format($row->ForeignAmount * $row->ExchangeRate, 2, '.', ',') }}</span>
                </td>
                
                <td class="text-end">{{ $row->BaseCurrencyID . ' ' . number_format($row->ExchangeRate, 2, '.', ',') }}</td>
                <td class="text-end">{{ $row->BaseCurrencyID . ' ' . number_format($row->ForeignAmount  * $row->ExchangeRate, 2, '.', ',') }}</td>

                @if(!isset($show_action) || $show_action == TRUE)
                <td class="text-center">
                    @if($row->POStatus == 'D')
                    <div class="input-group-prepend text-center">
                        <x-btn-edit-detail :id="$row->IDX_T_PurchaseOrderDetail" />
                        <x-btn-delete-detail :id="$row->IDX_T_PurchaseOrderDetail" :label="$row->ValasName" />                    
                    </div>
                    @endif
                </td>
                @endif
            </tr>
        @endforeach
        {{-- <tr class="font-weight-bold">
            <td colspan="4" class="text-right text-secondary">Sub Total</td>
            <td class="text-right text-secondary">Rp {{ number_format($subtotal_untaxed, 2, '.', ',') }}</td>
            <td></td>
        </tr>
        <tr class="font-weight-bold">
            <td colspan="4" class="text-right text-secondary">Tax</td>
            <td class="text-right text-secondary">Rp {{ number_format($subtotal_tax, 2, '.', ',') }}</td>
            <td></td>
        </tr> --}}        
        <tr class="font-weight-bold">
            <td colspan="4" class="text-end"><strong>Total Base Amount</strong></td>
            <td class="text-end"><strong>{{ $row->BaseCurrencyID . ' ' . number_format($subtotal_idr, 2, '.', ',') }}</strong></td>
            <td></td>
        </tr>

    @endif
    </tbody>
</table>