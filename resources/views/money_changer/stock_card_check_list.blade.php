<div class="alert alert-label-warning">
    <span class="text-muted">
        Baris kartu stok (<code>MC_T_StockCardValas</code>) untuk transaksi ini. Gunakan tombol
        <i class="fas fa-pen"></i> untuk mengoreksi kuantitas atau <i class="fa fa-trash"></i> untuk
        menghapus baris yang dobel (duplikat). Baris bertanda <span class="badge bg-danger">Duplikat</span>
        muncul lebih dari satu kali untuk valas yang sama pada transaksi ini.
    </span>
</div>

<table class="table table-bordered">
    <thead>
        <tr>
            <th scope="col">#</th>
            <th scope="col">Tanggal</th>
            <th scope="col">No Transaksi</th>
            <th scope="col">Valas</th>
            <th scope="col" class="text-end">Qty Masuk</th>
            <th scope="col" class="text-end">Qty Keluar</th>
            <th scope="col" class="text-end">Nilai (Valas)</th>
            <th scope="col" class="text-center">Status</th>
            <th scope="col" class="text-center">Action</th>
        </tr>
    </thead>
    <tbody>
    @if(!empty($records_stockcard))

        @php $seq = 0; @endphp

        @foreach($records_stockcard as $row)
            @php
                $seq += 1;
                $is_dup = ($row->DupCount ?? 0) > 1;
            @endphp

            <tr @if($is_dup) class="table-warning" @endif>
                <td>{{ $seq }}</td>
                <td>{{ $row->TransactionDate ? date('d M Y', strtotime($row->TransactionDate)) : '' }}</td>
                <td>{{ $row->TransactionNo }}</td>
                <td>
                    <span>{{ $row->ValasSKU }}</span><br>
                    <span class="text-muted">{{ $row->ValasName }}</span>
                </td>
                <td class="text-end">{{ number_format($row->StockInQty, 2, '.', ',') }}</td>
                <td class="text-end">{{ number_format($row->StockOutQty, 2, '.', ',') }}</td>
                <td class="text-end">
                    @if(($row->IDX_M_TransactionType ?? 0) == 3)
                        {{ number_format($row->StockInForeignAmount, 2, '.', ',') }}
                    @else
                        {{ number_format($row->StockOutForeignAmount, 2, '.', ',') }}
                    @endif
                </td>
                <td class="text-center">
                    @if($is_dup)
                        <span class="badge bg-danger">Duplikat ({{ $row->DupCount }})</span>
                    @else
                        <span class="badge bg-success">OK</span>
                    @endif
                </td>
                <td class="text-center">
                    <div class="input-group-prepend text-center">
                        <x-btn-edit-detail :id="$row->IDX_T_StockCardValas" function="editStockCard" />
                        <x-btn-delete-detail :id="$row->IDX_T_StockCardValas" :label="$row->ValasName" function="deleteStockCard" />
                    </div>
                </td>
            </tr>
        @endforeach

    @else
        <tr>
            <td colspan="9" class="text-center">Belum ada baris kartu stok untuk transaksi ini.</td>
        </tr>
    @endif
    </tbody>
</table>
