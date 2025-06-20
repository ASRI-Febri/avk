<table class="table table-bordered">
    <thead>
        <tr>
            <th scope="col">#</th>
            <th scope="col">Tax Desc</th>          
            <th scope="col" class="text-right">Tax Amount</th>

            @if(!isset($show_action) || $show_action == TRUE)
            <th scope="col" class="text-center">Action</th>
            @endif
        </tr>
    </thead>
    <tbody>
    @if($tax_detail)

        @php 
            $seq = 0;
            $total_tax = 0;            
        @endphp

        @foreach($tax_detail as $row)

            @php 
                $seq += 1;
                $url_delete = url('fm-purchase-invoice-tax/delete/'.$row->IDX_T_PurchaseInvoiceTax);       
            @endphp

            <tr>
                <td>{{ $seq }}</td>
                <td>                    
                    <span>{{ $row->TaxDesc }}</span>
                    <br>
                    <span>{{ 'Tax Account: ' . $row->COAID . ' - ' . $row->COADesc }}</span>
                    <br>
                    <span>{{ 'Tax Rate: ' . $row->TaxRate }}</span>                                       
                </td>
                
                <td class="text-right">                    
                    <span>{{ number_format($row->TaxAmount * $row->Quantity, 2, '.', ',') }}</span>

                    @php
                        $total_tax += $row->TaxAmount * $row->Quantity;
                    @endphp
                </td>

                @if(!isset($show_action) || $show_action == TRUE)
                <td class="text-center">
                    @if($row->InvoiceStatus == 'D')
                    <div class="input-group-prepend text-center">
                        <a id="btn-edit" class="btn btn-outline-secondary btn-sm" href="#" title="Edit"
                            onclick="editTax('{{$row->IDX_T_PurchaseInvoiceTax}}')">
                            <i class="fa fa-edit"></i>
                        </a>
                        <a id="btn-delete" class="btn btn-outline-danger btn-sm" href="#" title="Delete" 
                            onclick="deleteTax('{{$row->IDX_T_PurchaseInvoiceTax}}','{{$row->TaxDesc}}')">
                            <i class="fa fa-trash"></i>
                        </a>
                    </div>
                    @endif
                </td>
                @endif
            </tr>
        @endforeach
       
        <tr>
            <td colspan="2"></td>
            <td colspan="2" class="text-right"><span><b>Total: {{ number_format($total_tax, 2, '.', ',') }}</b></span></td>
        </tr>

    @endif
    </tbody>
</table>