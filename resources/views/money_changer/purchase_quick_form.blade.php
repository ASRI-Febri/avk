@extends('layouts.master-form-transaction')

@section('active_link')
    $('#nav-transaction').addClass('mm-active');
    $('#nav-ul-transaction').addClass('mm-show');
    $('#nav-li-input-po-quick').addClass('mm-active');
@endsection

@section('form-remark')
    Input cepat transaksi pembelian valuta asing. Isi informasi umum dan detail valas dalam satu form,
    lalu klik <b>Simpan</b>.
@endsection

@section('content-form')

    {{-- HIDDEN FIELDS --}}
    <input type="hidden" id="IDX_T_PurchaseOrder" name="IDX_T_PurchaseOrder" value="{{ $fields->IDX_T_PurchaseOrder }}"/>
    <input type="hidden" id="IDX_M_Company"       name="IDX_M_Company"       value="{{ $fields->IDX_M_Company }}"/>
    <input type="hidden" id="IDX_M_Branch"        name="IDX_M_Branch"        value="{{ $fields->IDX_M_Branch }}"/>
    <input type="hidden" id="IDX_M_Partner"       name="IDX_M_Partner"       value="{{ $fields->IDX_M_Partner }}"/>
    <input type="hidden" id="POStatus"            name="POStatus"            value="{{ $fields->POStatus }}"/>
    <input type="hidden" id="PONumber"            name="PONumber"            value="{{ $fields->PONumber }}"/>
    <input type="hidden" id="detail_json"         name="detail_json"         value="[]"/>
    <input type="hidden" id="deleted_ids_json"    name="deleted_ids_json"    value="[]"/>

    @if($state !== 'create')
        <h5 class="text-secondary mb-3">
            {{ $fields->PONumber }} <span class="text-muted">— {{ $fields->StatusDesc ?? '' }}</span>
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
                    <label class="form-label text-secondary">No Nota <span class="text-danger">*</span></label>
                    <input type="text" id="ReferenceNo" name="ReferenceNo"
                        class="form-control required" placeholder="No nota fisik"
                        value="{{ $fields->ReferenceNo }}">
                </div>

                <div class="col-md-3">
                    <label class="form-label text-secondary">Tanggal <span class="text-danger">*</span></label>
                    <input type="text" id="PODate" name="PODate"
                        class="form-control required datepicker2"
                        placeholder="YYYY-MM-DD"
                        value="{{ $fields->PODate }}">
                </div>

                <div class="col-md-6">
                    <label class="form-label text-secondary">Supplier <span class="text-danger">*</span></label>
                    <div class="input-group">
                        <input type="text" id="PartnerDesc" name="PartnerDesc"
                            class="form-control required" placeholder="Pilih supplier..."
                            value="{{ $fields->PartnerDesc }}" readonly>
                        <button type="button" class="btn btn-outline-primary" id="btn-find-partner">
                            <i class="fas fa-search"></i> Cari
                        </button>
                    </div>
                </div>

                <div class="col-md-12">
                    <label class="form-label text-secondary">Keterangan <span class="text-danger">*</span></label>
                    <input type="text" id="PONotes" name="PONotes"
                        class="form-control required"
                        placeholder="Keterangan transaksi"
                        value="{{ $fields->PONotes }}">
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
                            <th style="width:130px;" class="text-end">Jumlah Valas <span class="text-danger">*</span></th>
                            <th style="width:130px;" class="text-end">Nilai Tukar <span class="text-danger">*</span></th>
                            <th style="width:100px;" class="text-end">Qty</th>
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
                            <td colspan="5" class="text-end pe-3">TOTAL</td>
                            <td class="text-end" id="td-grand-total">IDR 0</td>
                            <td colspan="2"></td>
                        </tr>
                    </tfoot>
                </table>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-12">
            @include('form_helper.btn_save_header')
            <a href="{{ url('mc-purchase-order') }}" class="btn btn-outline-secondary">
                <i class="fas fa-times"></i> Batal
            </a>
        </div>
    </div>

@endsection

@section('script')
<script>
var ddValas     = @json($dd_valas);
var existingRow = @json($records_detail ?? []);

$(document).ready(function () {

    // ---------- Lookup Supplier ----------
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
                idx_t_purchaseorderdetail: row.IDX_T_PurchaseOrderDetail || 0,
                idx_m_valas:               row.IDX_M_Valas || '',
                quantity:                  parseFloat(row.Quantity)      || 0,
                foreign_amount:            parseFloat(row.ForeignAmount) || 0,
                exchange_rate:             parseFloat(row.ExchangeRate)  || 0,
                detail_notes:              row.DetailNotes || ''
            });
        });
    } else {
        appendDetailRow({}); // 1 baris kosong default
    }

    recalcAll();
    serializeDetail();

    // ---------- Tambah baris ----------
    $('#btn-add-row').on('click', function () {
        appendDetailRow({});
        serializeDetail();
    });

    // ---------- Hitung ulang baris saat input berubah ----------
    $(document).on('input change', '.inp-valas, .inp-foreign, .inp-rate, .inp-qty, .inp-notes', function () {
        var $row = $(this).closest('tr');
        recalcRow($row);
        recalcGrandTotal();
        serializeDetail();
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
        serializeDetail();
    });

    // ---------- Serialize sebelum save ----------
    $('#btn-save-header').on('click', function () {
        serializeDetail();
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

function appendDetailRow(row) {
    var idxDetail = row.idx_t_purchaseorderdetail || 0;
    var idxValas  = row.idx_m_valas               || '';
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
                    buildValasOptions(idxValas) +
                '</select>' +
            '</td>' +
            '<td><input type="text" class="form-control form-control-sm text-end inp-foreign" ' +
                'value="' + formatNumber(foreign, 2) + '" placeholder="0"></td>' +
            '<td><input type="text" class="form-control form-control-sm text-end inp-rate" ' +
                'value="' + formatNumber(rate, 4) + '" placeholder="0"></td>' +
            '<td><input type="text" class="form-control form-control-sm text-end inp-qty" ' +
                'value="' + formatNumber(qty, 2) + '" placeholder="0"></td>' +
            '<td><input type="text" class="form-control form-control-sm text-end inp-total" ' +
                'value="' + formatNumber(total, 2) + '" readonly></td>' +
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
}

function recalcRow($row) {
    var foreign = parseFloat(cleanNumber($row.find('.inp-foreign').val())) || 0;
    var rate    = parseFloat(cleanNumber($row.find('.inp-rate').val()))    || 0;
    $row.find('.inp-total').val(formatNumber(foreign * rate, 2));
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
            idx_t_purchaseorderdetail: parseInt($r.data('detail-id')) || 0,
            idx_m_valas:               idxValas,
            quantity:                  parseFloat(cleanNumber($r.find('.inp-qty').val()))      || 0,
            foreign_amount:            parseFloat(cleanNumber($r.find('.inp-foreign').val())) || 0,
            exchange_rate:             parseFloat(cleanNumber($r.find('.inp-rate').val()))    || 0,
            detail_notes:              $r.find('.inp-notes').val() || ''
        });
    });
    $('#detail_json').val(JSON.stringify(rows));
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
