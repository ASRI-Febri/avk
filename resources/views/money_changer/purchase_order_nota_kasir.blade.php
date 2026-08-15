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
        /*
         * Font nota: DejaVu Sans Mono, dimuat dari server sendiri.
         *
         * Courier New yang dipakai sebelumnya bergaris terlalu tipis. Diukur
         * pada ukuran cetak yang sama, tintanya hanya sekitar separuh: 309
         * piksel pekat berbanding 600. Di printer 9 jarum seperti LX-310,
         * goresan setipis itu kehilangan titik sehingga huruf tampak pudar
         * dan patah, terutama pada angka.
         *
         * Fontnya dimuat dari server, bukan mengandalkan yang terpasang di
         * komputer kasir, supaya hasil cetak setiap unit sama persis. Lebar
         * karakternya hampir identik dengan Courier (8.83 vs 8.80 piksel),
         * jadi susunan kolom nota tidak bergeser.
         */
        @font-face {
            font-family: 'NotaMono';
            src: url('{{ URL::asset('assets/fonts/DejaVuSansMono.ttf') }}') format('truetype');
            font-weight: normal;
            font-style: normal;
        }

        @font-face {
            font-family: 'NotaMono';
            src: url('{{ URL::asset('assets/fonts/DejaVuSansMono-Bold.ttf') }}') format('truetype');
            font-weight: bold;
            font-style: normal;
        }

        html, body {
            margin: 0;
            padding: 0;
            background: #fff;
            color: #000;
            font-family: 'NotaMono', 'Lucida Console', Consolas, 'Courier New', monospace;
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
        .kop .kanan { padding-left: 6mm; }

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
        /* Judul kolom angka ikut rata kanan; tanpa ini .rinci th yang
           lebih spesifik menahannya tetap rata kiri sehingga judulnya tidak
           sejajar dengan angkanya. */
        .rinci th.angka { text-align: right; }
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
            /*
             * Batas atas 14mm, bukan 5mm. Kepala cetak LX-310 tidak bisa
             * menjangkau beberapa milimeter teratas kertas, dan posisi
             * awal kertas tidak pernah persis sama tiap kali dipasang,
             * sehingga baris INVOICE terpotong. Isi nota hanya memakai
             * sekitar 107mm dari 148mm, jadi ruang bawahnya masih cukup.
             */
            @page { size: 210mm 148mm; margin: 14mm 7mm 5mm; }

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
            {{-- 116mm: alamat perusahaan 48 karakter butuh 110mm, sisanya jarak aman --}}
            <td style="width:116mm">
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
            <td>No. Invoice : {{ $header->PONumber }}</td>
            <td class="kanan">
                @if($header->PartnerNIK !== '')
                    NIK : {{ $header->PartnerNIK }}
                @endif
            </td>
        </tr>
        <tr>
            <td>No. Referensi : {{ $header->ReferenceNo !== '' ? $header->ReferenceNo : '-' }}</td>
            <td class="kanan angka">Admin : {{ $header->AdminName }}</td>
        </tr>
    </table>

    {{-- RINCIAN TRANSAKSI --}}
    <table class="rinci">
        <thead>
            <tr>
                {{--
                    Lebar kolom dihitung dari lebar karakter font nota (10pt
                    DejaVu Sans Mono = 2.12mm) ditambah padding sel 2mm:

                      Description  nama valas terpanjang 29 karakter -> 64mm
                      Forex/Local  judulnya 12 karakter -> 27mm, angka lebih pendek
                      Rate         angka terpanjang 9 karakter -> 21mm

                    Sisanya diberikan ke Description supaya nama valas tidak
                    pernah patah ke baris kedua.
                --}}
                <th style="width:9mm">No.</th>
                <th style="width:20mm">Currency</th>
                <th style="width:70mm">Description</th>
                <th style="width:11mm">Trx.</th>
                <th style="width:28mm" class="angka">Forex Amount</th>
                <th style="width:22mm" class="angka">Rate</th>
                <th style="width:36mm" class="angka">Local Amount</th>
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
