<table class="table table-bordered">
        <thead>
            <tr>
                <th scope="col">#</th>
                <th scope="col">Journal Date</th>          
                <th scope="col">Account</th>
                <th scope="col">Account Desc</th>
                <th scope="col">Remark</th>
                <th scope="col" class="text-right">Debet</th>
                <th scope="col" class="text-right">Credit</th>
            </tr>
        </thead>
        <tbody>

        @if($payment_detail)
        
            @php 
                $seq = 0;
                $currVoucher = "";
                $oldVoucher = "";
                $totalDebit = 0;
                $totalCredit = 0;                
            @endphp

            @foreach($payment_detail as $row)

                @php 
                    $seq += 1;
                    $currVoucher = $payment_detail[$seq - 1]->VoucherNo;
                @endphp

                @if($currVoucher <> $oldVoucher)

                <tr>
                    <th colspan="7">
                        <span><b>{{ $row->VoucherNo . ' - ' . $row->JournalTypeDesc}}</b></span>
                    </th>
                </tr> 
                @endif

                @php

                    $oldVoucher = $currVoucher;
                    $totalDebit += $payment_detail[$seq - 1]->BDebetAmount;
                    $totalCredit += $payment_detail[$seq - 1]->BCreditAmount;

                @endphp

                <tr>
                    <td>{{ $seq }}</td>
                    <td>                    
                        <span>{{ $row->JournalDate }}</span>                                       
                    </td>
                    
                    <td>                    
                        <span>{{ $row->COAID }}</span>
                    </td>
    
                    <td>                    
                        <span>{{ $row->COADesc }}</span>
                    </td>
    
                    <td>                    
                        <span>{{ $row->RemarkDetail }}</span>
                    </td>
    
                    <td class="text-right">                    
                        <span>{{ number_format($row->BDebetAmount, 2, '.', ',') }}</span>
                    </td>
    
                    <td class="text-right">                    
                        <span>{{ number_format($row->BCreditAmount, 2, '.', ',') }}</span>
                    </td>
    
                </tr>
            @endforeach

            <tr>
                <td><td><td></td><td></td>
                <td class="text-right">                    
                        <span style="font-weight:bold">TOTAL</span>
                    </td>
                <td class="text-right">                    
                    <span style="font-weight:bold">{{ number_format($totalDebit,2,'.',',') }}</span>
                </td>
                <td class="text-right">                    
                    <span style="font-weight:bold">{{ number_format($totalCredit,2,'.',',') }}</span>
                </td>
            </tr>
    
        @endif
        </tbody>
    </table>