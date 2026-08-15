{{--
    Modal input cepat konsumen.

    Dibuka dari form input cepat penjualan/pembelian valas, isinya hanya data
    wajib supaya kasir tidak berpindah menu di tengah transaksi. Setelah simpan,
    konsumen yang baru langsung terpasang di form transaksi lewat getSelected()
    yang sudah dipakai modal pencarian konsumen.
--}}

<div class="modal-header">
    <h5 class="modal-title"><i class="fas fa-user-plus me-2"></i>{{ $form_desc }}</h5>

    <div class="card-addon">
        <button type="button" class="btn btn-danger" data-bs-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
        </button>
    </div>
</div>

<div class="modal-body">
    <p class="text-muted small mb-3">
        Isi data wajib berikut. Kelengkapan lain seperti tempat/tanggal lahir dan NPWP
        bisa dilengkapi belakangan lewat menu <b>Business Partner</b>.
    </p>

    <div class="row g-3">
        <div class="col-md-12">
            <label class="form-label text-secondary">Nama Konsumen <span class="text-danger">*</span></label>
            <input type="text" id="qp-PartnerName" class="form-control"
                placeholder="Nama sesuai KTP" maxlength="150" autocomplete="off">
        </div>

        <div class="col-md-6">
            <label class="form-label text-secondary">NIK <span class="text-danger">*</span></label>
            <input type="text" id="qp-SingleIdentityNumber" class="form-control"
                placeholder="16 digit NIK" maxlength="64" inputmode="numeric" autocomplete="off">
            <div class="form-text">NIK yang sudah terdaftar akan dipakai ulang, bukan dibuat kembar.</div>
        </div>

        <div class="col-md-6">
            <label class="form-label text-secondary">No Handphone <span class="text-danger">*</span></label>
            <input type="text" id="qp-MobilePhone" class="form-control"
                placeholder="08xxxxxxxxxx" maxlength="50" inputmode="tel" autocomplete="off">
        </div>

        <div class="col-md-8">
            <label class="form-label text-secondary">Alamat <span class="text-danger">*</span></label>
            <textarea id="qp-Street" class="form-control" rows="2"
                placeholder="Alamat sesuai KTP" maxlength="1024"></textarea>
        </div>

        <div class="col-md-4">
            <label class="form-label text-secondary">Kode Pos</label>
            <input type="text" id="qp-Zip" class="form-control"
                placeholder="Opsional" maxlength="32" inputmode="numeric" autocomplete="off">
            <div class="form-text">Bila diisi, alamat ikut terhubung ke master kode pos.</div>
        </div>
    </div>

    <div id="qp-pesan" class="alert alert-danger mt-3 mb-0 d-none"></div>
</div>

<div class="modal-footer">
    <button type="button" class="btn btn-danger" data-bs-dismiss="modal">Batal</button>
    <button type="button" class="btn btn-primary" id="qp-simpan">
        <i class="fas fa-save me-1"></i> Simpan &amp; Pakai
    </button>
</div>

<script>
$(function () {
    var $tombol = $('#qp-simpan');
    var $pesan  = $('#qp-pesan');

    $('#qp-PartnerName').focus();

    function tampilkanPesan(html) {
        $pesan.html(html).removeClass('d-none');
    }

    function simpan() {
        $pesan.addClass('d-none').empty();
        $tombol.prop('disabled', true).html('<i class="fas fa-spinner fa-spin me-1"></i> Menyimpan...');

        $.post('{{ $url_save }}', {
            _token:               $('#_token').val(),
            PartnerName:          $('#qp-PartnerName').val(),
            SingleIdentityNumber: $('#qp-SingleIdentityNumber').val(),
            MobilePhone:          $('#qp-MobilePhone').val(),
            Street:               $('#qp-Street').val(),
            Zip:                  $('#qp-Zip').val()
        }).done(function (hasil) {
            if (hasil.flag !== 'success') {
                tampilkanPesan(hasil.message);
                $tombol.prop('disabled', false).html('<i class="fas fa-save me-1"></i> Simpan &amp; Pakai');
                return;
            }

            // Pasang ke form transaksi memakai jalur yang sama dengan pencarian
            @if($target_index !== '')
                $('#{{ $target_index }}').val(hasil.idx);
            @endif
            @if($target_name !== '')
                $('#{{ $target_name }}').val(hasil.partner_id + ' - ' + hasil.partner_name);
            @endif

            $('#div-form-modal').modal('hide');

            Swal.fire({
                title: hasil.sudah_ada ? 'Konsumen sudah terdaftar' : 'Konsumen ditambahkan',
                html:  hasil.message,
                icon:  hasil.sudah_ada ? 'info' : 'success',
                timer: hasil.sudah_ada ? undefined : 1800,
                showConfirmButton: hasil.sudah_ada
            });
        }).fail(function () {
            tampilkanPesan('Data gagal disimpan. Coba ulangi, atau daftarkan lewat menu Business Partner.');
            $tombol.prop('disabled', false).html('<i class="fas fa-save me-1"></i> Simpan &amp; Pakai');
        });
    }

    $tombol.on('click', simpan);

    // Enter di kolom mana pun ikut menyimpan, kecuali di alamat yang butuh baris baru
    $('#qp-PartnerName, #qp-SingleIdentityNumber, #qp-MobilePhone, #qp-Zip').on('keydown', function (e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            simpan();
        }
    });
});
</script>
