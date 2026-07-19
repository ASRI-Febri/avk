<table class="table table-bordered">
    <thead>
        <tr>
            <th scope="col">#</th>
            <th scope="col">Tanggal</th>
            <th scope="col">Document Type</th>
            <th scope="col">Account (Beban)</th>
            <th scope="col">No Referensi</th>
            <th scope="col">Dibayarkan ke</th>
            <th scope="col">Keterangan</th>
            <th scope="col" class="text-end">Jumlah</th>

            @if(!isset($show_action) || $show_action == TRUE)
            <th scope="col" class="text-center">Action</th>
            @endif
        </tr>
    </thead>
    <tbody>
    @if($records_detail)

        @php
            $seq = 0;
            $total = 0;
        @endphp

        @foreach($records_detail as $row)

            @php
                $seq += 1;
                $total += $row->PettyCashAmount;
            @endphp

            <tr>
                <td>{{ $seq }}</td>
                <td>{{ $row->TransactionDate }}</td>
                <td>{{ $row->DocumentTypeDesc }}</td>
                <td>{{ trim($row->COAID . ' - ' . $row->COADesc) }}</td>
                <td>{{ $row->ReferenceNo }}</td>
                <td>{{ $row->PartnerName }}</td>
                <td>{{ $row->DetailDesc }}</td>
                <td class="text-end">{{ number_format($row->PettyCashAmount, 2, '.', ',') }}</td>

                @if(!isset($show_action) || $show_action == TRUE)
                <td class="text-center">
                    <div class="input-group-prepend text-center">
                        @if($row->PettyCashStatus == 'O')
                            <x-btn-edit-detail :id="$row->IDX_T_PettyCashDetail" />
                            <x-btn-delete-detail :id="$row->IDX_T_PettyCashDetail" :label="$row->DetailDesc" />
                        @endif
                    </div>
                </td>
                @endif
            </tr>

        @endforeach

        <tr>
            <td colspan="7" class="text-end"><strong>Total Pengeluaran</strong></td>
            <td class="text-end"><strong>{{ number_format($total, 2, '.', ',') }}</strong></td>
            @if(!isset($show_action) || $show_action == TRUE)
            <td></td>
            @endif
        </tr>

    @endif
    </tbody>
</table>
