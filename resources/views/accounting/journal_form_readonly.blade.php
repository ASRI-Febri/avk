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

    @php
        $user_date = function ($name, $id, $date) {
            if (!$date) {
                return '-';
            }
            $user = trim($name ?: $id);
            return date('d M Y H:i', strtotime($date)) . ($user ? ' oleh ' . $user . ($name && $id ? ' (' . trim($id) . ')' : '') : '');
        };
    @endphp

    <div class="row form-group">
        <div class="col-xl-6 col-md-6 col-sm-12">
            <table class="table table-borderless mb-0">
                <tbody>
                    <tr>
                        <th scope="row" width="35%">Journal Type :</th>
                        <td>{{ $fields->JournalTypeDesc }}</td>
                    </tr>
                    <tr>
                        <th scope="row">Voucher No :</th>
                        <td>{{ $fields->VoucherNo }}</td>
                    </tr>
                    <tr>
                        <th scope="row">No Referensi :</th>
                        <td>{{ $fields->ReferenceNo ?: '-' }}</td>
                    </tr>
                    <tr>
                        <th scope="row">Business Partner :</th>
                        <td>{{ $fields->PartnerDesc ?: '-' }}</td>
                    </tr>
                </tbody>
            </table>
        </div>
        <div class="col-xl-6 col-md-6 col-sm-12">
            <table class="table table-borderless mb-0">
                <tbody>
                    <tr>
                        <th scope="row" width="35%">Journal Date :</th>
                        <td>{{ $fields->JournalDate }}</td>
                    </tr>
                    <tr>
                        <th scope="row">Company / Branch :</th>
                        <td>{{ $fields->CompanyName }} / {{ $fields->BranchName }}</td>
                    </tr>
                    <tr>
                        <th scope="row">Keterangan :</th>
                        <td style="white-space: pre-line;">{{ $fields->RemarkHeader ?: '-' }}</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

    @if($fields->PostingStatus == 'P')
    <div class="card border mb-3">
        <div class="card-body py-2">
            <h6 class="text-secondary mb-2"><i class="fa fa-check-double me-1"></i> Informasi Posting</h6>
            <div class="row">
                <div class="col-xl-6 col-md-6 col-sm-12">
                    <table class="table table-sm table-borderless mb-0">
                        <tbody>
                            <tr>
                                <th scope="row" width="35%">Posting Date :</th>
                                <td>{{ $fields->PostingDate ? date('d M Y', strtotime($fields->PostingDate)) : '-' }}</td>
                            </tr>
                            <tr>
                                <th scope="row">Posted By :</th>
                                <td>{{ trim($fields->PostedByName ?: $fields->PostedBy) ?: '-' }}
                                    @if($fields->PostedByName && $fields->PostedBy)
                                        <small class="text-muted">({{ trim($fields->PostedBy) }})</small>
                                    @endif
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div class="col-xl-6 col-md-6 col-sm-12">
                    <table class="table table-sm table-borderless mb-0">
                        <tbody>
                            <tr>
                                <th scope="row" width="35%">Keterangan Posting :</th>
                                <td style="white-space: pre-line;">{{ $fields->PostingNotes ?: '-' }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    @endif

    <div id="table-journal-detail" class="table-responsive">
        @include('accounting.journal_detail_list')            
    </div> 

    <div class="card border mt-3">
        <div class="card-body">
            <h6 class="text-secondary mb-3"><i class="fas fa-paperclip me-1"></i> Lampiran</h6>
            @include('general.attachment_panel', ['attachment_type' => 'JE', 'attachment_id' => $fields->IDX_T_JournalHeader])
        </div>
    </div>

    <div class="row mt-2">
        <div class="col-12">
            <small class="text-muted d-block">Dibuat: {{ $user_date($fields->CreateByName, $fields->CreateByID, $fields->CreateByDate) }}</small>
            <small class="text-muted d-block">Terakhir diubah: {{ $user_date($fields->ModifiedByName, $fields->ModifiedByID, $fields->ModifiedByDate) }}</small>
        </div>
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
