<table class="table table-bordered">
    <thead>
        <tr>
            <th scope="col">#</th>
            <th scope="col">Valas</th>
            <th scope="col" class="text-end">Opening Qty</th>
            <th scope="col" class="text-end">Opening Value</th>
            <th scope="col" class="text-end">Closing Qty</th>
            <th scope="col" class="text-end">Closing Value</th>            
            
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
                //$url_delete = url('mc-purchase-order-detail/delete/'.$row->IDX_T_OpenCloseDailyDetail); 
                                               
                $subtotal_foreign_amount += ($row->OpenQty);
                $subtotal_idr += ($row->CloseQty);
                              
            @endphp

            <tr>
                <td>{{ $seq }}</td>
                
                <td>                    
                    <span>{{ $row->ValasSKU }}</span>
                    <br>
                    <span>{{ $row->ValasChangeName }}</span>   
                </td>                
                
                <td class="text-end">{{ number_format($row->OpenQty, 2, '.', ',') }}</td>
                <td class="text-end">{{ $row->CurrencyID . ' ' . number_format($row->OpenQty * $row->ValasChangeNumber, 2, '.', ',') }}</td>
                <td class="text-end">{{ number_format($row->CloseQty, 2, '.', ',') }}</td>
                <td class="text-end">{{ $row->CurrencyID . ' ' . number_format($row->CloseQty * $row->ValasChangeNumber, 2, '.', ',') }}</td>

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
        {{-- <tr class="font-weight-bold">
            <td colspan="5" class="text-end"><strong>Total</strong></td>
            <td class="text-end"><strong>{{ number_format($subtotal_idr, 2, '.', ',') }}</strong></td>
            <td></td>
        </tr> --}}

    @endif
    </tbody>
</table>