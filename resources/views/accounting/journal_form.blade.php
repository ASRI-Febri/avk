@extends('layouts.master-form-transaction')

@section('form-remark')
   Journal 
@endsection

@section('action')

    @if($fields->PostingStatus == 'U')
    @include('form_helper.btn_save_header')
    @endif

    <x-btn-action>
        
        @if($fields->PostingStatus == 'U')
        <a id="btn-posting" class="dropdown-item" href="#">
            <div class="dropdown-icon">
                <i class="fa fa-check-double"></i> 
            </div>
            <span class="dropdown-content">Posting</span>            
        </a>
        @endif

        @if($fields->PostingStatus == 'P')
        <a id="btn-unposting" class="dropdown-item text-danger" href="#">
            <div class="dropdown-icon">
                <i class="fas fa-undo"></i> 
            </div>
            <span class="dropdown-content">Unposting</span> 
        </a>
        @endif

        <div class="dropdown-divider"></div>   

        <a href="{{ url('ac-journal/download-pdf').'/'.$fields->IDX_T_JournalHeader }}" id="btn-download2-pdf" 
            target="_blank" class="dropdown-item text-info">
            <div class="dropdown-icon">
                <i class="fa fa-file-pdf"></i> 
            </div>
            <span class="dropdown-content">Print</span>
        </a>      
        
        <a id="btn-duplicate-header" class="dropdown-item text-primary" href="#" title="Duplicate this data">
            <div class="dropdown-icon">
                <i class="fas fa-copy"></i> 
            </div>
            <span class="dropdown-content">Duplicate</span>
        </a>
        
    </x-btn-action>


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

@section('content-form')    

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_T_JournalHeader" name="IDX_T_JournalHeader" value="{{ $fields->IDX_T_JournalHeader }}"/>   
    <input type="hidden" id="IDX_M_Partner" name="IDX_M_Partner" value="{{ $fields->IDX_M_Partner }}"/>
    <input type="hidden" id="IDX_ReferenceNo" name="IDX_ReferenceNo" value="{{ $fields->IDX_ReferenceNo }}"/> 
    <input type="hidden" id="PostingStatus" name="PostingStatus" value="{{ $fields->PostingStatus }}"/> 
    <input type="hidden" id="JournalSource" name="JournalSource" value="{{ $fields->JournalSource }}"/>   
    
    @if($state <> 'create')
        <h6 class="text-secondary">{{ $fields->VoucherNo }}</h6>
    @endif

    <div class="row">
        <div class="col-xl-12 col-md-12 col-sm-12">

            <div class="card border">
                <div class="card-header">
                    
                    <div class="nav nav-lines card-header-lines mb-0" id="card-tab-1" role="tablist">
                        <a class="nav-item nav-link active" id="card-general-tab" data-bs-toggle="tab" href="#card-general" aria-selected="false" role="tab" tabindex="-1">
                            <i class="fas fa-align-justify"></i> General
                        </a>
                        @if($state <> 'create')
                        <a class="nav-item nav-link" id="card-detail-tab" data-bs-toggle="tab" href="#card-detail" aria-selected="false" role="tab" tabindex="-1">
                            <i class="fas fa-list"></i> Journal Detail</a>
                        @endif
                    </div>

                </div>
                <div class="card-body">
                    <div class="tab-content">
                        <div class="tab-pane fade active show" id="card-general" role="tabpanel" aria-labelledby="#card-general-tab">
                            
                            <div class="mb-2">
                            <x-select-horizontal label="Company" id="IDX_M_Company" :value="$fields->IDX_M_Company" class="required" :array="$dd_company"/>
                            </div>

                            <div class="mb-2">
                            <x-select-horizontal label="Profit Center" id="IDX_M_Branch" :value="$fields->IDX_M_Branch" class="required" :array="$dd_branch"/>
                            </div>

                            <div class="mb-2">
                            <x-select-horizontal label="Journal Type" id="IDX_M_JournalType" :value="$fields->IDX_M_JournalType" class="required" :array="$dd_journal_type"/>
                            </div>

                            <x-textbox-horizontal label="Voucher No" id="VoucherNo" :value="$fields->VoucherNo" placeholder="(Auto)" class="readonly mb-2" />
                            <x-textbox-horizontal label="Reference No" id="ReferenceNo" :value="$fields->ReferenceNo" placeholder="Reference No" class="required mb-2" />
                            <x-textbox-horizontal label="Journal Date" id="JournalDate" :value="$fields->JournalDate" placeholder="Journal Date" class="required datepicker2 mb-2" />                    
                            <x-textbox-horizontal label="Voucher Notes" id="RemarkHeader" :value="$fields->RemarkHeader" placeholder="Notes" class="required mb-2" />

                            
                            <x-lookup-horizontal label="Business Partner" id="PartnerDesc" :value="$fields->PartnerDesc" class="required" button="btn-find-partner"/>

                        </div>

                        @if($state <> 'create')
                        <div class="tab-pane fade" id="card-detail" role="tabpanel" aria-labelledby="#card-detail-tab">
                            @if($fields->PostingStatus == 'U')
                                <x-btn-add-detail id="btn-add-detail" label="Add New" />
                                <br><br>
                            @endif 

                            <div id="table-journal-detail" class="table-responsive">
                                @include('accounting.journal_detail_list')            
                            </div>  
                        </div>
                        @endif
                    </div>
                </div>
            </div>
        </div>
    </div>

    
   

    

@endsection

@section('script')

    <script>

        function deleteDetail2(idx,item_description)
        {
            //alert('Delete ' + idx);
            var url = "{{ url('ac-journal-detail/delete') }}";

            //alert(url);
            
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