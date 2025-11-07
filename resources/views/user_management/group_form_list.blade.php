<table class="table table-bordered">
    <thead>
        <tr>
            <th scope="col">#</th>
            <th scope="col">Form ID</th>
            <th scope="col">Form Name</th> 
            <th scope="col">URL</th> 
            <th scope="col" class="text-center">Status</th>            
            @if(!isset($show_action) || $show_action == TRUE)
            <th scope="col" class="text-center">Action</th>
            @endif
        </tr>
    </thead>
    <tbody>
    @if($records_form)
        @foreach($records_form as $row)
        <tr>
            <td></td>
            <td>{{ $row->FormID }}</td>
            <td>{{ $row->FormName }}</td>
            <td>{{ $row->FormURL }}</td>

            @if($row->RecordStatus == 'A')
            <td class="text-center"><x-badge-info label="Active" /></td>
            @else 
            <td class="text-center"><x-badge-danger label="In-Active" /></td>
            @endif

            @if(!isset($show_action) || $show_action == TRUE)
            <td class="text-center">
            <div class="input-group-prepend text-center">     
                @if($row->RecordStatus == 'I')
                <x-btn-edit-detail :id="$row->IDX_M_GroupForm" />
                @endif
                <x-btn-delete-detail :id="$row->IDX_M_GroupForm" :label="$row->FormName" />                    
            </div>
            </td>
            @endif
        </tr>
        @endforeach
    @endif
    </tbody>
</table>