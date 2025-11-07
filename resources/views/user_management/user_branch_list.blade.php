<table class="table table-bordered">
    <thead>
        <tr>
            <th scope="col">#</th>
            <th scope="col">Branch ID</th>
            <th scope="col">Branch Name</th> 
            <th scope="col">Notes</th> 
            <th scope="col">Status</th>            
            @if(!isset($show_action) || $show_action == TRUE)
            <th scope="col" class="text-center">Action</th>
            @endif
        </tr>
    </thead>
    <tbody>
    @if($records_branch)
        @php 
            $seqno = 0;
        @endphp
        @foreach($records_branch as $row)
        @php 
            $seqno += 1;
        @endphp
        <tr>
            <td>{{ $seqno }}</td>
            <td>{{ $row->BranchID }}</td>
            <td>{{ $row->BranchName }}</td>
            <td>{{ $row->BranchRemark }}</td>
            @if($row->RecordStatus == 'A')
            <td class=""><x-badge-info label="Active" /></td>
            @else 
            <td class=""><x-badge-danger label="In-Active" /></td>
            @endif

            @if(!isset($show_action) || $show_action == TRUE)
            <td class="text-center">
            <div class="input-group-prepend text-center">     
                @if($row->RecordStatus == 'I')
                    <x-btn-edit-detail :id="$row->IDX_M_UserBranch" function="activateBranch" />
                @else 
                    <x-btn-delete-detail :id="$row->IDX_M_UserBranch" :label="$row->BranchName" function="deleteBranch" />
                @endif                    
            </div>
            </td>
            @endif
        </tr>
        @endforeach
    @endif
    </tbody>
</table>