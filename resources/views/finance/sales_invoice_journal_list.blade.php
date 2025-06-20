<table class="table table-bordered">
    <thead>
        <tr>
            <th scope="col">#</th>
            <th scope="col">Account</th>          
            <th scope="col">Remark</th>
            <th scope="col">Debit</th>
            <th scope="col">Credit</th>
        </tr>
    </thead>
    <tbody>
    @if($journal_detail)

        @php 
            $seq = 0;
            $currVoucher = "";
            $oldVoucher = "";
            $totalDebit = 0;
            $totalCredit = 0;            
        @endphp

        @foreach($journal_detail as $row)

            @php 
                $seq += 1;
                $currVoucher = $journal_detail[$seq - 1]->VoucherNo;
            @endphp

            @if($currVoucher <> $oldVoucher)

            <tr>
                <th colspan="5">
                    <span><b>{{ $row->VoucherNo . ' - ' . $row->JournalDate}}</b></span>
                </th>
            </tr> 
            @endif

            @php

                $oldVoucher = $currVoucher;
                $totalDebit += $journal_detail[$seq - 1]->BDebetAmount;
                $totalCredit += $journal_detail[$seq - 1]->BCreditAmount;

            @endphp
        
            <tr>
                
                <td>{{ $seq }}</td>
                <td>                    
                    <span>{{ $row->COAID }}</span>
                    <br>
                    <span>{{ $row->COADesc }}</span>                                      
                </td>
                
                <td>                    
                    <span>{{ $row->RemarkDetail }}</span>
                </td>

                <td>                    
                    <span>{{ number_format($row->BDebetAmount, 2, '.', ',') }}</span>
                </td>

                <td>                    
                    <span>{{ number_format($row->BCreditAmount, 2, '.', ',') }}</span>
                </td>
            </tr>
        @endforeach
       
        @php
            echo "<tr>\n";
                echo "<td colspan=3 class=text-right><b>TOTAL</b></td>\n";
                echo "<td><b>" . number_format($totalDebit,2,'.',',') . "</b></td>\n";
                echo "<td><b>" . number_format($totalCredit,2,'.',',') . "</b></td>\n";
            echo "</tr>\n";
        @endphp

    @endif
    </tbody>
</table>