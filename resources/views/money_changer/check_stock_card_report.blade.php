@extends('layouts.report_data')

@section('title')
    {{ $title }}
@endsection

@section('pagetitle')
    {{ $page_title }}
@endsection

@section('content')

    @php
        $total_rows = count($records);
        $diff_rows = 0;
        $missing_rows = 0;
        foreach ($records as $r) {
            if (($r->IsMissingDetail ?? 0) == 1 || ($r->IsMissingHeader ?? 0) == 1) {
                $missing_rows += 1;
            } elseif (round($r->DiffQty, 4) != 0) {
                $diff_rows += 1;
            }
        }
        $ok_rows = $total_rows - $diff_rows - $missing_rows;
    @endphp

    <!-- BEGIN REPORT PARAMETER -->
    <div style="width:100%;">
        <div style="float:left;width:100%;">
            <table>
                <tr>
                    <td class="param-key">JENIS REKONSILIASI</td>
                    <td class="param-value">: {{ $ScopeName }}</td>
                </tr>
                <tr>
                    <td class="param-key">PILIHAN DATA</td>
                    <td class="param-value">: {{ $DataScopeName }}</td>
                </tr>
                <tr>
                    <td class="param-key">CABANG</td>
                    <td class="param-value">: {{ $BranchName }}</td>
                </tr>
                <tr>
                    <td class="param-key">VALUTA ASING</td>
                    <td class="param-value">: {{ $ValasName }}</td>
                </tr>
                <tr>
                    <td class="param-key">PERIODE TRANSAKSI</td>
                    <td class="param-value">: {{ date('d M Y', strtotime($fields['start_date'])) }} s/d {{ date('d M Y', strtotime($fields['end_date'])) }}</td>
                </tr>
                <tr>
                    <td class="param-key">RINGKASAN</td>
                    <td class="param-value">: {{ $total_rows }} baris &mdash;
                        <strong style="color:green">{{ $ok_rows }} sesuai</strong>,
                        <strong style="color:brown">{{ $diff_rows }} selisih</strong>,
                        <strong style="color:red">{{ $missing_rows }} tidak ditemukan</strong>
                    </td>
                </tr>
            </table>
        </div>
    </div>
    <br/>
    <hr>
    <br/>
    <!-- END REPORT PARAMETER -->

    <!-- BEGIN REPORT DATA -->
    <table id="table-report" class="minimalistBlack">
        @php
            $row_number = 0;
            $group_number = 0;
            $group_a1 = '';
            $group_a2 = '';
        @endphp

        @forelse ($records as $row)

            @php
                $row_number += 1;
                $group_a1 = $row->TransactionTypeDesc;

                $is_missing = (($row->IsMissingDetail ?? 0) == 1 || ($row->IsMissingHeader ?? 0) == 1);
                $has_diff = (!$is_missing && round($row->DiffQty, 4) != 0);
            @endphp

            @if($group_a1 <> $group_a2)
                <thead>
                    <tr class="bg-info">
                        <th class="text-start" colspan="11">{{ strtoupper($group_a1) }}</th>
                    </tr>
                    <tr>
                        <th>#</th>
                        <th>CABANG</th>
                        <th>CURRENCY</th>
                        <th>SKU</th>
                        <th>NAMA VALAS</th>
                        <th>NO TRANSAKSI</th>
                        <th>TANGGAL</th>
                        <th class="text-center">QTY KARTU STOK</th>
                        <th class="text-center">QTY TRANSAKSI</th>
                        <th class="text-center">SELISIH</th>
                        <th class="text-center">STATUS</th>
                    </tr>
                </thead>
                <tbody>

                @php
                    $group_number = 0;
                    $group_a2 = $group_a1;
                @endphp
            @endif

            @php $group_number += 1; @endphp

            <tr>
                <td>{{ $group_number }}</td>
                <td class="text-left">{{ $row->BranchName }}</td>
                <td>{{ $row->CurrencyID }}</td>
                <td>{{ $row->ValasSKU }}</td>
                <td>{{ $row->ValasName }}</td>
                <td>
                    @if($row->IDX_M_TransactionType == 3)
                        <a href="{{ url('mc-purchase-order/update') . '/' . $row->IDX_Transaction }}" target="_blank">{{ $row->TransactionNo }}</a>
                    @else
                        <a href="{{ url('mc-sales-order/update') . '/' . $row->IDX_Transaction }}" target="_blank">{{ $row->TransactionNo }}</a>
                    @endif
                </td>
                <td>{{ $row->TransactionDate ? date('d M Y', strtotime($row->TransactionDate)) : '' }}</td>
                <td class="text-right">{{ number_format($row->StockCardQty, 2, '.', ',') }}</td>
                <td class="text-right">{{ number_format($row->TransactionQty, 2, '.', ',') }}</td>
                <td class="text-right">
                    @if($has_diff || $is_missing)
                        <span style="color:brown"><strong>{{ number_format($row->DiffQty, 2, '.', ',') }}</strong></span>
                    @else
                        {{ number_format($row->DiffQty, 2, '.', ',') }}
                    @endif
                </td>
                <td class="text-center">
                    @if($is_missing)
                        <span style="color:red"><strong>TIDAK DITEMUKAN</strong></span>
                    @elseif($has_diff)
                        <span style="color:brown"><strong>SELISIH</strong></span>
                    @else
                        <span style="color:green">SESUAI</span>
                    @endif
                </td>
            </tr>

        @empty
            <tbody>
                <tr>
                    <td colspan="11" class="text-center">Tidak ada data kartu stok pada periode yang dipilih.</td>
                </tr>
            </tbody>
        @endforelse
        </tbody>
    </table>
    <!-- END REPORT DATA -->

@endsection
