@php
    /*
     * NOTA PDF — isi dan tata letaknya sama persis dengan Nota Kasir
     * (money_changer/sales_order_nota_kasir.blade.php), bedanya keluarannya PDF
     * untuk diarsip atau dikirim ke nasabah, bukan untuk dicetak ke dot matrix.
     *
     * Angka totalnya dihitung di SalesOrderController::nota_data() supaya kedua
     * nota tidak pernah berbeda isinya.
     *
     * Ditulis untuk dompdf: hanya tabel dan CSS sederhana, tanpa flexbox,
     * lebar kolom memakai persen, dan kertas A5 mendatar (210 x 148 mm)
     * diatur di controller lewat setPaper().
     */

    $baris = $records_detail ?? [];

    $rp = function ($nilai, $desimal = 2) {
        return number_format((float) $nilai, $desimal, '.', ',');
    };
@endphp
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8" />
    <title>Nota {{ $header->SONumber }}</title>
    <style>
        @page { margin: 6mm 7mm; }

        body {
            margin: 0;
            padding: 0;
            color: #000;
            font-family: "Courier", "Courier New", monospace;
            font-size: 9.5pt;
            line-height: 1.3;
        }

        table { width: 100%; border-collapse: collapse; }
        td, th { padding: 0; vertical-align: top; }

        .kop td { padding-bottom: 0; }
        .kop .kanan { padding-left: 6mm; }

        .rinci { margin-top: 3mm; }
        .rinci th {
            border-top: 1.5px solid #000;
            border-bottom: 1.5px solid #000;
            padding: 1mm;
            text-align: left;
            font-weight: bold;
        }
        .rinci td { padding: 0.6mm 1mm; }
        .rinci .total td {
            border-top: 1.5px solid #000;
            border-bottom: 1.5px solid #000;
            padding: 1mm;
        }

        .angka { text-align: right; }
        /* Judul kolom angka ikut rata kanan; tanpa ini .rinci th yang
           lebih spesifik menahannya tetap rata kiri sehingga judulnya tidak
           sejajar dengan angkanya. */
        .rinci th.angka { text-align: right; }
        .tebal { font-weight: bold; }

        .ttd { margin-top: 10mm; }
        .ttd td { text-align: center; }
        .ttd .garis { padding-top: 16mm; }
    </style>
</head>
<body>

    {{-- KOP: perusahaan di kiri, nasabah di kanan --}}
    <table class="kop">
        <tr>
            <td width="56%">
                <div class="tebal">INVOICE</div>
                <div class="tebal">{{ $header->CompanyName }}</div>
                <div>{{ $header->CompanyAddress }}</div>
                <div>{{ $header->CompanyAddress2 }}</div>
                @if($header->CompanyLicense !== '')
                    <div>NO: {{ $header->CompanyLicense }}</div>
                @endif
            </td>
            <td width="44%" class="kanan">
                <div class="tebal">{{ date('d F Y', strtotime($header->SODate)) }}</div>
                <div class="tebal">{{ $header->PartnerName }}</div>
                <div>{{ $header->PartnerAddress }}</div>
                <div>{{ $header->PartnerAddress2 }}</div>
                @if($header->PartnerPhone !== '')
                    <div>{{ $header->PartnerPhone }}</div>
                @endif
            </td>
        </tr>
        <tr>
            <td>No. Faktur / Referensi : {{ $header->ReferenceNo !== '' ? $header->ReferenceNo : $header->SONumber }}</td>
            <td class="kanan">
                @if($header->PartnerNIK !== '')
                    NIK : {{ $header->PartnerNIK }}
                @endif
            </td>
        </tr>
        <tr>
            <td>No. Nota Sistem : {{ $header->SONumber }}</td>
            <td class="kanan angka">Admin : {{ $header->AdminName }}</td>
        </tr>
    </table>

    {{-- RINCIAN TRANSAKSI --}}
    <table class="rinci">
        <thead>
            <tr>
                <th width="5%">No.</th>
                <th width="11%">Currency</th>
                <th width="22%">Description</th>
                <th width="6%">Trx.</th>
                <th width="16%" class="angka">Forex Amount</th>
                <th width="15%" class="angka">Rate</th>
                <th width="25%" class="angka">Local Amount</th>
            </tr>
        </thead>
        <tbody>
            @foreach($baris as $i => $b)
                <tr>
                    <td>{{ $i + 1 }}</td>
                    <td>{{ $b->ForeignCurrencyID }}</td>
                    <td>{{ strtoupper($b->ValasName) }}</td>
                    <td>{{ (int) $b->IDX_M_TransactionType === 1 ? 'Buy' : 'Sell' }}</td>
                    <td class="angka">{{ $rp($b->ForeignAmount) }}</td>
                    <td class="angka">{{ $rp($b->ExchangeRate) }}</td>
                    <td class="angka">{{ $rp($b->BaseCurrencyAmount) }}</td>
                </tr>
            @endforeach

            @if(count($baris) == 0)
                <tr><td colspan="7">Tidak ada rincian transaksi.</td></tr>
            @endif

            <tr class="total">
                <td colspan="4">({{ date('d/m/Y H:i:s', strtotime($header->DCreate)) }})</td>
                <td class="angka">{{ $rp($total_valas) }}</td>
                <td class="angka tebal">Total :</td>
                <td class="angka tebal">{{ $rp($total_net) }}</td>
            </tr>
        </tbody>
    </table>

    <div>
        {{ $total_net >= 0 ? 'Diterima dari nasabah' : 'Dibayarkan kepada nasabah' }} :
        Rp {{ $rp(abs($total_net)) }}
        @if($header->SONotes !== '')
            &middot; {{ $header->SONotes }}
        @endif
    </div>

    {{-- TANDA TANGAN --}}
    <table class="ttd">
        <tr>
            <td width="50%">Served By,</td>
            <td width="50%">Customer,</td>
        </tr>
        <tr>
            <td class="garis">( {{ $header->AdminName }} )</td>
            <td class="garis">( {{ $header->PartnerName }} )</td>
        </tr>
    </table>

</body>
</html>
