<table class="table table-bordered">
    <thead>
        <tr>
            <th scope="col">#</th>
            <th scope="col">Project</th>
            <th scope="col">COA</th>          
            <th scope="col">Notes</th>
            <th scope="col">Receive Amount</th>

            @if(!isset($show_action) || $show_action == TRUE)
            <th scope="col" class="text-center">Action</th>
            @endif
        </tr>
    </thead>
    <tbody>
    @if($records_detail)

        @php 
            $seq = 0;            
        @endphp

        @foreach($records_detail as $row)

            @php 
                $seq += 1;
                $url_delete = url('fm-financial-receive-detail/delete/'.$row->IDX_T_FinancialReceiveDetail);       
            @endphp

            <tr>
                <td>{{ $seq }}</td>
                <td>{{ $row->ProjectName }}</td>
                
                <td>                    
                    <span>{{ $row->COAID . ' - ' . $row->COADesc }}</span>
                </td>

                <td>                    
                    <span>{{ $row->RemarkDetail }}</span>                                     
                </td>

                <td class="text-right">                    
                    <span>{{ number_format($row->ReceiveAmount, 2, '.', ',') }}</span>
                </td>
                
                @if(!isset($show_action) || $show_action == TRUE)
                <td class="text-center">
                    @if($row->ReceiveStatus == 'D')
                    <div class="input-group-prepend text-center">
                        <a id="btn-allocate" class="btn btn-outline-success btn-sm" href="#" title="Allocate"
                            onclick="allocateDetail('{{ $row->IDX_T_FinancialReceiveDetail }}')">
                            <i class="fa fa-link"></i>
                        </a>
                        <x-btn-edit-detail :id="$row->IDX_T_FinancialReceiveDetail" />
                        <x-btn-delete-detail :id="$row->IDX_T_FinancialReceiveDetail" :label="$row->ReceiveID" />                    
                    </div>
                    @endif
                </td>
                @endif
            </tr>

            @if($allocation_detail)
                @foreach($allocation_detail as $row1)
                    @if($row1->IDX_T_FinancialReceiveDetail == $row->IDX_T_FinancialReceiveDetail)
                        <tr>
                            <td></td>
                            <td></td>
                            
                            <td>                    
                                <span>Allocate To :</span>
                            </td>
            
                            <td>                    
                                <span>{{ $row1->AllocationDate }}</span>
                                <br>
                                <span>{{ $row1->DocumentTypeDesc }}</span>
                                <br>
                                <span>
                                    <a href="{{ url($row1->URLDocument) }}" target="_blank">{{ $row1->DocumentNo }}</a>                                    
                                </span>
                                <br>
                                <span>{{ $row1->PartnerName }}</span>                                  
                            </td>
            
                            <td class="text-right">                    
                                <span>({{ number_format($row1->AllocationAmount, 2, '.', ',') }})</span>
                            </td>
                            
                            @if(!isset($show_action) || $show_action == TRUE)
                            <td class="text-center">
                                @if($row1->AllocationStatus == 'D')
                                <div class="input-group-prepend text-center">
                                    <a id="btn-approve" class="btn btn-outline-success btn-sm" href="#" title="Approve"
                                        onclick="approveAllocation('{{ $row1->IDX_T_ReceiveAllocation }}')">
                                        <i class="fa fa-check"></i>
                                    </a>
                                    <a id="btn-edit" class="btn btn-outline-secondary btn-sm" href="#" title="Edit"
                                        onclick="editAllocation('{{ $row1->IDX_T_ReceiveAllocation }}')">
                                        <i class="fa fa-edit"></i>
                                    </a>
                                    <a id="btn-delete" class="btn btn-outline-danger btn-sm" href="#" title="Delete"
                                        onclick="deleteAllocation('{{ $row1->IDX_T_ReceiveAllocation }}')">
                                        <i class="fa fa-trash"></i>
                                    </a>                  
                                </div>
                                @endif
                            </td>
                            @endif
                        </tr>
                    @endif
                @endforeach
            @endif

        @endforeach
       

    @endif
    </tbody>
</table>