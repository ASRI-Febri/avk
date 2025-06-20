@extends('layouts.form')

@section('left_header')    
    
@endsection

@section('right_header')    
    {{-- @include('form_helper.btn_save_header') --}}
    
    @if($state !== 'create')
        
    <x-btn-create-new label="Create New" :url="$url_create" />

    <x-btn-action>
        
        @if($fields->PostingStatus == 'U')
        <a id="btn-posting" class="dropdown-item" href="#"><i class="fa fa-check-double"></i> Posting</a>
        @endif

        @if($fields->PostingStatus == 'P')
        <a id="btn-unposting" class="dropdown-item text-danger" href="#"><i class="fas fa-undo"></i> Unposting</a>
        @endif

        <div class="dropdown-divider"></div>            
        <a href="{{ url('ac-journal/download-pdf').'/'.$fields->IDX_T_JournalHeader }}" id="btn-download2-pdf" 
            target="_blank" class="dropdown-item text-info">
            <i class="fa fa-file-pdf"></i> Print PDF
        </a>      
        
        <a id="btn-duplicate-header" class="dropdown-item text-primary" href="#" title="Duplicate this data"><i class="fas fa-copy"></i> Duplicate</a>
    </x-btn-action> 
    @endif
@endsection

@section('additional_log')
    <div class="card mb-3">
        <div class="card-body">
            <h6>Journal Status</h6>
            <hr>
            @if($fields->PostingStatus == 'U')
            <span class="badge badge-pill outline-badge-danger p-2 mb-1">{{ $fields->StatusDesc }}</span>
            @else 
            <span class="badge badge-pill outline-badge-info p-2 mb-1">{{ $fields->StatusDesc }}</span>
            @endif
        </div>
    </div>
@endsection

@section('content_form')    

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_T_JournalHeader" name="IDX_T_JournalHeader" value="{{ $fields->IDX_T_JournalHeader }}"/>   
    <input type="hidden" id="IDX_M_Partner" name="IDX_M_Partner" value="{{ $fields->IDX_M_Partner }}"/>
    <input type="hidden" id="IDX_ReferenceNo" name="IDX_ReferenceNo" value="{{ $fields->IDX_ReferenceNo }}"/> 
    <input type="hidden" id="PostingStatus" name="PostingStatus" value="{{ $fields->PostingStatus }}"/> 
    <input type="hidden" id="JournalSource" name="JournalSource" value="{{ $fields->JournalSource }}"/>    
    
    <ul class="nav nav-tabs pb-3" role="tablist">    
        <li class="nav-item">
        <a class="nav-link text-muted active" href="#general" role="tab" data-toggle="tab"><i class="fas fa-align-justify"></i> <strong>General</strong></a>
        </li>

        @if($fields->IDX_T_JournalHeader <> 0)
            <li class="nav-item">
                <a class="nav-link text-muted" href="#journal-item" role="tab" data-toggle="tab"><i class="fas fa-align-justify"></i> <strong>Journal Item</strong></a>
            </li>           
        @endif
    </ul>

    <!-- Tab panes -->
    <div class="tab-content mb-3">
        <div role="tabpanel" class="tab-pane fade in active" id="general">            
            <div class="card">
                <div class="card-body">
                    <legend><h6 class="text-muted font-weight-bold">Journal Info</h6></legend>
                    <x-select-horizontal label="Company" id="IDX_M_Company" :value="$fields->IDX_M_Company" class="required" :array="$dd_company"/>
                    <x-select-horizontal label="Branch" id="IDX_M_Branch" :value="$fields->IDX_M_Branch" class="required" :array="$dd_branch"/>
                    <x-select-horizontal label="Journal Type" id="IDX_M_JournalType" :value="$fields->IDX_M_JournalType" class="required" :array="$dd_journal_type"/>
                    <x-textbox-horizontal label="Voucher No" id="VoucherNo" :value="$fields->VoucherNo" placeholder="Voucher No" class="readonly" />
                    <x-textbox-horizontal label="Reference No" id="ReferenceNo" :value="$fields->ReferenceNo" placeholder="Reference No" class="required" />
                    <x-textbox-horizontal label="Journal Date" id="JournalDate" :value="$fields->JournalDate" placeholder="Invoice Date" class="required datepicker2" />                    
                    <x-textbox-horizontal label="Voucher Notes" id="RemarkHeader" :value="$fields->RemarkHeader" placeholder="Notes" class="required" />

                    <legend><h6 class="text-muted font-weight-bold">Business Partner</h6></legend>
                    <x-lookup-horizontal label="Business Partner" id="PartnerDesc" :value="$fields->PartnerDesc" class="required" button="btn-find-partner"/>
                </div>
                
                <hr>
                
                <div class="form-row m-2"> 
                    <div class="col-12 mb-3">           
                        @include('form_helper.btn_save_header')
                    </div>
                </div>
            </div>

        </div>

        @if($fields->IDX_T_JournalHeader <> 0)
            <div role="tabpanel" class="tab-pane fade in" id="journal-item">            
                <div class="card">
                    <div class="card-body">
    
                        @if($fields->PostingStatus == 'U')
                        <x-btn-add-detail id="btn-add-detail" label="Add New" />
                        <br><br>
                        @endif 

                        <div id="table-journal-detail" class="table-responsive">
                            @include('accounting.journal_detail_list')            
                        </div>  
    
                    </div>            
                </div>
            </div> 
        @endif

    </div>    

@endsection

@section('script')

    <script>

        function deleteDetail(idx,item_description)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('ac-journal-detail/delete') }}";
            
            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();       

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_JournalHeader": $("#IDX_T_JournalHeader").val(),
                "IDX_T_JournalDetail": idx,
                "COADesc": item_description
            }
            
            callAjaxModalView(url,data);
        }

        function editDetail(idx)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('ac-journal-detail/update') }}"+'/'+idx;

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_JournalHeader": $("#IDX_T_JournalHeader").val(),
                "IDX_T_JournalDetail": idx            
            }
            
            callAjaxModalView(url,data);
        } 
        
        function duplicateDetail(idx)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('ac-journal-detail/duplicate') }}"+'/'+idx;

            // GET CURRENT SCROLL TOP POSITION
            getScrollPosition();

            var data = {
                "_token": $('#_token').val(),
                "IDX_T_JournalHeader": $("#IDX_T_JournalHeader").val(),
                "IDX_T_JournalDetail": idx            
            }
            
            callAjaxModalView(url,data);
        } 

        $(document).ready(function(){

            $('#btn-find-partner').click(function(){
                
                var data = {
                    _token: $("#_token").val(),  
                    target_index: 'IDX_M_Partner',
                    target_name: 'PartnerDesc'                  
                }              

                callAjaxModalView('{{ url('/fm-select-partner-pi') }}',data);                
            });            
           
            $('#btn-add-detail').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_JournalHeader: $("#IDX_T_JournalHeader").val(),
                }                

                callAjaxModalView('{{ url('ac-journal-detail/create') }}',data);            
            });   

            $('#btn-posting').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_JournalHeader: $("#IDX_T_JournalHeader").val(),
                }                

                callAjaxModalView('{{ url('ac-journal/posting') }}',data);            
            });

            $('#btn-unposting').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_JournalHeader: $("#IDX_T_JournalHeader").val(),
                }                

                callAjaxModalView('{{ url('ac-journal/unposting') }}',data);            
            });

            $('#btn-duplicate-header').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_JournalHeader: $("#IDX_T_JournalHeader").val(),
                }                

                callAjaxModalView('{{ url('ac-journal/duplicate') }}',data);            
            });
        });

    </script>

@endsection