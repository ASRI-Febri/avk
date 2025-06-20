@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-modal id="btn-save-modal" label="Duplicate" :url="$url_save_modal"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_JournalHeader" name="IDX_T_JournalHeader" value="{{ $fields->IDX_T_JournalHeader }}"/>

    <div class="alert alert-primary" role="alert">
        Fungsi ini untuk membuat duplikat data journal voucher.
        <br>
        Status journal yang terbentuk adalah <b>unposting</b>, dan harus dicek dan diubah sesuai kebutuhan
    </div>

    <dl class="row mb-0 redial-line-height-2_5">
        <dt class="col-sm-5">Voucher No:</dt>
        <dd class="col-sm-7">{{ $fields->VoucherNo }}</dd>

        <dt class="col-sm-5">Journal Type:</dt>
        <dd class="col-sm-7">{{ $fields->JournalTypeDesc }}</dd>

        <dt class="col-sm-5">Journal Date:</dt>
        <dd class="col-sm-7">{{ date('d M Y',strtotime($fields->JournalDate)) }}</dd>

        <dt class="col-sm-5">Reference No:</dt>
        <dd class="col-sm-7">{{ $fields->ReferenceNo }}</dd>

        <dt class="col-sm-5">Journal Remark:</dt>
        <dd class="col-sm-7">{{ $fields->RemarkHeader }}</dd>

        <dt class="col-sm-5">Status</dt>
        @if($fields->PostingStatus == 'U')
        <dd class="col-sm-7"><span class="badge badge-danger text-white">Unposting</span></dd>
        @else
        <dd class="col-sm-7"><span class="badge badge-primary text-white">Posting</span></dd>
        @endif 
    </dl>

    <hr>

    <table class="table table-bordered">
        <thead>
            <tr>
                <th scope="col">#</th>            
                <th scope="col">COA</th>
                <th scope="col">Remark</th>
                <th scope="col">Debet</th>
                <th scope="col">Credit</th>                
            </tr>
        </thead>
        <tbody>
        @if($records_detail)
    
            @php 
                $seq = 0;            
            @endphp
    
            @foreach($records_detail as $row)
    
                @php 
                    $seq += 1;
                    $url_delete = url('ac-journal-detail/delete/'.$row->IDX_T_JournalDetail);       
                @endphp
    
                <tr>
                    <td>{{ $seq }}</td>               
                    
                    <td>                    
                        <span>{{ $row->COAID . ' - ' . $row->COADesc }}</span>
                    </td>               
    
                    <td>                    
                        <span>{{ $row->RemarkDetail }}</span>
                    </td>
    
                    <td class="text-right">                    
                        <span>{{ number_format($row->BDebetAmount,2,'.',',') }}</span>
                    </td>
                    
                    <td class="text-right">                    
                        <span>{{ number_format($row->BCreditAmount,2,'.',',') }}</span>
                    </td>   
                </tr>
            @endforeach
           
    
        @endif
        </tbody>
    </table>
    

@endsection 