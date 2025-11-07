@extends('layouts.master-form-with-log')

@section('right_header')   

    @if($state !== 'create')        
        <x-btn-create-new label="Create New" :url="$url_create" />
        <button id="btn-reset" class="btn btn-outline-dark btn-sm" type="button">
            <i class="fas fa-key"></i> 
            Reset Password
        </button>
        {{-- <a href="{{ $url_reset }}" class="btn btn-outline-secondary btn-sm" type="button" id="btn-reset"><i class="fas fa-key"></i> Reset Password</a> --}}
    @endif 
    
    @include('form_helper.btn_save_header')
@endsection

@section('form-remark')
    User ID untuk akses sistem informasi AVK
@endsection

@section('content-form')

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_M_User" name="IDX_M_User" value="{{ $fields->IDX_M_User }}"/>
    
    <x-textbox-horizontal label="User ID" id="LoginID" :value="$fields->LoginID" placeholder="" class="required" />
    <x-textbox-horizontal label="User Name" id="Name" :value="$fields->Name" placeholder="User Name" class="required" />
    <x-textbox-horizontal label="Alias" id="Alias" :value="$fields->Alias" placeholder="" class="" />
    <x-textbox-horizontal label="Email" id="Email" :value="$fields->Email" placeholder="" class="" />

    <x-select-horizontal label="Gender" id="IDX_M_Gender" :value="$fields->IDX_M_Gender" class="required" :array="$dd_gender"/>
    <x-textbox-horizontal label="Notes" id="Notes" :value="$fields->Notes" placeholder="" class="" />

    @if($state == 'create')
    <div class="form-group row">
        <label class="col-sm-3 col-form-label text-secondary">Password</label>
        <div class="col-sm-9">
            <input type="password" id="Password2" name="Password2" class="form-control required" placeholder="" value="">
        </div>
    </div>
    <div class="form-group row">
        <label class="col-sm-3 col-form-label text-secondary">Re-type Password</label>
        <div class="col-sm-9">
            <input type="password" id="Password2Confirm" name="Password2Confirm" class="form-control required" placeholder="" value="">
        </div>
    </div>
    @endif 
        
    <!-- MAPPING GROUP, BRANCH & PROJECT -->
    @if($state != 'create')           
        <hr>
        <ul class="nav nav-tabs pb-3" role="tablist">    
            <li class="nav-item">
            <a class="nav-link text-muted active" href="#group" role="tab" data-toggle="tab"><i class="fas fa-align-justify"></i> <strong>Group User</strong></a>
            </li>
            <li class="nav-item">
            <a class="nav-link text-muted" href="#branch" role="tab" data-toggle="tab"><i class="fas fa-list"></i> <strong>Branch</strong></a>
            </li>
            <li class="nav-item">
            <a class="nav-link text-muted" href="#project" role="tab" data-toggle="tab"><i class="fas fa-cogs"></i> <strong>Project</strong></a>
            </li>            
        </ul>
        <!-- Tab panes -->
        <div class="tab-content mb-3">
            <div role="tabpanel" class="tab-pane fade in active" id="group"> 
                <div class="card">
                    <div class="card-body">
                        <x-btn-add-detail id="btn-add-detail" label="Add New Role" />
                        <br><br>       
            
                        <div id="table-role" class="table-responsive">
                            @include('user_management.user_role_list')            
                        </div>
                    </div>
                </div>
            </div>
            <div role="tabpanel" class="tab-pane fade" id="branch">
                <div class="card">
                    <div class="card-body">
                        <x-btn-add-detail id="btn-add-branch" label="Add New Branch" />
                        <br><br>  
                        <div id="table-branch" class="table-responsive">
                            @include('user_management.user_branch_list')            
                        </div>
                    </div>
                </div>
            </div>
            <div role="tabpanel" class="tab-pane fade" id="project">
                <div class="card">
                    <div class="card-body">
                        <x-btn-add-detail id="btn-add-project" label="Add New Project" />
                        <br><br>  
                        <div id="table-project" class="table-responsive">
                            @include('user_management.user_project_list')            
                        </div>
                    </div>
                </div>
            </div>
        </div> 
    @endif      
    
    <div class="row"> 
        <div class="col-12 mb-3">           
            @include('form_helper.btn_save_header')
        </div>
    </div>

@endsection 

@section('script')

    <script>  

        function deleteGroup(idx,item_description)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('sm-user-group/delete') }}";
            
            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();       

            var data = {
                "_token": $('#_token').val(),
                "IDX_M_User": $("#IDX_M_User").val(),
                "IDX_M_UserGroup": idx,
                "GroupName": item_description
            }
            
            callAjaxModalView(url,data);
        }

        function activateGroup(idx)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('sm-user-group/activate') }}";

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_M_User": $("#IDX_M_User").val(),
                "IDX_M_UserGroup": idx            
            }
            
            callAjaxModalView(url,data);
        }

        function deleteBranch(idx,item_description)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('sm-user-branch/delete') }}";
            
            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();       

            var data = {
                "_token": $('#_token').val(),
                "IDX_M_User": $("#IDX_M_User").val(),
                "IDX_M_UserBranch": idx,
                "BranchName": item_description
            }
            
            callAjaxModalView(url,data);
        }

        function activateBranch(idx)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('sm-user-branch/activate') }}";

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_M_User": $("#IDX_M_User").val(),
                "IDX_M_UserBranch": idx            
            }
            
            callAjaxModalView(url,data);
        }

        function deleteProject(idx,item_description)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('sm-user-project/delete') }}";
            
            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();       

            var data = {
                "_token": $('#_token').val(),
                "IDX_M_User": $("#IDX_M_User").val(),
                "IDX_M_UserProject": idx,
                "ProjectName": item_description
            }
            
            callAjaxModalView(url,data);
        }

        function activateProject(idx)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('sm-user-project/activate') }}";

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_M_User": $("#IDX_M_User").val(),
                "IDX_M_UserProject": idx            
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
                    IDX_M_User: $("#IDX_M_User").val(),
                    UserID: $("#LoginID").val(),
                    UserName: $("#Name").val(),
                }                

                callAjaxModalView('{{ url('sm-user-group/create') }}',data);            
            });

            $('#btn-add-branch').click(function()
            {   
                var data = {
                    _token: $("#_token").val(),
                    IDX_M_User: $("#IDX_M_User").val(),
                    UserID: $("#LoginID").val(),
                    UserName: $("#Name").val(),
                }                

                callAjaxModalView('{{ url('sm-user-branch/create') }}',data);            
            });

            $('#btn-add-project').click(function()
            {   
                var data = {
                    _token: $("#_token").val(),
                    IDX_M_User: $("#IDX_M_User").val(),
                    UserID: $("#LoginID").val(),
                    UserName: $("#Name").val(),
                }                

                callAjaxModalView('{{ url('sm-user-project/create') }}',data);            
            });

            $('#btn-add-department').click(function()
            {   
                var data = {
                    _token: $("#_token").val(),
                    IDX_M_User: $("#IDX_M_User").val(),
                    UserID: $("#LoginID").val(),
                    UserName: $("#Name").val(),
                }                

                callAjaxModalView('{{ url('sm-user-department/create') }}',data);            
            });

            $('#btn-reset').click(function()
            {   
                var data = {
                    _token: $("#_token").val(),
                    IDX_M_User: $("#IDX_M_User").val(),
                    UserID: $("#LoginID").val(),
                }                

                callAjaxModalView('{{ url('sm-user/reset') }}',data);            
            });

        });

    </script>

@endsection