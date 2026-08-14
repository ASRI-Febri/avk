@php
    /*
     * NOTA KASIR — cetak ke Epson LX-310 (9 pin, continuous form 9.5" x 5.5").
     *
     * Sengaja HTML, bukan PDF: pada printer 9 pin, PDF dikirim sebagai gambar
     * ber-dither sehingga hurufnya kabur dan lambat. HTML dengan satu fon
     * monospace dicetak sebagai teks, hasilnya tajam dan cepat.
     *
     * Aturan tata letaknya keras:
     *  - satu fon monospace saja (Courier), 10 cpi, supaya kolom lurus
     *  - hitam pekat, tanpa abu abu, tanpa blok warna, tanpa latar
     *  - garis pemisah memakai garis tipis, bukan blok tebal
     */

    $baris = $records_detail ?? [];

    $total_valas = 0;
    $total_beli  = 0;   // valas dibeli dari nasabah -> perusahaan membayar
    $total_jual  = 0;   // valas dijual ke nasabah   -> perusahaan menerima

    foreach ($baris as $b) {
        $total_valas += (float) $b->ForeignAmount;

        if ((int) $b->IDX_M_TransactionType === 1) {
            $total_beli += (float) $b->BaseCurrencyAmount;
        } else {
            $total_jual += (float) $b->BaseCurrencyAmount;
        }
    }

    // Positif: nasabah membayar. Negatif: nasabah menerima uang.
    $total_net = $total_jual - $total_beli;

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
        html, body {
            margin: 0;
            padding: 0;
            background: #fff;
            color: #000;
            font-family: 'Courier New', Courier, monospace;
            font-size: 11pt;
            line-height: 1.35;
        }

        .lembar {
            width: 225mm;                 /* area cetak 9.5" dikurangi margin traktor */
            margin: 0 auto;
            padding: 6mm 8mm;
        }

        table { width: 100%; border-collapse: collapse; }
        td, th { padding: 0; vertical-align: top; }

        .kop td { padding-bottom: 0; }
        .kop .kanan { padding-left: 8mm; }

        .rinci { margin-top: 2mm; }
        .rinci th {
            border-top: 1px solid #000;
            border-bottom: 1px solid #000;
            padding: 0.6mm 1mm;
            text-align: left;
            font-weight: bold;
        }
        .rinci td { padding: 0.4mm 1mm; }
        .rinci .total td {
            border-top: 1px solid #000;
            border-bottom: 1px solid #000;
            padding: 0.6mm 1mm;
        }

        .angka { text-align: right; white-space: nowrap; }
        .tebal { font-weight: bold; }
        .ttd { margin-top: 12mm; }
        .ttd td { text-align: center; }
        .ttd .garis { padding-top: 18mm; }

        /* Panel bantu di layar, tidak ikut tercetak */
        .toolbar {
            font-family: Arial, Helvetica, sans-serif;
            font-size: 12px;
            background: #f1f3f5;
            border-bottom: 1px solid #ced4da;
            padding: 8px 12px;
        }
        .toolbar button, .toolbar a {
            font-size: 12px; padding: 4px 10px; margin-right: 6px; cursor: pointer;
            border: 1px solid #adb5bd; background: #fff; border-radius: 3px;
            text-decoration: none; color: #212529;
        }
        .toolbar .catatan { color: #495057; margin-left: 4px; }

        @media print {
            .toolbar { display: none; }

            /* Continuous form 9.5 x 5.5 inci */
            @page { size: 241mm 140mm; margin: 5mm 6mm; }

            html, body { font-size: 10pt; }
            .lembar { width: auto; margin: 0; padding: 0; }

            /* 9 pin hanya bisa hitam atau kosong: paksa semuanya hitam pekat */
            * { color: #000 !important; background: transparent !important; }
        }
    </style>
</head>
<body>

<div class="toolbar">
    <button type="button" onclick="window.print()">Cetak</button>
    <a href="{{ url('mc-sales-order/update/'.$header->IDX_T_SalesOrder) }}">Kembali ke transaksi</a>
    <span class="catatan">
        Epson LX-310 &middot; continuous form 9,5" &times; 5,5" &middot;
        di dialog cetak pilih ukuran kertas yang sama dan matikan "fit to page" agar kolom tetap lurus.
    </span>
</div>

<div class="lembar">

    {{-- KOP: perusahaan di kiri, nasabah di kanan --}}
    <table class="kop">
        <tr>
            <td width="55%">
                <div class="tebal">INVOICE</div>
                <div class="tebal">{{ $header->CompanyName }}</div>
                <div>{{ $header->CompanyAddress }}</div>
                <div>{{ $header->CompanyAddress2 }}</div>
                @if($header->CompanyLicense !== '')
                    <div>NO: {{ $header->CompanyLicense }}</div>
                @endif
            </td>
            <td width="45%" class="kanan">
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
                <th width="10%">Currency</th>
                <th width="30%">Description</th>
                <th width="8%">Trx.</th>
                <th width="15%" class="angka">Forex Amount</th>
                <th width="13%" class="angka">Rate</th>
                <th width="19%" class="angka">Local Amount</th>
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
            &nbsp;&middot;&nbsp; {{ $header->SONotes }}
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

</div>

<script>
    // Langsung buka dialog cetak; kalau dibatalkan, notanya tetap bisa dibaca
    // di layar dan tombol Cetak di atas masih tersedia.
    window.addEventListener('load', function () {
        window.setTimeout(function () { window.print(); }, 250);
    });
</script>

</body>
</html>
