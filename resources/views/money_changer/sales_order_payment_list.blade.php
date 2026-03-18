<table class="table table-bordered">
    <thead>
        <tr>
            <th scope="col">#</th>
            <th scope="col">Kode</th>
            <th scope="col">Tanggal</th>
            <th scope="col">Cara Bayar</th>
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

            $total_receive_amount = 0;
			
        @endphp

        @foreach($records_payment as $row)

            @php 
                $seq += 1;
                //$url_delete = url('mc-purchase-order-detail/delete/'.$row->IDX_T_SalesOrderDetail); 
                                               
                $total_receive_amount += ($row->ReceiveAmount);
                
            @endphp

            <tr>
                <td>{{ $seq }}</td>
                <td>
                    <a href="{{ url('fm-financial-receive/update') . '/' . $row->IDX_T_FinancialReceiveHeader }}" target="_blank" rel="noopener noreferrer">
                        {{ $row->ReceiveID }}
                    </a>
                </td>
                <td>{{ date('d M Y', strtotime($row->ReceiveDate)) }}</td>
                <td>{{ $row->FinancialAccountDesc }}</td>
                <td>{{ $row->RemarkHeader }}</td>
                <td class="text-end">{{ number_format($row->ReceiveAmount, 2, '.', ',') }}</td>
               
                @if(!isset($show_action) || $show_action == TRUE)
                <td class="text-center">
                    @if($row->ReceiveStatus == 'D')
                    <div class="input-group-prepend text-center">
                        <x-btn-edit-detail :id="$row->IDX_T_FinancialReceiveHeader" />
                        <x-btn-delete-detail :id="$row->IDX_T_FinancialReceiveHeader" :label="$row->FinancialAccountDesc" function="deleteDetailValas" />                    
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
            <td colspan="5" class="text-end"><strong>Total </strong></td>
            <td class="text-end"><strong>{{  number_format($total_receive_amount, 2, '.', ',') }}</strong></td>
            <td></td>
        </tr>

    @endif
    </tbody>
</table>