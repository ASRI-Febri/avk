<table class="table table-bordered">
    <thead>
        <tr>
            <th scope="col">#</th>
            <th scope="col">Account (COA)</th>
            <th scope="col">Keterangan</th>
            <th scope="col" class="text-end">Debet</th>
            <th scope="col" class="text-end">Credit</th>
        </tr>
    </thead>
    <tbody>
    @if(isset($journal_detail) && $journal_detail)

        @php
            $total_debet = 0;
            $total_credit = 0;
        @endphp

        @foreach($journal_detail as $row)

            @php
                $total_debet  += $row->BDebetAmount;
                $total_credit += $row->BCreditAmount;
            @endphp

            <tr>
                <td>{{ $row->JournalSeqNo }}</td>
                <td>{{ trim($row->COAID . ' - ' . $row->COADesc) }}</td>
                <td>{{ $row->JournalDesc }}</td>
                <td class="text-end">{{ number_format($row->BDebetAmount, 2, '.', ',') }}</td>
                <td class="text-end">{{ number_format($row->BCreditAmount, 2, '.', ',') }}</td>
            </tr>

        @endforeach

        <tr>
            <td colspan="3" class="text-end"><strong>Total</strong></td>
            <td class="text-end"><strong>{{ number_format($total_debet, 2, '.', ',') }}</strong></td>
            <td class="text-end"><strong>{{ number_format($total_credit, 2, '.', ',') }}</strong></td>
        </tr>

    @else
        <tr>
            <td colspan="5" class="text-center text-muted">Belum ada jurnal. Jurnal akan terbentuk otomatis saat Petty Cash di-Close.</td>
        </tr>
    @endif
    </tbody>
</table>
