@extends('layouts.master-form-transaction')

@section('active_link')
    $('#nav-transaction').addClass('mm-active');
    $('#nav-ul-transaction').addClass('mm-show');
    $('#nav-li-input-so-quick').addClass('mm-active');
@endsection

@section('form-remark')
    Input cepat transaksi penjualan valuta asing. Isi informasi umum dan detail valas dalam satu form,
    lalu klik <b>Simpan</b>.
@endsection

@section('content-form')

    {{-- HIDDEN FIELDS --}}
    <input type="hidden" id="IDX_T_SalesOrder" name="IDX_T_SalesOrder" value="{{ $fields->IDX_T_SalesOrder }}"/>
    <input type="hidden" id="IDX_M_Company"    name="IDX_M_Company"    value="{{ $fields->IDX_M_Company }}"/>
    <input type="hidden" id="IDX_M_Branch"     name="IDX_M_Branch"     value="{{ $fields->IDX_M_Branch }}"/>
    <input type="hidden" id="IDX_M_Partner"    name="IDX_M_Partner"    value="{{ $fields->IDX_M_Partner }}"/>
    <input type="hidden" id="SOStatus"         name="SOStatus"         value="{{ $fields->SOStatus }}"/>
    <input type="hidden" id="SONumber"         name="SONumber"         value="{{ $fields->SONumber }}"/>
    <input type="hidden" id="detail_json"      name="detail_json"      value="[]"/>
    <input type="hidden" id="payment_json"     name="payment_json"     value="[]"/>
    <input type="hidden" id="confirm"          name="confirm"          value="0"/>
    <input type="hidden" id="deleted_ids_json" name="deleted_ids_json" value="[]"/>

    @if($state !== 'create')
        <h5 class="text-secondary mb-3">
            {{ $fields->SONumber }} <span class="text-muted">— {{ $fields->StatusDesc ?? '' }}</span>
        </h5>
    @endif

    {{-- ======================================================
         BAGIAN 1 : Informasi Umum
    ====================================================== --}}
    <div class="card border mb-3">
        <div class="card-header card-header-bordered">
            <h3 class="card-title"><i class="fas fa-file-invoice me-2"></i> Informasi Umum</h3>
        </div>
        <div class="card-body">
            <div class="row g-3">

                <div class="col-md-3">
                    <label class="form-label text-secondary">No Nota</label>
                    <input type="text" id="ReferenceNo" name="ReferenceNo"
                        class="form-control" placeholder="No nota fisik"
                        value="{{ $fields->ReferenceNo }}">
                </div>

                <div class="col-md-3">
                    <label class="form-label text-secondary">Tanggal <span class="text-danger">*</span></label>
                    <input type="text" id="SODate" name="SODate"
                        class="form-control required datepicker2"
                        placeholder="YYYY-MM-DD"
                        value="{{ $fields->SODate }}">
                </div>

                <div class="col-md-6">
                    <label class="form-label text-secondary">Konsumen <span class="text-danger">*</span></label>
                    <div class="input-group">
                        <input type="text" id="PartnerDesc" name="PartnerDesc"
                            class="form-control required" placeholder="Pilih konsumen..."
                            value="{{ $fields->PartnerDesc }}" readonly>
                        <button type="button" class="btn btn-outline-primary" id="btn-find-partner">
                            <i class="fas fa-search"></i> Cari
                        </button>
                    </div>
                </div>

                <div class="col-md-12">
                    <label class="form-label text-secondary">Keterangan <span class="text-danger">*</span></label>
                    <input type="text" id="SONotes" name="SONotes"
                        class="form-control required"
                        placeholder="Keterangan transaksi"
                        value="{{ $fields->SONotes }}">
                </div>

                <div class="col-md-6">
                    <label class="form-label text-secondary">Sumber Dana</label>
                    <input type="text" id="FundSource" name="FundSource"
                        class="form-control" placeholder="Pribadi / Perusahaan / lainnya"
                        value="{{ $fields->FundSource ?? '' }}">
                </div>

                <div class="col-md-6">
                    <label class="form-label text-secondary">Tujuan Transaksi</label>
                    <input type="text" id="TransactionPurpose" name="TransactionPurpose"
                        class="form-control" placeholder="Traveling / Medical / Education / lainnya"
                        value="{{ $fields->TransactionPurpose ?? '' }}">
                </div>

            </div>
        </div>
    </div>

    {{-- ======================================================
         BAGIAN 2 : Detail Valas (Dynamic Table)
    ====================================================== --}}
    <div class="card border mb-3">
        <div class="card-header card-header-bordered">
            <h3 class="card-title"><i class="fas fa-coins me-2"></i> Detail Valuta Asing</h3>
            <div class="card-addon">
                <button type="button" class="btn btn-sm btn-outline-primary" id="btn-add-row">
                    <i class="fas fa-plus me-1"></i> Tambah Baris
                </button>
            </div>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-bordered table-hover mb-0 align-middle" id="tbl-detail">
                    <thead class="table-light">
                        <tr>
                            <th style="width:40px;" class="text-center">No</th>
                            <th style="min-width:220px;">Valas <span class="text-danger">*</span></th>
                            <th style="width:110px;" class="text-end">Qty (Lembar) <span class="text-danger">*</span></th>
                            <th style="width:95px;" class="text-end">Sisa Stok</th>
                            <th style="width:130px;" class="text-end">Nilai Tukar <span class="text-danger">*</span></th>
                            <th style="width:140px;" class="text-end">Jumlah Valas</th>
                            <th style="width:160px;" class="text-end">Total (IDR)</th>
                            <th style="min-width:160px;">Catatan</th>
                            <th style="width:50px;" class="text-center">Hapus</th>
                        </tr>
                    </thead>
                    <tbody id="tbody-detail">
                        {{-- Diisi JS --}}
                    </tbody>
                    <tfoot>
                        <tr class="table-light fw-bold">
                            <td colspan="6" class="text-end pe-3">TOTAL</td>
                            <td class="text-end" id="td-grand-total">IDR 0</td>
                            <td colspan="2"></td>
                        </tr>
                    </tfoot>
                </table>
            </div>
        </div>
    </div>

    {{-- ======================================================
         BAGIAN 3 : Pembayaran
         Satu nota boleh dibayar lebih dari satu cara, mis. sebagian tunai
         sebagian transfer. Baris CASH dan TRANSFER sudah disiapkan, kasir
         tinggal mengisi nominalnya. Pembayaran baru diposting saat nota
         dikonfirmasi, karena penerimaan hanya boleh untuk nota Approved.
    ====================================================== --}}
    @php
        $sudah_approved = trim($fields->SOStatus ?? 'D') === 'A';
        $sudah_dibayar  = count($records_payment ?? []) > 0;
    @endphp

    <div class="card border mb-3">
        <div class="card-header card-header-bordered">
            <h3 class="card-title"><i class="fas fa-money-bill-wave me-2"></i> Pembayaran</h3>
            @if(!$sudah_dibayar)
                <div class="card-addon">
                    <button type="button" class="btn btn-sm btn-outline-primary" id="btn-add-payment">
                        <i class="fas fa-plus me-1"></i> Tambah Cara Bayar
                    </button>
                </div>
            @endif
        </div>
        <div class="card-body">

            @if($sudah_dibayar)
                {{-- Nota sudah dibayar: tampilkan apa adanya, ubahnya lewat menu penjualan --}}
                <table class="table table-sm table-bordered mb-0">
                    <thead>
                        <tr>
                            <th>Kode Pembayaran</th>
                            <th>Tanggal</th>
                            <th>Cara Bayar</th>
                            <th>Status</th>
                            <th class="text-end">Jumlah</th>
                        </tr>
                    </thead>
                    <tbody>
                        @php $total_bayar = 0; @endphp
                        @foreach($records_payment as $bayar)
                            @php $total_bayar += (float) $bayar->ReceiveAmount; @endphp
                            <tr>
                                <td>
                                    <a href="{{ url('fm-financial-receive/update').'/'.$bayar->IDX_T_FinancialReceiveHeader }}" target="_blank">
                                        {{ $bayar->ReceiveID }}
                                    </a>
                                </td>
                                <td>{{ date('d M Y', strtotime($bayar->ReceiveDate)) }}</td>
                                <td>{{ $bayar->FinancialAccountDesc }}</td>
                                <td>{{ $bayar->StatusDesc }}</td>
                                <td class="text-end">{{ number_format($bayar->ReceiveAmount, 2, '.', ',') }}</td>
                            </tr>
                        @endforeach
                        <tr class="table-light fw-bold">
                            <td colspan="4" class="text-end">TOTAL</td>
                            <td class="text-end">{{ number_format($total_bayar, 2, '.', ',') }}</td>
                        </tr>
                    </tbody>
                </table>
            @else
                <div class="table-responsive">
                    <table class="table table-sm table-bordered mb-2" id="tbl-payment">
                        <thead>
                            <tr>
                                <th style="width:45%">Cara Bayar</th>
                                <th style="width:35%" class="text-end">Jumlah (IDR)</th>
                                <th style="width:20%" class="text-center">Aksi</th>
                            </tr>
                        </thead>
                        <tbody id="tbody-payment">
                            {{-- Diisi JS: baris CASH dan TRANSFER --}}
                        </tbody>
                        <tfoot>
                            <tr class="table-light fw-bold">
                                <td class="text-end pe-3">TOTAL PEMBAYARAN</td>
                                <td class="text-end" id="td-total-payment">0.00</td>
                                <td></td>
                            </tr>
                        </tfoot>
                    </table>
                </div>

                <div id="info-payment" class="alert alert-label-info mb-0">
                    Total pembayaran harus sama dengan nilai transaksi.
                </div>
            @endif

        </div>
    </div>

    <div class="row">
        <div class="col-12">
            @include('form_helper.btn_save_header')

            @if(!$sudah_dibayar)
                <button type="button" id="btn-save-confirm" class="btn btn-primary">
                    <i class="fas fa-check-double me-1"></i> Save &amp; Konfirmasi
                </button>
            @endif

            <a href="{{ url('mc-sales-order') }}" class="btn btn-outline-secondary">
                <i class="fas fa-times"></i> Batal
            </a>
        </div>
    </div>

@endsection

@section('css')
    <link href="{{ URL::asset('public/css/valas-select.css') }}" rel="stylesheet" type="text/css" />
@endsection

@section('script')
{{-- Masking angka: hanya digit, ribuan koma, desimal titik --}}
<script src="{{ URL::asset('public/js/money-mask.js') }}"></script>
<script>
var ddValas       = @json($dd_valas);
var ddValasOption = @json($dd_valas_option ?? []);
var ddAkun      = @json($dd_financial_account ?? []);
var akunCash    = @json($akun_cash ?? 0);
var akunTransfer= @json($akun_transfer ?? 0);
var sudahBayar  = @json(count($records_payment ?? []) > 0);
var existingRow = @json($records_detail ?? []);

// Sisa stok tiap pecahan sampai tanggal nota: { idx: {sku, sisa} }.
// Nota yang sudah approved stoknya sudah keluar di kartu stok, jadi
// pemeriksaan dilewati supaya tidak terhitung dua kali.
var stokValas      = @json((object) ($dd_valas_stok ?? []));
var lewatiCekStok  = @json(trim($fields->SOStatus ?? 'D') === 'A');
var urlStok        = '{{ $url_stok }}';

$(document).ready(function () {

    // ---------- Lookup Konsumen ----------
    $('#btn-find-partner').on('click', function () {
        var data = {
            _token:       $('#_token').val(),
            target_index: 'IDX_M_Partner',
            target_name:  'PartnerDesc'
        };
        callAjaxModalView('{{ url('/gn-select-partner') }}', data);
    });

    // ---------- Load baris existing (mode update) ----------
    if (existingRow.length > 0) {
        existingRow.forEach(function (row) {
            appendDetailRow({
                idx_t_salesorderdetail: row.IDX_T_SalesOrderDetail || 0,
                idx_m_valas:            row.IDX_M_Valas || '',
                idx_m_transactiontype:  row.IDX_M_TransactionType || 2,
                quantity:               parseFloat(row.Quantity)      || 0,
                foreign_amount:         parseFloat(row.ForeignAmount) || 0,
                exchange_rate:          parseFloat(row.ExchangeRate)  || 0,
                detail_notes:           row.DetailNotes || ''
            });
        });
    } else {
        appendDetailRow({}); // 1 baris kosong default
    }

    recalcAll();
    tampilkanStok();
    serializeDetail();

    // ---------- Tambah baris ----------
    $('#btn-add-row').on('click', function () {
        // fokus: pencarian valas langsung terbuka supaya kasir tinggal mengetik
        appendDetailRow({ fokus: true });
        serializeDetail();
    });

    // ---------- Hitung ulang baris saat input berubah ----------
    $(document).on('input change', '.inp-valas, .inp-foreign, .inp-rate, .inp-qty, .inp-notes', function () {
        var $row = $(this).closest('tr');
        recalcRow($row);
        recalcGrandTotal();
        tampilkanStok();
        serializeDetail();
    });

    // ---------- Stok mengikuti tanggal nota ----------
    // Stok dihitung sampai tanggal transaksi, jadi nota mundur punya sisa yang
    // berbeda dengan hari ini.
    $('#SODate').on('change', function () {
        muatStok($(this).val());
    });

    // ---------- Hapus baris ----------
    $(document).on('click', '.btn-del-row', function () {
        var $row = $(this).closest('tr');
        var detailId = parseInt($row.data('detail-id')) || 0;

        if (detailId > 0) {
            var deleted = JSON.parse($('#deleted_ids_json').val() || '[]');
            deleted.push(detailId);
            $('#deleted_ids_json').val(JSON.stringify(deleted));
        }

        $row.remove();

        if ($('#tbody-detail tr').length === 0) {
            appendDetailRow({});
        }

        renumberRows();
        recalcGrandTotal();
        tampilkanStok();
        serializeDetail();
    });

    // ---------- Pembayaran ----------
    if (!sudahBayar) {
        // Dua baris bawaan sesuai permintaan: CASH dan TRANSFER
        appendPaymentRow({ idx_akun: akunCash });
        appendPaymentRow({ idx_akun: akunTransfer });

        $('#btn-add-payment').on('click', function () {
            appendPaymentRow({});
        });

        $(document).on('click', '.btn-del-payment', function () {
            $(this).closest('tr').remove();
            recalcPayment();
        });

        $(document).on('input', '.inp-bayar', function () {
            recalcPayment();
        });

        // Nilai transaksi berubah -> selisihnya ikut dihitung ulang
        $('#tbl-detail').on('input change', 'input, select', function () {
            window.setTimeout(recalcPayment, 0);
        });
    }

    // ---------- Serialize sebelum save ----------
    // Tombolnya membawa onclick bawaan komponen yang langsung memanggil
    // saveHeader. Handler itu dilepas supaya urutannya pasti: periksa stok
    // dulu, baru kirim.
    $('#btn-save-header').removeAttr('onclick').on('click', function () {
        $('#confirm').val('0');
        serializeDetail();
        serializePayment();

        if (!stokMencukupi()) { return; }

        saveHeader('{{ $url_save_header }}');
    });

    // ---------- Save & Konfirmasi ----------
    $('#btn-save-confirm').on('click', function () {
        serializeDetail();
        serializePayment();

        if (!stokMencukupi()) { return; }

        var selisih = totalPembayaran() - totalTransaksi();

        if (Math.abs(selisih) > 0.01) {
            Swal.fire({
                title: 'Pembayaran belum pas',
                html: 'Total pembayaran <b>' + formatNumber(totalPembayaran(), 2) + '</b> tidak sama dengan ' +
                      'nilai transaksi <b>' + formatNumber(totalTransaksi(), 2) + '</b>.',
                icon: 'warning'
            });
            return;
        }

        Swal.fire({
            title: 'Konfirmasi transaksi?',
            html: 'Nota akan di-approve dan pembayaran sebesar <b>' + formatNumber(totalPembayaran(), 2) +
                  '</b> langsung dicatat.<br>Setelah dikonfirmasi, perubahan harus lewat menu penjualan.',
            icon: 'question',
            showCancelButton: true,
            confirmButtonText: 'Ya, Konfirmasi',
            cancelButtonText: 'Batal'
        }).then(function (hasil) {
            if (hasil.isConfirmed) {
                $('#confirm').val('1');
                saveHeader('{{ $url_save_header }}');
            }
        });
    });

    // ---------- Shortcut: Enter di baris terakhir -> tambah baris ----------
    $(document).on('keydown', '#tbl-detail input, #tbl-detail select', function (e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            var $row = $(this).closest('tr');
            if ($row.is(':last-child')) {
                appendDetailRow({});
                $('#tbody-detail tr:last-child').find('.inp-valas').focus();
            }
        }
    });
});

// =========================================================
// HELPERS
// =========================================================
function buildValasOptions(selected) {
    var html = '';
    Object.keys(ddValas).forEach(function (key) {
        var val  = (key === '' ? '' : key);
        var text = ddValas[key];
        var sel  = (String(selected) === String(val)) ? ' selected' : '';
        html += '<option value="' + val + '"' + sel + '>' + escapeHtml(text) + '</option>';
    });
    return html;
}

// =========================================================
// DROPDOWN VALAS
// Daftarnya panjang, jadi dipakai Select2: ada kotak pencarian, dikelompokkan
// per mata uang, dan bisa dicari lewat kode, nama, maupun SKU pecahan.
// =========================================================
function buildValasOptionsBaru(selected) {
    var html = '<option value=""></option>';
    var grupSekarang = '';

    ddValasOption.forEach(function (v) {
        var grup = v.kode + ' - ' + v.mata;

        if (grup !== grupSekarang) {
            if (grupSekarang !== '') { html += '</optgroup>'; }
            html += '<optgroup label="' + escapeHtml(grup) + '">';
            grupSekarang = grup;
        }

        // Teks option dipakai Select2 untuk pencarian, jadi kode, nama, dan SKU
        // semuanya disertakan walau yang tampil nanti dirapikan templateResult.
        var teksCari = v.kode + ' ' + v.mata + ' ' + v.pecahan + ' ' + v.sku;
        var sel = (String(selected) === String(v.id)) ? ' selected' : '';

        html += '<option value="' + v.id + '"' + sel +
                ' data-kode="' + escapeHtml(v.kode) + '"' +
                ' data-mata="' + escapeHtml(v.mata) + '"' +
                ' data-sku="' + escapeHtml(v.sku) + '"' +
                ' data-pecahan="' + escapeHtml(v.pecahan) + '">' +
                escapeHtml(teksCari) + '</option>';
    });

    if (grupSekarang !== '') { html += '</optgroup>'; }

    return html;
}

function tampilkanBarisValas(state) {
    if (!state.id) { return state.text; }

    var $opt = $(state.element);
    var kode = $opt.data('kode') || '';
    var sku = $opt.data('sku') || '';
    var pecahan = $opt.data('pecahan') || '';

    // Nama mata uang tidak diulang di sini karena sudah jadi judul grup.
    // Yang tersisa: kode sebagai penanda, pecahan sebagai isi, SKU sebagai
    // rujukan ke kartu stok dan laporan.
    return $(
        '<span>' +
            '<span class="pilih-valas__sku">' + escapeHtml(sku) + '</span>' +
            '<span class="pilih-valas__kode">' + escapeHtml(kode) + '</span>' +
            '<span class="pilih-valas__isi">' + escapeHtml(pecahan) + '</span>' +
        '</span>'
    );
}

function tampilkanValasTerpilih(state) {
    if (!state.id) { return state.text; }

    var $opt = $(state.element);
    var kode = $opt.data('kode') || '';
    var pecahan = $opt.data('pecahan') || '';

    return $('<span><span class="pilih-valas__kode">' + escapeHtml(kode) + '</span>' +
             escapeHtml(pecahan) + '</span>');
}

/**
 * Pencocokan kata kunci: semua kata harus ada, urutannya bebas.
 * Bawaan Select2 hanya mencocokkan potongan teks berurutan, sehingga ketikan
 * lazim seperti "usd 100" tidak ketemu padahal keduanya ada di baris yang sama.
 */
function cocokSemuaKata(kataKunci, teks) {
    var kata = String(kataKunci).toLowerCase().split(/\s+/).filter(function (k) { return k !== ''; });
    var isi = String(teks).toLowerCase();

    return kata.every(function (k) { return isi.indexOf(k) !== -1; });
}

function cocokkanValas(params, data) {
    if ($.trim(params.term || '') === '') { return data; }
    if (typeof data.text === 'undefined') { return null; }

    // Grup mata uang: tampilkan grupnya kalau ada anak yang cocok
    if (data.children && data.children.length) {
        var anak = data.children.filter(function (c) {
            return cocokSemuaKata(params.term, data.text + ' ' + c.text);
        });

        if (anak.length === 0) { return null; }

        var salinan = $.extend({}, data, true);
        salinan.children = anak;
        return salinan;
    }

    return cocokSemuaKata(params.term, data.text) ? data : null;
}

function pasangSelect2Valas($select) {
    $select.select2({
        width: '100%',
        placeholder: 'Cari valas / pecahan...',
        allowClear: false,
        dropdownAutoWidth: true,
        matcher: cocokkanValas,
        templateResult: tampilkanBarisValas,
        templateSelection: tampilkanValasTerpilih
    });
}

function appendDetailRow(row) {
    var idxDetail = row.idx_t_salesorderdetail || 0;
    var idxValas  = row.idx_m_valas            || '';
    var idxType   = row.idx_m_transactiontype  || 2;
    var qty       = parseFloat(row.quantity)        || 0;
    var foreign   = parseFloat(row.foreign_amount)  || 0;
    var rate      = parseFloat(row.exchange_rate)   || 0;
    var notes     = row.detail_notes || '';

    var nomor = $('#tbody-detail tr').length + 1;
    var total = foreign * rate;

    var $tr = $(
        '<tr data-detail-id="' + idxDetail + '">' +
            '<td class="text-center td-nomor">' + nomor + '</td>' +
            '<td>' +
                '<select class="form-control form-control-sm inp-valas">' +
                    buildValasOptionsBaru(idxValas) +
                '</select>' +
                '<input type="hidden" class="inp-txtype" value="' + idxType + '">' +
            '</td>' +
            // Qty berisi jumlah lembar/koin dan disimpan sebagai bilangan bulat,
            // jadi tidak ada angka desimal di sini.
            '<td><input type="text" class="form-control form-control-sm text-end inp-money inp-qty" inputmode="numeric" data-decimal="0" ' +
                'value="' + (qty ? formatNumber(qty, 0) : '') + '" placeholder="0"></td>' +
            // Sisa stok pecahan yang dipilih, ikut berubah begitu valas atau
            // qty diubah, supaya kasir tahu sebelum notanya dikirim.
            '<td class="text-end td-stok text-muted">-</td>' +
            '<td><input type="text" class="form-control form-control-sm text-end inp-money inp-rate" inputmode="decimal" data-decimal="4" ' +
                'value="' + formatNumber(rate, 4) + '" placeholder="0"></td>' +
            // Jumlah Valas dan Total dihitung dengan rumus yang sama dengan
            // stored procedure penyimpanan, jadi angkanya tidak bisa berbeda.
            '<td><input type="text" class="form-control form-control-sm text-end inp-foreign bg-light" ' +
                'value="' + formatNumber(foreign, 2) + '" readonly tabindex="-1"></td>' +
            '<td><input type="text" class="form-control form-control-sm text-end inp-total bg-light" ' +
                'value="' + formatNumber(total, 2) + '" readonly tabindex="-1"></td>' +
            '<td><input type="text" class="form-control form-control-sm inp-notes" ' +
                'value="' + escapeHtml(notes) + '" placeholder="Catatan"></td>' +
            '<td class="text-center">' +
                '<button type="button" class="btn btn-sm btn-outline-danger btn-del-row">' +
                    '<i class="fas fa-trash"></i>' +
                '</button>' +
            '</td>' +
        '</tr>'
    );

    $('#tbody-detail').append($tr);

    // Select2 harus dipasang setelah baris masuk ke DOM
    pasangSelect2Valas($tr.find('.inp-valas'));

    // Fokuskan pencarian begitu baris baru ditambahkan lewat tombol
    if (row.fokus) {
        $tr.find('.inp-valas').select2('open');
    }
}

function recalcRow($row) {
    // Rumusnya menyalin USP_MC_*OrderDetail_Save:
    //   ForeignAmount = ValasChangeNumber x Quantity
    //   BaseCurrency  = ForeignAmount x ExchangeRate
    var qty     = parseFloat(cleanNumber($row.find('.inp-qty').val()))  || 0;
    var rate    = parseFloat(cleanNumber($row.find('.inp-rate').val())) || 0;
    var pecahan = nilaiPecahan($row.find('.inp-valas').val());
    var foreign = qty * pecahan;

    $row.find('.inp-foreign').val(formatNumber(foreign, 2));
    $row.find('.inp-total').val(formatNumber(foreign * rate, 2));
}

// =========================================================
// STOK VALAS
// Sisa stok = SUM(StockInQty) - SUM(StockOutQty) per cabang dan pecahan sampai
// tanggal nota, rumus yang sama dengan validasi di stored procedure. Layar
// hanya memberi peringatan lebih awal; penolakan sebenarnya tetap di database.
// =========================================================
function sisaStok(idxValas) {
    var s = stokValas[String(idxValas)];
    return s ? (parseFloat(s.sisa) || 0) : 0;
}

function skuValas(idxValas) {
    var s = stokValas[String(idxValas)];
    return s ? s.sku : ('Valas #' + idxValas);
}

/**
 * Jumlah lembar yang diminta per pecahan di seluruh baris.
 * Dijumlahkan karena satu nota boleh punya dua baris pecahan yang sama, dan
 * yang menentukan cukup atau tidak adalah totalnya.
 */
function permintaanPerValas() {
    var permintaan = {};

    $('#tbody-detail tr').each(function () {
        var $r = $(this);
        var idx = parseInt($r.find('.inp-valas').val()) || 0;
        if (idx === 0) { return; }

        var qty = parseFloat(cleanNumber($r.find('.inp-qty').val())) || 0;
        permintaan[idx] = (permintaan[idx] || 0) + qty;
    });

    return permintaan;
}

/** Isi kolom Sisa Stok dan tandai merah baris yang melebihi stok */
function tampilkanStok() {
    var permintaan = permintaanPerValas();

    $('#tbody-detail tr').each(function () {
        var $r = $(this);
        var $sel = $r.find('.td-stok');
        var idx = parseInt($r.find('.inp-valas').val()) || 0;

        if (idx === 0) {
            $sel.text('-').removeClass('text-danger fw-bold').addClass('text-muted');
            $r.find('.inp-qty').removeClass('is-invalid');
            return;
        }

        var sisa = sisaStok(idx);
        var kurang = !lewatiCekStok && (permintaan[idx] || 0) > sisa;

        $sel.text(formatNumber(sisa, 0))
            .toggleClass('text-danger fw-bold', kurang)
            .toggleClass('text-muted', !kurang);

        $r.find('.inp-qty').toggleClass('is-invalid', kurang);
    });
}

/** Ambil ulang sisa stok saat tanggal nota berubah */
function muatStok(tanggal) {
    $.getJSON(urlStok, { date: tanggal, branch: $('#IDX_M_Branch').val() })
        .done(function (data) {
            stokValas = data || {};
            tampilkanStok();
        });
}

/**
 * Pesan kekurangan stok, kosong bila semuanya cukup.
 * Dipakai menahan tombol simpan sebelum data dikirim.
 */
function pesanStokKurang() {
    if (lewatiCekStok) { return ''; }

    var permintaan = permintaanPerValas();
    var pesan = [];

    Object.keys(permintaan).forEach(function (idx) {
        var sisa = sisaStok(idx);

        if (permintaan[idx] > sisa) {
            pesan.push('<b>' + escapeHtml(skuValas(idx)) + '</b>: diminta ' +
                formatNumber(permintaan[idx], 0) + ' lembar, sisa stok ' +
                formatNumber(sisa, 0) + ' lembar');
        }
    });

    return pesan.join('<br>');
}

/** TRUE bila stok cukup; bila kurang, tampilkan peringatannya */
function stokMencukupi() {
    var pesan = pesanStokKurang();

    if (pesan === '') { return true; }

    Swal.fire({
        title: 'Stok valas tidak mencukupi',
        html: pesan,
        icon: 'warning'
    });

    return false;
}

/** Nilai pecahan (ValasChangeNumber) dari valas yang dipilih */
function nilaiPecahan(idxValas) {
    if (!idxValas) { return 0; }

    for (var i = 0; i < ddValasOption.length; i++) {
        if (String(ddValasOption[i].id) === String(idxValas)) {
            return parseFloat(ddValasOption[i].angka) || 0;
        }
    }

    return 0;
}

function recalcAll() {
    $('#tbody-detail tr').each(function () { recalcRow($(this)); });
    recalcGrandTotal();
}

function recalcGrandTotal() {
    var grand = 0;
    $('#tbody-detail tr').each(function () {
        grand += parseFloat(cleanNumber($(this).find('.inp-total').val())) || 0;
    });
    $('#td-grand-total').text('IDR ' + formatNumber(grand, 2));
}

function renumberRows() {
    $('#tbody-detail tr').each(function (idx) {
        $(this).find('.td-nomor').text(idx + 1);
    });
}

function serializeDetail() {
    var rows = [];
    $('#tbody-detail tr').each(function () {
        var $r = $(this);
        var idxValas = parseInt($r.find('.inp-valas').val()) || 0;
        if (!idxValas) return; // skip baris kosong

        rows.push({
            idx_t_salesorderdetail: parseInt($r.data('detail-id')) || 0,
            idx_m_valas:            idxValas,
            idx_m_transactiontype:  parseInt($r.find('.inp-txtype').val()) || 2,
            quantity:               parseFloat(cleanNumber($r.find('.inp-qty').val()))      || 0,
            // Nilainya hasil hitung, bukan ketikan; server tetap menghitung ulang
            foreign_amount:         parseFloat(cleanNumber($r.find('.inp-foreign').val())) || 0,
            exchange_rate:          parseFloat(cleanNumber($r.find('.inp-rate').val()))    || 0,
            detail_notes:           $r.find('.inp-notes').val() || ''
        });
    });
    $('#detail_json').val(JSON.stringify(rows));
}

// =========================================================
// PEMBAYARAN
// =========================================================
function buildAkunOptions(selected) {
    var html = '';
    Object.keys(ddAkun).forEach(function (key) {
        var sel = (String(selected) === String(key)) ? ' selected' : '';
        html += '<option value="' + key + '"' + sel + '>' + escapeHtml(ddAkun[key]) + '</option>';
    });
    return html;
}

function appendPaymentRow(row) {
    var idxAkun = row.idx_akun || '';
    var jumlah  = parseFloat(row.jumlah) || 0;

    var html = '<tr>' +
        '<td><select class="form-control form-control-sm inp-akun">' + buildAkunOptions(idxAkun) + '</select></td>' +
        '<td><input type="text" class="form-control form-control-sm text-end inp-money inp-bayar" inputmode="decimal" data-decimal="2" value="' +
            (jumlah ? formatNumber(jumlah, 2) : '') + '" placeholder="0.00"></td>' +
        '<td class="text-center">' +
            '<button type="button" class="btn btn-sm btn-outline-danger btn-del-payment"><i class="fas fa-trash"></i></button>' +
        '</td>' +
    '</tr>';

    $('#tbody-payment').append(html);
    recalcPayment();
}

function totalTransaksi() {
    var total = 0;
    $('#tbody-detail tr').each(function () {
        total += parseFloat(cleanNumber($(this).find('.inp-total').val())) || 0;
    });
    return total;
}

function totalPembayaran() {
    var total = 0;
    $('#tbody-payment tr').each(function () {
        total += parseFloat(cleanNumber($(this).find('.inp-bayar').val())) || 0;
    });
    return total;
}

function recalcPayment() {
    var bayar = totalPembayaran();
    var nilai = totalTransaksi();
    var selisih = bayar - nilai;

    $('#td-total-payment').text(formatNumber(bayar, 2));

    var $info = $('#info-payment');
    if (!$info.length) return;

    if (nilai === 0) {
        $info.attr('class', 'alert alert-label-info mb-0')
             .html('Total pembayaran harus sama dengan nilai transaksi.');
    } else if (Math.abs(selisih) <= 0.01) {
        $info.attr('class', 'alert alert-label-success mb-0')
             .html('Pembayaran sudah pas dengan nilai transaksi <b>' + formatNumber(nilai, 2) + '</b>.');
    } else if (selisih < 0) {
        $info.attr('class', 'alert alert-label-warning mb-0')
             .html('Kurang <b>' + formatNumber(Math.abs(selisih), 2) + '</b> dari nilai transaksi <b>' +
                   formatNumber(nilai, 2) + '</b>.');
    } else {
        $info.attr('class', 'alert alert-label-danger mb-0')
             .html('Lebih <b>' + formatNumber(selisih, 2) + '</b> dari nilai transaksi <b>' +
                   formatNumber(nilai, 2) + '</b>.');
    }
}

function serializePayment() {
    var rows = [];
    $('#tbody-payment tr').each(function () {
        var $r = $(this);
        var idxAkun = parseInt($r.find('.inp-akun').val()) || 0;
        var jumlah  = parseFloat(cleanNumber($r.find('.inp-bayar').val())) || 0;

        if (!idxAkun || jumlah <= 0) return; // baris kosong dilewati

        rows.push({ idx_m_financialaccount: idxAkun, amount: jumlah });
    });
    $('#payment_json').val(JSON.stringify(rows));
}

function cleanNumber(val) {
    return val ? val.toString().replace(/,/g, '') : '0';
}

function formatNumber(num, digits) {
    digits = (typeof digits === 'number') ? digits : 2;
    return parseFloat(num || 0).toLocaleString('en-US', {
        minimumFractionDigits: digits,
        maximumFractionDigits: digits
    });
}

function escapeHtml(str) {
    return String(str)
        .replace(/&/g,  '&amp;')
        .replace(/"/g,  '&quot;')
        .replace(/'/g, '&#39;')
        .replace(/</g,  '&lt;')
        .replace(/>/g,  '&gt;');
}
</script>
@endsection
