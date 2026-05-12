<table class="table table-bordered">
    <thead>
        <tr>
            <th scope="col">#</th>
            <th scope="col">Voucher No</th>
            <th scope="col">Journal Date</th>
            <th scope="col">Remark Header</th>
            <th scope="col">COA ID</th>
            <th scope="col">COA Desc</th>
            <th scope="col" class="text-end">Debet</th>
            <th scope="col" class="text-end">Credit</th>
        </tr>
    </thead>
    <tbody>
    @if(!empty($records_journal) && count($records_journal) > 0)

        @php
            $grouped = [];
            foreach ($records_journal as $row) {
                $key = $row->JournalTypeDesc;
                if (!isset($grouped[$key])) {
                    $grouped[$key] = [];
                }
                $grouped[$key][] = $row;
            }

            $grand_debet = 0;
            $grand_credit = 0;
        @endphp

        @foreach($grouped as $journalTypeDesc => $rows)
            @php
                $group_debet = 0;
                $group_credit = 0;
                $seq = 0;
            @endphp

            <tr class="table-secondary">
                <td colspan="8"><strong>{{ $journalTypeDesc }}</strong></td>
            </tr>

            @foreach($rows as $row)
                @php
                    $seq += 1;
                    $group_debet += $row->BDebetAmount;
                    $group_credit += $row->BCreditAmount;
                @endphp
                <tr>
                    <td>{{ $seq }}</td>
                    <td>{{ $row->VoucherNo }}</td>
                    <td>{{ $row->JournalDate ? date('d M Y', strtotime($row->JournalDate)) : '' }}</td>
                    <td>{{ $row->RemarkHeader }}</td>
                    <td>{{ $row->COAID }}</td>
                    <td>{{ $row->COADesc }}</td>
                    <td class="text-end">{{ number_format($row->BDebetAmount, 2, '.', ',') }}</td>
                    <td class="text-end">{{ number_format($row->BCreditAmount, 2, '.', ',') }}</td>
                </tr>
            @endforeach

            <tr class="font-weight-bold">
                <td colspan="6" class="text-end"><strong>Subtotal {{ $journalTypeDesc }}</strong></td>
                <td class="text-end"><strong>{{ number_format($group_debet, 2, '.', ',') }}</strong></td>
                <td class="text-end"><strong>{{ number_format($group_credit, 2, '.', ',') }}</strong></td>
            </tr>

            @php
                $grand_debet += $group_debet;
                $grand_credit += $group_credit;
            @endphp
        @endforeach

        <tr class="font-weight-bold">
            <td colspan="6" class="text-end"><strong>Grand Total</strong></td>
            <td class="text-end"><strong>{{ number_format($grand_debet, 2, '.', ',') }}</strong></td>
            <td class="text-end"><strong>{{ number_format($grand_credit, 2, '.', ',') }}</strong></td>
        </tr>
    @else
        <tr>
            <td colspan="8" class="text-center text-muted">Tidak ada data journal</td>
        </tr>
    @endif
    </tbody>
</table>
