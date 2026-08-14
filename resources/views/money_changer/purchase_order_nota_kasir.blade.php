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

    // Angka totalnya dihitung di PurchaseOrderController::nota_data() supaya
    // Nota Kasir dan Nota PDF memakai perhitungan yang sama persis.
    $baris = $records_detail ?? [];

    $rp = function ($nilai, $desimal = 2) {
        return number_format((float) $nilai, $desimal, '.', ',');
    };
@endphp
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8" />
    <title>Nota {{ $header->PONumber }}</title>
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

        /*
         * Kertas 1/2 A4 = 210 x 148 mm (A4 dipotong melintang).
         * Lebar area cetak dikunci 196 mm supaya Chrome tidak perlu memutar
         * halaman agar muat: begitu isi lebih lebar dari kertas, Chrome diam
         * diam memilih landscape A4 dan hasilnya tercetak menyeberang lipatan.
         */
        .lembar {
            width: 196mm;
            margin: 0 auto;
            padding: 5mm 7mm;
        }

        table { width: 196mm; border-collapse: collapse; table-layout: fixed; }
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
        .ttd { margin-top: 8mm; }
        .ttd td { text-align: center; }
        .ttd .garis { padding-top: 14mm; }

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
        .toolbar .catatan { color: #495057; margin-top: 6px; line-height: 1.5; }

        @media print {
            .toolbar { display: none; }

            /* 1/2 A4 mendatar: 210 x 148 mm */
            @page { size: 210mm 148mm; margin: 5mm 7mm; }

            html, body { font-size: 10pt; line-height: 1.25; }
            .lembar { width: auto; margin: 0; padding: 0; }
            table { width: 100%; }

            /* 9 pin hanya bisa hitam atau kosong: paksa semuanya hitam pekat */
            * { color: #000 !important; background: transparent !important; }

            /*
             * Garis 1px di 120 dpi hanya sebaris jarum sehingga tercetak
             * putus putus. 2px membuatnya padat tetapi tetap garis, bukan blok.
             */
            .rinci th, .rinci .total td { border-width: 2px; }
        }
    </style>
</head>
<body>

<div class="toolbar">
    <div>
        <button type="button" onclick="window.print()">Cetak</button>
        <a href="{{ url('mc-purchase-order/update/'.$header->IDX_T_PurchaseOrder) }}">Kembali ke transaksi</a>
    </div>
    <div class="catatan">
        <b>Kertas 1/2 A4 (210 &times; 148 mm), Epson LX-310.</b>
        Di dialog cetak Chrome atur: <b>Paper size</b> = A5 atau ukuran khusus 210 &times; 148 mm
        (jangan A4, isinya akan diputar melintang) &middot;
        <b>Scale</b> = Actual size / 100% &middot;
        <b>Margins</b> = Default &middot;
        <b>Headers and footers</b> jangan dicentang.
        Di driver printer pilih kualitas <b>240 &times; 144 dpi (LQ)</b> agar huruf lebih tebal;
        120 &times; 72 dpi adalah mode draft sehingga hasilnya tipis.
    </div>
</div>

<div class="lembar">

    {{-- KOP: perusahaan di kiri, nasabah di kanan --}}
    <table class="kop">
        <tr>
            <td style="width:112mm">
                <div class="tebal">INVOICE</div>
                <div class="tebal">{{ $header->CompanyName }}</div>
                <div>{{ $header->CompanyAddress }}</div>
                <div>{{ $header->CompanyAddress2 }}</div>
                @if($header->CompanyLicense !== '')
                    <div>NO: {{ $header->CompanyLicense }}</div>
                @endif
            </td>
            <td style="width:84mm" class="kanan">
                <div class="tebal">{{ date('d F Y', strtotime($header->PODate)) }}</div>
                <div class="tebal">{{ $header->PartnerName }}</div>
                <div>{{ $header->PartnerAddress }}</div>
                <div>{{ $header->PartnerAddress2 }}</div>
                @if($header->PartnerPhone !== '')
                    <div>{{ $header->PartnerPhone }}</div>
                @endif
            </td>
        </tr>
        <tr>
            <td>No. Faktur / Referensi : {{ $header->ReferenceNo !== '' ? $header->ReferenceNo : $header->PONumber }}</td>
            <td class="kanan">
                @if($header->PartnerNIK !== '')
                    NIK : {{ $header->PartnerNIK }}
                @endif
            </td>
        </tr>
        <tr>
            <td>No. Nota Sistem : {{ $header->PONumber }}</td>
            <td class="kanan angka">Admin : {{ $header->AdminName }}</td>
        </tr>
    </table>

    {{-- RINCIAN TRANSAKSI --}}
    <table class="rinci">
        <thead>
            <tr>
                <th style="width:9mm">No.</th>
                <th style="width:21mm">Currency</th>
                <th style="width:44mm">Description</th>
                <th style="width:12mm">Trx.</th>
                <th style="width:30mm" class="angka">Forex Amount</th>
                <th style="width:28mm" class="angka">Rate</th>
                <th style="width:38mm" class="angka">Local Amount</th>
            </tr>
        </thead>
        <tbody>
            @foreach($baris as $i => $b)
                <tr>
                    <td>{{ $i + 1 }}</td>
                    <td>{{ $b->ForeignCurrencyID }}</td>
                    <td>{{ strtoupper($b->ValasName) }}</td>
                    <td>Buy</td>
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
        @if($header->PONotes !== '')
            &nbsp;&middot;&nbsp; {{ $header->PONotes }}
        @endif
    </div>

    {{-- TANDA TANGAN --}}
    <table class="ttd">
        <tr>
            <td style="width:98mm">Served By,</td>
            <td style="width:98mm">Customer,</td>
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
