<table class="table table-bordered">
    <thead>
        <tr>
            <th scope="col">#</th>
            <th scope="col">Group ID</th>
            <th scope="col">Group Name</th> 
            <th scope="col">Notes</th> 
            <th scope="col">Status</th>            
            @if(!isset($show_action) || $show_action == TRUE)
            <th scope="col" class="text-center">Action</th>
            @endif
        </tr>
    </thead>
    <tbody>
    @if($records_group)
        @foreach($records_group as $row)
        <tr>
            <td></td>
            <td>{{ $row->GroupID }}</td>
            <td>{{ $row->GroupName }}</td>
            <td>{{ $row->Notes }}</td>
            @if($row->RecordStatus == 'A')
            <td class=""><x-badge-info label="Active" /></td>
            @else 
            <td class=""><x-badge-danger label="In-Active" /></td>
            @endif

            @if(!isset($show_action) || $show_action == TRUE)
            <td class="text-center">
            <div class="input-group-prepend text-center">     
                @if($row->RecordStatus == 'I')
                    <x-btn-edit-detail :id="$row->IDX_M_UserGroup" function="activateGroup"/>
                @else 
                    <x-btn-delete-detail :id="$row->IDX_M_UserGroup" :label="$row->GroupName" function="deleteGroup"/>
                @endif                                    
            </div>
            </td>
            @endif
        </tr>
        @endforeach
    @endif
    </tbody>
</table>