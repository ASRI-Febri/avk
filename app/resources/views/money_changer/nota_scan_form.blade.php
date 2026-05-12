@extends('layouts.master-form-transaction')

@section('active_link')
    $('#nav-transaction').addClass('mm-active');
    $('#nav-ul-transaction').addClass('mm-show');
    $('#nav-li-nota-scan').addClass('mm-active');
@endsection

@section('form-remark')
    Upload foto / scan nota transaksi jual beli valuta asing. Gambar akan diproses OCR secara otomatis.
    Periksa dan koreksi hasil OCR sebelum disimpan.
    <br>
    Format: <code>JPG, PNG, WebP</code> &nbsp;|&nbsp; Maks: <code>10 MB</code>
@endsection

@section('content-form')

    <!-- HIDDEN FIELDS -->
    <input type="hidden" id="IDX_T_MC_NotaScan" name="IDX_T_MC_NotaScan"
        value="{{ $fields->IDX_T_MC_NotaScan ?? 0 }}"/>
    <input type="hidden" id="FileName"    name="FileName"    value="{{ $fields->FileName    ?? '' }}"/>
    <input type="hidden" id="FilePath"    name="FilePath"    value="{{ $fields->FilePath    ?? '' }}"/>
    <input type="hidden" id="OCRRawText"  name="OCRRawText"  value="{{ $fields->OCRRawText  ?? '' }}"/>
    <input type="hidden" id="detail_json" name="detail_json" value="[]"/>

    {{-- =========================================================
         BAGIAN 1 : Upload & Proses OCR
    ========================================================= --}}
    <div class="card border mb-3">
        <div class="card-header card-header-bordered">
            <h3 class="card-title">
                <i class="fas fa-camera me-2"></i> Upload Gambar Nota
            </h3>
        </div>
        <div class="card-body">
            <div class="row g-3 align-items-end">
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Pilih File Gambar <span class="text-danger">*</span></label>
                    <input id="ScanFile" name="ScanFile" type="file"
                        class="form-control" accept=".jpg,.jpeg,.png,.gif,.webp" />
                    <div class="form-text text-muted">JPG / PNG / WebP, maks 10 MB</div>
                </div>
                <div class="col-md-3">
                    <button type="button" class="btn btn-warning w-100" id="btn-scan">
                        <i class="fas fa-magic me-2"></i> Proses OCR
                    </button>
                </div>
            </div>

            <div id="div-img-preview" class="mt-3" style="display:none;">
                <img id="img-preview" src="" alt="Preview Nota"
                    style="max-height:300px; max-width:100%; border:1px solid #ddd; border-radius:6px;"/>
            </div>

            <div id="div-ocr-spinner" class="mt-3 text-center" style="display:none;">
                <div class="spinner-border text-warning" role="status"></div>
                <p class="text-muted mt-2">Memproses OCR, mohon tunggu...</p>
            </div>
        </div>
    </div>

    {{-- =========================================================
         BAGIAN 2 : Header Transaksi (2 kolom)
    ========================================================= --}}
    <div class="row g-3 mb-3">

        {{-- Kolom Kiri: Informasi Nota --}}
        <div class="col-md-6">
            <div class="card border h-100">
                <div class="card-header card-header-bordered">
                    <h3 class="card-title"><i class="fas fa-file-invoice me-2"></i> Informasi Nota</h3>
                </div>
                <div class="card-body">
                    <div class="d-grid gap-3">
                        <x-select-horizontal label="Jenis Transaksi"
                            id="TipeTransaksi"
                            :value="$fields->TipeTransaksi ?? ''"
                            class="required"
                            :array="$dd_tipe" />

                        <x-textbox-horizontal label="Tanggal"
                            id="TanggalNota"
                            :value="$fields->TanggalNota ?? date('Y-m-d')"
                            class="required datepicker2" />

                        <x-textbox-horizontal label="No. Kwitansi"
                            id="NoNota"
                            :value="$fields->NoNota ?? ''"
                            placeholder="Contoh: A-7800345" />

                        <x-textbox-horizontal label="Keterangan"
                            id="Keterangan"
                            :value="$fields->Keterangan ?? ''"
                            placeholder="Catatan umum" />
                    </div>
                </div>
            </div>
        </div>

        {{-- Kolom Kanan: Data Konsumen (sesuai regulasi BI) --}}
        <div class="col-md-6">
            <div class="card border h-100">
                <div class="card-header card-header-bordered">
                    <h3 class="card-title"><i class="fas fa-user me-2"></i> Data Konsumen</h3>
                </div>
                <div class="card-body">
                    <div class="d-grid gap-3">
                        <x-textbox-horizontal label="Nama"
                            id="NamaKonsumen"
                            :value="$fields->NamaKonsumen ?? ''"
                            placeholder="Nama pembeli / penjual" />

                        <x-textbox-horizontal label="No. KTP / Identitas"
                            id="NoKTP"
                            :value="$fields->NoKTP ?? ''"
                            placeholder="No identitas konsumen" />

                        <x-textbox-horizontal label="No. Telp"
                            id="NoTelp"
                            :value="$fields->NoTelp ?? ''"
                            placeholder="No telepon konsumen" />

                        <x-textbox-horizontal label="Sumber Dana"
                            id="SumberDana"
                            :value="$fields->SumberDana ?? ''"
                            placeholder="Misal: Tabungan pribadi" />

                        <x-textbox-horizontal label="Tujuan Transaksi"
                            id="TujuanTransaksi"
                            :value="$fields->TujuanTransaksi ?? ''"
                            placeholder="Misal: Kebutuhan perjalanan" />
                    </div>
                </div>
            </div>
        </div>

    </div>

    {{-- Hasil OCR Raw --}}
    <div class="card border mb-3">
        <div class="card-header card-header-bordered">
            <h3 class="card-title"><i class="fas fa-robot me-2"></i> Teks OCR Mentah</h3>
        </div>
        <div class="card-body">
            <textarea id="ocr-raw-display" class="form-control font-monospace"
                rows="4" readonly
                placeholder="Teks hasil OCR akan tampil di sini setelah proses...">{{ $fields->OCRRawText ?? '' }}</textarea>
        </div>
    </div>

    <div class="row mb-3">
        <div class="col-12">
            @include('form_helper.btn_save_header')
        </div>
    </div>

    {{-- =========================================================
         BAGIAN 3 : Tabel Detail Transaksi
    ========================================================= --}}
    <div class="card border">
        <div class="card-header card-header-bordered">
            <h3 class="card-title">
                <i class="fas fa-table me-2"></i> Detail Transaksi Valas
            </h3>
            <div class="card-addon">
                <button type="button" class="btn btn-sm btn-outline-primary" id="btn-add-row">
                    <i class="fas fa-plus me-1"></i> Tambah Baris
                </button>
            </div>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-bordered table-hover mb-0" id="tbl-detail">
                    <thead class="table-light">
                        <tr>
                            <th style="width:45px;" class="text-center">No</th>
                            <th style="width:160px;">Keterangan Valas</th>
                            <th style="width:140px;" class="text-end">Nilai Valas</th>
                            <th style="width:140px;" class="text-end">Nilai Tukar</th>
                            <th style="width:160px;" class="text-end">Total Nilai (IDR)</th>
                            <th style="width:160px;">Catatan</th>
                            <th style="width:55px;" class="text-center">Hapus</th>
                        </tr>
                    </thead>
                    <tbody id="tbody-detail">
                        {{-- Diisi via JavaScript --}}
                    </tbody>
                    <tfoot>
                        <tr class="table-light fw-bold">
                            <td colspan="4" class="text-end pe-3">TOTAL</td>
                            <td class="text-end" id="td-grand-total">IDR 0</td>
                            <td colspan="2"></td>
                        </tr>
                    </tfoot>
                </table>
            </div>
        </div>
    </div>

@endsection

@section('script')
<script>
$(document).ready(function () {

    // -------------------------------------------------------
    // Inisialisasi baris dari server (mode update)
    // -------------------------------------------------------
    var existingRows = @json($records_detail ?? []);
    if (existingRows.length > 0) {
        existingRows.forEach(function (row, idx) {
            appendDetailRow({
                nomor:            idx + 1,
                keterangan_valas: row.KeteranganValas  || '',
                nilai_valas:      parseFloat(row.NilaiValas)  || 0,
                nilai_tukar:      parseFloat(row.NilaiTukar)  || 0,
                total_nilai:      parseFloat(row.TotalNilai)  || 0,
                catatan_detail:   row.CatatanDetail || '',
            });
        });
        recalcTotal();
        serializeDetail();
    }

    // -------------------------------------------------------
    // Preview gambar saat file dipilih
    // -------------------------------------------------------
    $('#ScanFile').on('change', function () {
        var file = this.files[0];
        if (!file) return;
        var reader = new FileReader();
        reader.onload = function (e) {
            $('#img-preview').attr('src', e.target.result);
            $('#div-img-preview').show();
        };
        reader.readAsDataURL(file);
    });

    // -------------------------------------------------------
    // Tombol Proses OCR
    // -------------------------------------------------------
    $('#btn-scan').on('click', function () {
        var file = $('#ScanFile')[0].files[0];
        if (!file) {
            showAlert('error', 'Pilih file gambar terlebih dahulu.');
            return;
        }

        var formData = new FormData();
        formData.append('_token',   $('#_token').val());
        formData.append('ScanFile', file);

        $('#btn-scan').prop('disabled', true);
        $('#div-ocr-spinner').show();

        $.ajax({
            url:         "{{ url('mc-nota-scan/scan') }}",
            type:        'POST',
            data:        formData,
            processData: false,
            contentType: false,
            success: function (resp) {
                $('#btn-scan').prop('disabled', false);
                $('#div-ocr-spinner').hide();

                if (resp.flag === 'error') {
                    showAlert('error', resp.message);
                    return;
                }

                var d = resp.data;

                // Hidden file fields
                $('#FileName').val(resp.file_name || '');
                $('#FilePath').val(resp.file_path || '');
                $('#OCRRawText').val(resp.raw || '');
                $('#ocr-raw-display').val(resp.raw || '');

                // Header
                if (d.tipe_transaksi) $('#TipeTransaksi').val(d.tipe_transaksi);
                if (d.tanggal_nota)   $('#TanggalNota').val(d.tanggal_nota);
                if (d.no_nota)        $('#NoNota').val(d.no_nota);
                if (d.nama_konsumen)  $('#NamaKonsumen').val(d.nama_konsumen);
                if (d.no_ktp)         $('#NoKTP').val(d.no_ktp);
                if (d.no_telp)        $('#NoTelp').val(d.no_telp);
                if (d.sumber_dana)    $('#SumberDana').val(d.sumber_dana);
                if (d.tujuan_transaksi) $('#TujuanTransaksi').val(d.tujuan_transaksi);
                if (d.keterangan)     $('#Keterangan').val(d.keterangan);

                // Render tabel detail
                $('#tbody-detail').empty();
                if (d.detail && d.detail.length > 0) {
                    d.detail.forEach(function (row) { appendDetailRow(row); });
                }

                recalcTotal();
                serializeDetail();

                showAlert('success', 'OCR berhasil. Periksa dan koreksi data sebelum disimpan.');
            },
            error: function () {
                $('#btn-scan').prop('disabled', false);
                $('#div-ocr-spinner').hide();
                showAlert('error', 'Terjadi kesalahan saat menghubungi server OCR.');
            }
        });
    });

    // -------------------------------------------------------
    // Tambah baris manual
    // -------------------------------------------------------
    $('#btn-add-row').on('click', function () {
        appendDetailRow({
            nomor:            $('#tbody-detail tr').length + 1,
            keterangan_valas: '',
            nilai_valas:      0,
            nilai_tukar:      0,
            total_nilai:      0,
            catatan_detail:   '',
        });
        recalcTotal();
        serializeDetail();
    });

    // -------------------------------------------------------
    // Auto-hitung total per baris
    // -------------------------------------------------------
    $(document).on('input', '.inp-nilai-valas, .inp-nilai-tukar', function () {
        var $row   = $(this).closest('tr');
        var valas  = parseFloat(cleanNumber($row.find('.inp-nilai-valas').val())) || 0;
        var tukar  = parseFloat(cleanNumber($row.find('.inp-nilai-tukar').val())) || 0;
        $row.find('.inp-total').val(formatNumber(valas * tukar));
        recalcTotal();
        serializeDetail();
    });

    $(document).on('input', '.inp-keterangan, .inp-catatan, .inp-total', function () {
        serializeDetail();
    });

    // -------------------------------------------------------
    // Hapus baris
    // -------------------------------------------------------
    $(document).on('click', '.btn-del-row', function () {
        $(this).closest('tr').remove();
        renumberRows();
        recalcTotal();
        serializeDetail();
    });

    // Serialisasi sebelum save
    $('#btn-save-header').on('click', function () {
        serializeDetail();
    });

});

// -------------------------------------------------------
// HELPERS
// -------------------------------------------------------

function appendDetailRow(row) {
    var nomor  = row.nomor            || ($('#tbody-detail tr').length + 1);
    var ket    = row.keterangan_valas || '';
    var valas  = parseFloat(row.nilai_valas) || 0;
    var tukar  = parseFloat(row.nilai_tukar) || 0;
    var total  = parseFloat(row.total_nilai) || 0;
    var catatan = row.catatan_detail  || '';

    if (total === 0 && valas > 0 && tukar > 0) total = valas * tukar;

    $('#tbody-detail').append(
        '<tr>' +
        '<td class="text-center align-middle td-nomor">' + nomor + '</td>' +
        '<td><input type="text" class="form-control form-control-sm inp-keterangan"' +
            ' value="' + escapeHtml(ket) + '" placeholder="PHP, USD, EUR..."/></td>' +
        '<td><input type="text" class="form-control form-control-sm text-end inp-nilai-valas"' +
            ' value="' + formatNumber(valas) + '" placeholder="0"/></td>' +
        '<td><input type="text" class="form-control form-control-sm text-end inp-nilai-tukar"' +
            ' value="' + formatNumber(tukar) + '" placeholder="0"/></td>' +
        '<td><input type="text" class="form-control form-control-sm text-end inp-total"' +
            ' value="' + formatNumber(total) + '" readonly/></td>' +
        '<td><input type="text" class="form-control form-control-sm inp-catatan"' +
            ' value="' + escapeHtml(catatan) + '" placeholder="Order, tunai..."/></td>' +
        '<td class="text-center align-middle">' +
            '<button type="button" class="btn btn-sm btn-outline-danger btn-del-row">' +
                '<i class="fas fa-trash"></i>' +
            '</button>' +
        '</td>' +
        '</tr>'
    );
}

function renumberRows() {
    $('#tbody-detail tr').each(function (idx) {
        $(this).find('.td-nomor').text(idx + 1);
    });
}

function recalcTotal() {
    var grand = 0;
    $('#tbody-detail tr').each(function () {
        grand += parseFloat(cleanNumber($(this).find('.inp-total').val())) || 0;
    });
    $('#td-grand-total').text('IDR ' + formatNumber(grand));
}

function serializeDetail() {
    var rows = [];
    var nomor = 1;
    $('#tbody-detail tr').each(function () {
        rows.push({
            nomor:            nomor++,
            keterangan_valas: $(this).find('.inp-keterangan').val().trim(),
            nilai_valas:      parseFloat(cleanNumber($(this).find('.inp-nilai-valas').val())) || 0,
            nilai_tukar:      parseFloat(cleanNumber($(this).find('.inp-nilai-tukar').val())) || 0,
            total_nilai:      parseFloat(cleanNumber($(this).find('.inp-total').val()))       || 0,
            catatan_detail:   $(this).find('.inp-catatan').val().trim(),
        });
    });
    $('#detail_json').val(JSON.stringify(rows));
}

function cleanNumber(val) {
    return val ? val.toString().replace(/,/g, '') : '0';
}

function formatNumber(num) {
    return parseFloat(num || 0).toLocaleString('en-US', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 4
    });
}

function escapeHtml(str) {
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/"/g, '&quot;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;');
}

function showAlert(type, message) {
    Swal.fire({
        icon:              type,
        html:              message,
        confirmButtonText: '<i class="fas fa-times-circle"></i> Tutup',
        confirmButtonClass:'btn btn-' + (type === 'success' ? 'success' : 'danger'),
    });
}
</script>
@endsection
