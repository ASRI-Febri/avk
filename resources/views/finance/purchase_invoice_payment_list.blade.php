<table class="table table-bordered">
    <thead>
        <tr>
            <th scope="col">#</th>
            <th scope="col">Payment ID</th>          
            <th scope="col">Invoice No</th>
            <th scope="col">Payment Date</th>
            <th scope="col">Remark</th>
            <th scope="col">Status</th>
            <th scope="col">Payment Amount</th>

            @if(!isset($show_action) || $show_action == TRUE)
            <th scope="col" class="text-center">Action</th>
            @endif
        </tr>
    </thead>
    <tbody>
    @if($payment_detail)

        @php 
            $seq = 0;
            $total_payment = 0;            
        @endphp

        @foreach($payment_detail as $row)

            @php 
                $seq += 1;
                // $url_delete = url('fm-purchase-invoice-payment/delete/'.$row->IDX_T_FinancialPaymentHeader);       
            @endphp

            <tr>
                <td>{{ $seq }}</td>
                {{-- <td>                    
                    <span>{{ $row->PaymentID }}</span>                                       
                </td> --}}

                <td>                    
                    <a href="{{ url('fm-financial-payment/update/' . $row->IDX_T_FinancialPaymentHeader) }}" target="_blank">{{ $row->PaymentID }}</a>                                       
                </td>
                
                <td>                    
                    <span>{{ $row->DocumentNo }}</span>
                </td>

                <td>                    
                    <span>{{ $row->PaymentDate }}</span>
                </td>

                <td>                    
                    <span>{{ $row->RemarkHeader }}</span>
                </td>

                <td>                    
                    <span>{{ $row->StatusDesc }}</span>
                </td>

                <td>                    
                    <span>{{ number_format($row->PaymentAmount, 2, '.', ',') }}</span>

                    @php
                        $total_payment += $row->PaymentAmount;
                    @endphp

                </td>

                @if(!isset($show_action) || $show_action == TRUE)
                <td class="text-center">
                    @if($row->PaymentStatus == 'D')
                    <div class="input-group-prepend text-center">
                        <a id="btn-edit" class="btn btn-outline-secondary btn-sm" href="{{ url('fm-financial-payment/update/' . $row->IDX_T_FinancialPaymentHeader) }}" title="Edit">
                            <i class="fa fa-edit"></i>
                        </a>              
                    </div>
                    @endif
                </td>
                @endif
            </tr>
        @endforeach
       
        <tr>
            <td colspan="6"></td>
            <td colspan="2"><span><b>Total: {{ number_format($total_payment, 2, '.', ',') }}</b></span></td>
        </tr>

    @endif
    </tbody>
</table>