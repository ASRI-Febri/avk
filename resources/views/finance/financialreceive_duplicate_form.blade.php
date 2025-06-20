@extends('layouts.modal_form')

@section('button-save')
    <x-btn-save-modal id="btn-save-modal" label="Duplicate" :url="$url_save_modal"/>    
@endsection

@section('modal-content')

    <input type="hidden" id="IDX_T_FinancialReceiveHeader" name="IDX_T_FinancialReceiveHeader" value="{{ $fields->IDX_T_FinancialReceiveHeader }}"/>

    <div class="alert alert-primary" role="alert">
        Fungsi ini untuk membuat duplikat transaksi Financial Receive.
        <br>
        Status transaksi yang terbentuk adalah <b>DRAFT</b>, dan harus dicek dan diubah sesuai kebutuhan
    </div>

    <dl class="row mb-0 redial-line-height-2_5">
        <dt class="col-sm-5">Voucher No:</dt>
        <dd class="col-sm-7">{{ $fields->ReceiveID }}</dd>

        <dt class="col-sm-5">Receive Date:</dt>
        <dd class="col-sm-7">{{ date('d M Y',strtotime($fields->ReceiveDate)) }}</dd>

        <dt class="col-sm-5">Remark:</dt>
        <dd class="col-sm-7">{{ $fields->RemarkHeader }}</dd>

        <dt class="col-sm-5">Status</dt>
        @if($fields->ReceiveStatus == 'A')
        <dd class="col-sm-7"><span class="badge badge-danger text-white">APPROVED</span></dd>
        @else
        <dd class="col-sm-7"><span class="badge badge-primary text-white">UN-APPROVED</span></dd>
        @endif 
    </dl>

    <hr>

    <table class="table table-bordered">
        <thead>
            <tr>
                <th scope="col">#</th>     
                <th scope="col">Project</th>       
                <th scope="col">COA ID</th>
                <th scope="col">COA Desc</th>
                <th scope="col">Amount</th>
                <th scope="col">Remark Detail</th>                
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
                @endphp

                <tr>
                    <td>{{ $seq }}</td>      
                    
                    <td>                    
                        <span>{{ $row->ProjectName }}</span>
                    </td>       
                    
                    <td>                    
                        <span>{{ $row->COAID }}</span>
                    </td>    
                    
                    <td>                    
                        <span>{{ $row->COADesc }}</span>
                    </td>  
    
                    <td class="text-right">                    
                        <span>{{ number_format($row->ReceiveAmount,2,'.',',') }}</span>
                    </td>  

                    <td>                    
                        <span>{{ $row->RemarkDetail }}</span>
                    </td>
                </tr>
            @endforeach
           
    
        @endif
        </tbody>
    </table>
    

@endsection 