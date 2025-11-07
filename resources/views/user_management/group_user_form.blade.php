@extends('layouts.master-form-with-log')

@section('right_header')    

    @if($state !== 'create')        
        <x-btn-create-new label="Create New" :url="$url_create" /> 
    @endif 
    @include('form_helper.btn_save_header')
@endsection

@section('content-form')

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_M_Group" name="IDX_M_Group" value="{{ $fields->IDX_M_Group }}"/>

    <x-textbox-horizontal label="Group ID" id="GroupID" :value="$fields->GroupID" placeholder="" class="required" />
    <x-textbox-horizontal label="Group Name" id="GroupName" :value="$fields->GroupName" placeholder="" class="required" />
    <x-textbox-horizontal label="Notes" id="Notes" :value="$fields->Notes" placeholder="" class="required" />

    
    <x-checkbox-horizontal id="add-new-after-save" name="add-new-after-save" label="add new data after save ?" :value="''" checked="" />
    <br><br>
    
    @if($state != 'create')           
    <hr>
    <ul class="nav nav-tabs pb-3" role="tablist">    
        <li class="nav-item">
        <a class="nav-link text-muted active" href="#form" role="tab" data-toggle="tab"><i class="fas fa-align-justify"></i> <strong>Group Access</strong></a>
        </li>
    </ul>
    <div class="tab-content mb-3">
        <div role="tabpanel" class="tab-pane fade in active" id="form"> 
            <div class="card">
                <div class="card-body">
                    <x-btn-add-detail id="btn-add-detail" label="Add New Access" />
                    <br><br>       

                    <div id="table-form" class="table-responsive">
                        @include('user_management.group_form_list')            
                    </div>
                </div>
            </div>
        </div>
    </div>
    @endif

    

    {{-- <hr>
    <h6 class="text-secondary">Role Access Setting</h6>

    @if($records_form)
        @php 
            $group_a1 = '';
            $group_a2 = '';
        @endphp
        @foreach ($records_form as $row)
            
            @php 
                $group_a1 = $row->ApplicationName;
            @endphp

            @if($group_a1 <> $group_a2)
                <p class="text-secondary font-weight-bold mt-3">{{ $row->ApplicationName }}</p>
                @php 
                    $group_a2 = $group_a1;
                @endphp
            @endif 
            <x-checkbox-horizontal :id="$row->IDX_M_Form" name="chk_box[]" :label="$row->FormName" :value="$row->IDX_M_Form" :checked="$row->CheckList" />
            <br>
        @endforeach
    @endif --}}    

@endsection

@section('script')

    <script>  

        function deleteDetail(idx,item_description)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('sm-group-form/delete') }}";
            
            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();       

            var data = {
                "_token": $('#_token').val(),
                "IDX_M_Group": $("#IDX_M_Group").val(),
                "IDX_M_GroupForm": idx,
                "FormName": item_description
            }
            
            callAjaxModalView(url,data);
        }

        function editDetail(idx)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('sm-group-form/update') }}"+'/'+idx;

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_M_Group": $("#IDX_M_Group").val(),
                "IDX_M_GroupForm": idx            
            }
            
            callAjaxModalView(url,data);
        }

        $(document).ready(function()
        {
            var detailTable = $("#table-group").dataTable({
                "responsive": true,
                stateSave: false,
                "pagingType": 'full_numbers', 
                "language": {
                    search: '<span>Filter:</span> _INPUT_',
                    lengthMenu: '<span>Show:</span> _MENU_',
                    paginate: { 'first': 'First', 'last': 'Last', 'next': '>', 'previous': '<' }
                },
                "iDisplayLength": 10,
                "bPaginate": true,		
                "dom": '<"datatable-header"fl><"datatable-scroll"t><"datatable-footer"ip>',								
                "aLengthMenu": [[10, 25, 50, 100], [10, 25, 50, 100]]
            });

            $('#btn-add-detail').click(function()
            {   
                var data = {
                    _token: $("#_token").val(),
                    IDX_M_Group: $("#IDX_M_Group").val(),
                    GroupID: $("#GroupID").val(),
                    GroupName: $("#GroupName").val(),
                }                

                callAjaxModalView('{{ url('sm-group-form/create') }}',data);            
            });

        });

    </script>

@endsection