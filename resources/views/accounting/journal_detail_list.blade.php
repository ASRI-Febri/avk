<table class="table table-bordered">
    <thead>
        <tr>
            <th scope="col">#</th>   
            <th scope="col">Project</th>           
            <th scope="col">COA</th>
            <th scope="col">Remark</th>
            <th scope="col" class="text-end">Debet</th>
            <th scope="col" class="text-end">Credit</th>

            @if(!isset($show_action) || $show_action == TRUE)
            <th scope="col" class="text-center">Action</th>
            @endif
        </tr>
    </thead>
    <tbody>
    @if($records_detail)

        @php 
            $seq = 0;       
            $groupdebet = 0;     
            $groupcredit = 0;
        @endphp

        @foreach($records_detail as $row)

            @php 
                $seq += 1;
                //$url_delete = url('ac-journal-detail/delete/'.$row->IDX_T_JournalDetail);       
                $groupdebet += $row->BDebetAmount;
                $groupcredit += $row->BCreditAmount;
            @endphp

            <tr>
                <td>{{ $seq }}</td>   
                
                <td>                    
                    <span>{{ $row->ProjectName ?? '' }}</span>
                </td>   
                
                <td>                    
                    <span>{{ $row->COAID . ' - ' . $row->COADesc }}</span>
                </td>               

                <td class="w-40">                    
                    <span>{{ $row->RemarkDetail }}</span>
                </td>

                <td class="text-end">                    
                    <span>{{ number_format($row->BDebetAmount,2,'.',',') }}</span>
                </td>
                
                <td class="text-end">                    
                    <span>{{ number_format($row->BCreditAmount,2,'.',',') }}</span>
                </td>

                @if(!isset($show_action) || $show_action == TRUE)
                <td class="text-center">
                    @if($row->PostingStatus == 'U')
                    <div class="input-group-prepend text-center">
                        <x-btn-edit-detail :id="$row->IDX_T_JournalDetail" />
                        <x-btn-delete-detail :id="$row->IDX_T_JournalDetail" :label="$row->COADesc" function="deleteDetail2"/>  
                        <x-btn-duplicate-detail :id="$row->IDX_T_JournalDetail" />            
                    </div>
                    @endif
                </td>
                @endif
            </tr>
        @endforeach
        <tr>
            <td><td><td></td>
            <td class="text-end">                    
                    <span style="font-weight:bold">TOTAL</span>
                </td>
            <td class="text-end">                    
                <span style="font-weight:bold">{{ number_format($groupdebet,2,'.',',') }}</span>
            </td>
            <td class="text-end">                    
                <span style="font-weight:bold">{{ number_format($groupcredit,2,'.',',') }}</span>
            </td>
            <td></td>
        </tr>
       

    @endif
    </tbody>
</table>