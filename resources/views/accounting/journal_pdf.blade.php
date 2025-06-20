@extends('layouts.pdf')

@section('title')
    Journal Voucher
@endsection

@section('content')    

    <div style="float:left;width:60%">
            
        <img src="{{ $img_logo }}" width="{{ $img_logo_w }}" height="{{ $img_logo_h }}" />
        <br>
        <table class="noborder">
            <tr class="noborder nopadding">                
                <td class="td-85 bold noborder nopadding param-key">
                    <span style="display:block;">PT {{ strtoupper($fields->CompanyName) }}</span>
                </td>
            </tr>
            <tr class="noborder nopadding">
                <td class="td-85 bold noborder nopadding param-value">
                    <span style="display:block;">BRANCH - {{ strtoupper($fields->BranchName) }}</span>
                </td>
            </tr>            
        </table>  
    </div>

    <div style="float:left;width:40%">
        <h1>Journal Voucher</h1>
        <table class="noborder nopadding">
            <tr class="noborder nopadding">
                <td class="td-30 bold noborder nopadding param-key">Voucher No</td>
                <td class="td-50 bold noborder nopadding param-value">{{ $fields->VoucherNo }}</td>
            </tr>
            <tr class="noborder">
                <td class="td-30 bold noborder nopadding param-key">Journal Date</td>
                <td class="td-50 bold noborder nopadding param-value">{{ date('d M Y',strtotime($fields->JournalDate)) }}</td>
            </tr>
            <tr class="noborder">
                <td class="td-30 bold noborder nopadding param-key">Posting Date</td>
                <td class="td-50 bold noborder nopadding param-value">{{ date('d M Y',strtotime($fields->PostingDate)) }}</td>
            </tr>
        </table>
        
    </div>

    <br>

    <table>
        <thead>
            <tr>                
                <td class="bold">Journal Type</td>
                <td class="bold">Business Partner</td>
                <td class="bold">Journal Description</td>
            </tr>
        </thead>
        <tbody>
            <tr>                
                <td>{{ $fields->JournalTypeDesc }}</td>
                <td>{{ $fields->PartnerDesc }}</td>
                <td>{{ $fields->RemarkHeader }}</td>
            </tr>
        </tbody>        
    </table>

    <br>

    <table class="table noborder">
        <thead>
            <tr style="border-bottom: 0.5px;">        
                <th class="noborder" style="border-bottom: 1px solid;">No</th>    
                <th class="noborder" style="border-bottom: 1px solid;" scope="col">Account Description</th>                            
                <th class="noborder text-right" style="border-bottom: 1px solid;" scope="col" class="text-right">Debet</th>            
                <th class="noborder text-right" style="border-bottom: 1px solid;" scope="col" class="text-right">Credit</th>           
            </tr>
        </thead>
        <tbody>
        @if($records_detail)
    
            @php 
                $seq = 0; 
    
                $subtotal_debet = 0;
                $subtotal_credit = 0;
                  
            @endphp
    
            @foreach($records_detail as $row)
    
                @php 
                    $seq += 1;
    
                    $subtotal_debet += ($row->BDebetAmount);
                    $subtotal_credit += ($row->BCreditAmount);
                @endphp
    
                <tr class="noborder">
                    <td class="text-center noborder">{{ $seq }}</td>
                    <td class="noborder">
                        <span style="display:block;">{{ $row->COAID . ' - ' . $row->COADesc }}</span>
                        <span style="display:block;">{{ $row->RemarkDetail }}</span>
                    </td>                   
                    
                    <td class="text-right noborder">Rp {{ number_format($row->BDebetAmount, 2, '.', ',') }}</td>
                    
                    <td class="text-right noborder">Rp {{ number_format($row->BCreditAmount, 2, '.', ',') }}</td>
                </tr>
    
            @endforeach
    
            <tr class="noborder">
                <td class="noborder" colspan="5"><hr style="border: 0.5px;"></td>
            </tr>
            
            <tr class="font-weight-bold noborder">
                <td colspan="2" class="text-right text-secondary noborder bold">TOTAL</td>
                <td class="text-right text-secondary noborder bold">Rp {{ number_format($subtotal_debet, 2, '.', ',') }}</td>     
                <td class="text-right text-secondary noborder bold">Rp {{ number_format($subtotal_credit, 2, '.', ',') }}</td>        
            </tr>
    
        @endif
        </tbody>
    </table>

    <br>

    <table>
        <thead>
            <tr>                
                <td class="bold text-center">Dibuat oleh,</td>
                <td class="bold text-center">Diperiksa oleh,</td>
                <td class="bold text-center">Disetujui oleh,</td>
            </tr>
        </thead>
        <tbody>
            <tr>                
                <td height="70px;"></td>
                <td height="70px;"></td>
                <td height="70px;"></td>
            </tr>
            <tr>                
                <td height="10px;"></td>
                <td height="10px;"></td>
                <td height="10px;"></td>
            </tr>
        </tbody>        
    </table>

@endsection