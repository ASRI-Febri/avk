@extends('layouts.master-form-transaction')

@section('active_link')
	$('#nav-transaction').addClass('mm-active');
    $('#nav-ul-transaction').addClass('mm-show');
    $('#nav-li-input-journal').addClass('mm-active');
@endsection

@section('form-remark')
   Journal Form (View Only)
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

@section('content-form')    

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_T_JournalHeader" name="IDX_T_JournalHeader" value="{{ $fields->IDX_T_JournalHeader }}"/>   
    <input type="hidden" id="IDX_M_Partner" name="IDX_M_Partner" value="{{ $fields->IDX_M_Partner }}"/>
    <input type="hidden" id="IDX_ReferenceNo" name="IDX_ReferenceNo" value="{{ $fields->IDX_ReferenceNo }}"/> 
    <input type="hidden" id="PostingStatus" name="PostingStatus" value="{{ $fields->PostingStatus }}"/> 
    <input type="hidden" id="JournalSource" name="JournalSource" value="{{ $fields->JournalSource }}"/>   
    
    @if($state <> 'create')
        <div class="row form-group">
            <div class="col-6">
                <h6 class="text-secondary">No Voucher: {{ $fields->VoucherNo }}</h6>
            </div>
            <div class="col-6">
                <span class="badge badge-primary">{{ $fields->StatusDesc }}</span>
            </div>
        </div>
    @endif

    <div class="row form-group">
        <div class="col-xl-6 col-md-6 col-sm-12">
            <table class="table table-nowrap table-borderless mb-0">
                <tbody>
                    <tr>
                        <th scope="row">Journal Type :</th>
                        <td>{{ $fields->JournalTypeDesc }}</td>
                    </tr>
                    <tr>
                        <th scope="row">Voucher No :</th>
                        <td>{{ $fields->VoucherNo }}</td>
                    </tr>`
                </tbody>
            </table>
        </div>
        <div class="col-xl-6 col-md-6 col-sm-12">
            <table class="table table-nowrap table-borderless mb-0">
                <tbody>
                    <tr>
                        <th scope="row">Journal Date :</th>
                        <td>{{ $fields->JournalDate }}</td>
                    </tr>
                </tbody>
            </table>
        </div>
        
    </div>

    <div id="table-journal-detail" class="table-responsive">
        @include('accounting.journal_detail_list')            
    </div> 

@endsection

@section('script')

    <script>

        $(document).ready(function(){

            $('#btn-duplicate-header').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_JournalHeader: $("#IDX_T_JournalHeader").val(),
                }                

                callAjaxModalView('{{ url('ac-journal/duplicate') }}',data);            
            });

            $('#btn-unposting').click(function()
            {           
                var data = {
                    _token: $("#_token").val(),
                    IDX_T_JournalHeader: $("#IDX_T_JournalHeader").val(),
                }                

                callAjaxModalView('{{ url('ac-journal/unposting') }}',data);

            });

        });

    </script>

@endsection 
