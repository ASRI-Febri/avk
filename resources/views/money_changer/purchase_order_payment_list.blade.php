<table class="table table-bordered">
    <thead>
        <tr>
            <th scope="col">#</th>
            <th scope="col">Metode Pembayaran</th>   
            <th scope="col">Kode Pembayaran</th>  
            <th scope="col">Keterangan</th>                
            <th scope="col" class="text-end">Jumlah Pembayaran</th>

            @if(!isset($show_action) || $show_action == TRUE)
            <th scope="col" class="text-center">Action</th>
            @endif
        </tr>
    </thead>
    <tbody>
    @if($records_payment)

        @php 
            $seq = 0; 

            $total_payment_amount = 0;
			
        @endphp

        @foreach($records_payment as $row)

            @php 
                $seq += 1;
                //$url_delete = url('mc-purchase-order-detail/delete/'.$row->IDX_T_SalesOrderDetail); 
                                               
                $total_payment_amount += ($row->PaymentAmount);
                
            @endphp

            <tr>
                <td>{{ $seq }}</td>
                <td>{{ $row->FinancialAccountDesc }}</td>
                <td>{{ $row->PaymentID }}</td>
                <td>{{ $row->RemarkDetail }}</td>
                <td class="text-end">{{ number_format($row->PaymentAmount, 2, '.', ',') }}</td>
               
                @if(!isset($show_action) || $show_action == TRUE)
                <td class="text-center">
                    @if($row->PaymentStatus == 'D')
                    <div class="input-group-prepend text-center">
                        <x-btn-edit-detail :id="$row->IDX_T_FinancialPaymentHeader" />
                        <x-btn-delete-detail :id="$row->IDX_T_FinancialPaymentHeader" :label="$row->FinancialAccountDesc" function="deleteDetailValas" />                    
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
            <td colspan="4" class="text-end"><strong>Total </strong></td>
            <td class="text-end"><strong>{{  number_format($total_payment_amount, 2, '.', ',') }}</strong></td>
            <td></td>
        </tr>

    @endif
    </tbody>
</table>