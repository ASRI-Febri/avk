<table class="table table-bordered">
    <thead>
        <tr>
            <th scope="col">#</th>
            <th scope="col">Project</th>
            <th scope="col">Description</th>          
            <th scope="col">COA</th>
            <th scope="col">Qty</th>
            <th scope="col">Unit Price</th>
            <th scope="col">Total Sales</th>

            @if(!isset($show_action) || $show_action == TRUE)
            <th scope="col" class="text-center">Action</th>
            @endif
        </tr>
    </thead>
    <tbody>
    @if($records_detail)

        @php 
            $seq = 0;
            $total_sales = 0;             
        @endphp

        @foreach($records_detail as $row)

            @php 
                $seq += 1;
                $url_delete = url('fm-sales-invoice-detail/delete/'.$row->IDX_T_SalesInvoiceDetail);       
            @endphp

            <tr>
                <td>{{ $seq }}</td>
                <td>{{ $row->ProjectName }}</td>
                <td>                    
                    <span>{{ $row->ItemAlias }}</span>
                    <br>
                    <span>{{ $row->ItemDesc }}</span>                                        
                </td>
                
                <td>                    
                    <span>{{ $row->COAID . ' - ' . $row->COADesc }}</span>
                    <br>
                    <span>{{ 'Notes: ' . $row->RemarkDetail }}</span>
                </td>

                <td>                    
                    <span>{{ $row->Quantity . ' ' . $row->UOMID }}</span>
                    <br>
                    <span>{{ 'Untaxed : ' . number_format($row->UntaxedAmount, 2, '.', ',') }}</span>
                    <br>
                    <span>{{ 'Discount : ' . number_format($row->DiscountAmount, 2, '.', ',') }}</span>
                    <br>
                    <span>{{ 'PPN : ' . number_format($row->TaxAmount, 2, '.', ',') }}</span>                                        
                </td>

                <td>                    
                    <span>{{ number_format($row->UnitPrice, 2, '.', ',') }}</span>
                </td>

                <td>                    
                    {{-- <span>{{ number_format(($row->TotalSales + (($row->TaxAmount - $row->DiscountAmount + $row->PPHAmount) * $row->Quantity)), 2, '.', ',') }}</span> --}}
                    <span>{{ number_format(($row->TotalSales), 2, '.', ',') }}</span>

                    @php
                        // $total_sales += ($row->TotalSales + (($row->TaxAmount - $row->DiscountAmount + $row->PPHAmount) * $row->Quantity) );
                        $total_sales += ($row->TotalSales);
                    @endphp
                </td>
                

                @if(!isset($show_action) || $show_action == TRUE)
                <td class="text-center">
                    @if($row->InvoiceStatus == 'D')
                    <div class="input-group-prepend text-center">
                        <x-btn-edit-detail :id="$row->IDX_T_SalesInvoiceDetail" />
                        <x-btn-delete-detail :id="$row->IDX_T_SalesInvoiceDetail" :label="$row->ItemDesc" />                    
                    </div>
                    @endif
                </td>
                @endif
            </tr>
        @endforeach
       
        <tr>
            <td colspan="5"></td>
            <td colspan="3"><span><b>Total: {{ number_format($total_sales, 2, '.', ',') }}</b></span></td>
        </tr>

    @endif
    </tbody>
</table>

@if($records_detail)
    @if($records_detail[0]->InvoiceStatus = 'D')
        {{-- <x-btn-add-detail id="btn-add-tax" label="Add Additional Tax" /> --}}
        <button onclick="addTax('0')" class="btn btn-outline-secondary btn-sm" type="button"><i class="fas fa-plus"></i> Add Additional Tax</button>
        <br><br>
    @endif

    <hr>
    
    <div id="table-salesinvoice-tax" class="table-responsive">
    @include('finance.sales_invoice_tax_list')
    </div>
@endif