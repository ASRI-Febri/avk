<table class="table table-bordered">
    <thead>
        <tr>
            <th scope="col">#</th>
            <th scope="col">Project ID</th>
            <th scope="col">Project Name</th>             
            <th scope="col">Status</th>            
            @if(!isset($show_action) || $show_action == TRUE)
            <th scope="col" class="text-center">Action</th>
            @endif
        </tr>
    </thead>
    <tbody>
    @if($records_project)
        @foreach($records_project as $row)
        <tr>
            <td></td>
            <td>{{ $row->ProjectID }}</td>
            <td>{{ $row->ProjectName }}</td>            
            @if($row->RecordStatus == 'A')
            <td class=""><x-badge-info label="Active" /></td>
            @else 
            <td class=""><x-badge-danger label="In-Active" /></td>
            @endif

            @if(!isset($show_action) || $show_action == TRUE)
            <td class="text-center">
            <div class="input-group-prepend text-center">     
                @if($row->RecordStatus == 'I')
                    <x-btn-edit-detail :id="$row->IDX_M_UserProject" function="activateProject" />
                @else 
                    <x-btn-delete-detail :id="$row->IDX_M_UserProject" :label="$row->ProjectName" function="deleteProject" />
                @endif                    
            </div>
            </td>
            @endif
        </tr>
        @endforeach
    @endif
    </tbody>
</table>