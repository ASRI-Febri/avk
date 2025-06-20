<table class="table table-bordered">
    <thead>
        <tr>
            <th scope="col">#</th>
            <th scope="col">Receive ID</th>          
            <th scope="col">Invoice No</th>
            <th scope="col">Receive Date</th>
            <th scope="col">Remark</th>
            <th scope="col">Status Allocation</th>
            <th scope="col" class="text-right">Receive Amount</th>

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
                $url_delete = url('fm-receive-invoice-payment/delete/'.$row->IDX_T_FinancialReceiveHeader);       
            @endphp

            <tr>
                <td>{{ $seq }}</td>
                {{-- <td>                    
                    <span>{{ $row->ReceiveID }}</span>                                       
                </td> --}}

                <td>                    
                    <a href="{{ url('fm-financial-receive/update/' . $row->IDX_T_FinancialReceiveHeader) }}" target="_blank">{{ $row->ReceiveID }}</a>                                       
                </td>
                
                <td>                    
                    <span>{{ $row->DocumentNo }}</span>
                </td>

                <td>                    
                    <span>{{ $row->ReceiveDate }}</span>
                </td>

                <td>                    
                    <span>{{ $row->RemarkHeader }}</span>
                </td>

                <td>        
                    @if($row->AllocationStatus == 'D')                    
                        <x-badge-danger label="Draft" />            
                    @elseif($row->AllocationStatus == 'A') 
                        <x-badge-info label="Approved" />
                    @elseif($row->AllocationStatus == 'C') 
                        <x-badge-danger label="Void" />
                    @endif                     
                </td>

                <td class="text-right">                    
                    <span>{{ number_format($row->ReceiveAmount, 2, '.', ',') }}</span>

                    @php
                        $total_payment += $row->ReceiveAmount;
                    @endphp
                </td>

                @if(!isset($show_action) || $show_action == TRUE)
                <td class="text-center">
                    @if($row->ReceiveStatus == 'D')
                    <div class="input-group-prepend text-center">
                        <a id="btn-edit" class="btn btn-outline-secondary btn-sm" href="{{ url('fm-financial-receive/update/' . $row->IDX_T_FinancialReceiveHeader) }}" title="Edit"
                            onclick="editPayment('{{$row->IDX_T_FinancialReceiveHeader}}')">
                            <i class="fa fa-edit"></i>
                        </a> 
                        {{-- <x-btn-edit-detail :id="$row->IDX_T_FinancialReceiveHeader" />
                        <x-btn-delete-detail :id="$row->IDX_T_FinancialReceiveHeader" :label="$row->ReceiveID" />                     --}}
                    </div>
                    @endif
                </td>
                @endif
            </tr>
        @endforeach
       
        <tr>
            <td colspan="6" class="text-right"><strong>TOTAL</strong></td>
            <td class="text-right"><span><b>{{ number_format($total_payment, 2, '.', ',') }}</b></span></td>
            <td></td>
        </tr>
        
    @endif
    </tbody>
</table>