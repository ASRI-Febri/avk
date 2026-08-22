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
        Isi data wajib berikut. Kelengkapan lain seperti NPWP bisa dilengkapi
        belakangan lewat menu <b>Business Partner</b>.
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
                placeholder="16 digit NIK, atau nomor paspor" maxlength="64" autocomplete="off">
            <div class="form-text" id="qp-nik-info">
                NIK harus 16 digit angka. NIK yang sudah terdaftar dipakai ulang, bukan dibuat kembar.
            </div>
        </div>

        <div class="col-md-6">
            <label class="form-label text-secondary">No Handphone <span class="text-danger">*</span></label>
            <input type="text" id="qp-MobilePhone" class="form-control"
                placeholder="08xxxxxxxxxx" maxlength="50" inputmode="tel" autocomplete="off">
        </div>

        <div class="col-md-6">
            <label class="form-label text-secondary">Tempat Lahir</label>
            <input type="text" id="qp-PlaceOfBirth" class="form-control"
                placeholder="Tempat lahir sesuai KTP" maxlength="100" autocomplete="off">
        </div>

        <div class="col-md-6">
            <label class="form-label text-secondary">Tanggal Lahir</label>
            <input type="text" id="qp-DateOfBirth" class="form-control"
                placeholder="YYYY-MM-DD" maxlength="10" autocomplete="off">
            <div class="form-text">Format YYYY-MM-DD, mis. 1990-05-17.</div>
        </div>

        <div class="col-md-8">
            <label class="form-label text-secondary">Alamat <span class="text-danger">*</span></label>
            <textarea id="qp-Street" class="form-control" rows="2"
                placeholder="Alamat sesuai KTP" maxlength="1024"></textarea>
        </div>

        <div class="col-md-12">
            <label class="form-label text-secondary">Foto KTP</label>
            <input type="file" id="qp-KTPFile" class="form-control"
                accept="image/jpeg,image/png,image/webp">
            <div class="form-text">
                Opsional. jpg, jpeg, png, atau webp; maksimal 5 MB.
                Diunggah otomatis sesudah konsumen tersimpan.
            </div>
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

    // Datepicker dipasang di sini karena isi modal baru ada sesudah init global
    $('#qp-DateOfBirth').datepicker({
        todayHighlight: true,
        changeMonth:    true,
        changeYear:     true,
        yearRange:      '1900:+0',
        format:         'yyyy-mm-dd',
        autoclose:      true,
        container:      '#div-form-modal'
    });

    function tampilkanPesan(html) {
        $pesan.html(html).removeClass('d-none');
    }

    // Foto KTP baru bisa diunggah sesudah konsumennya punya IDX, jadi dikirim
    // menyusul begitu penyimpanan berhasil. Kegagalan di sini tidak membatalkan
    // konsumennya: transaksi tetap bisa jalan, fotonya dilengkapi belakangan.
    function unggahKtp(hasil, selesai) {
        var berkas = $('#qp-KTPFile')[0].files[0];

        if (!berkas) {
            selesai('');
            return;
        }

        var data = new FormData();
        data.append('_token', $('#_token').val());
        data.append('IDX_M_Partner', hasil.idx);
        data.append('KTPFile', berkas);

        // Konsumen lama: foto yang sudah ada jangan ditimpa dari layar transaksi
        if (hasil.sudah_ada) {
            data.append('SkipIfExists', '1');
        }

        $.ajax({
            url: '{{ $url_ktp_upload }}',
            type: 'POST',
            data: data,
            processData: false,
            contentType: false
        }).done(function (ktp) {
            if (ktp.flag === 'success') {
                selesai('<br><small>Foto KTP tersimpan.</small>');
            } else {
                selesai('<br><small class="text-danger">Foto KTP tidak tersimpan: ' + ktp.message + '</small>');
            }
        }).fail(function () {
            selesai('<br><small class="text-danger">Foto KTP gagal diunggah. '
                + 'Silakan upload lewat menu Business Partner.</small>');
        });
    }

    function simpan() {
        $pesan.addClass('d-none').empty();
        $tombol.prop('disabled', true).html('<i class="fas fa-spinner fa-spin me-1"></i> Menyimpan...');

        $.post('{{ $url_save }}', {
            _token:               $('#_token').val(),
            PartnerName:          $('#qp-PartnerName').val(),
            SingleIdentityNumber: $('#qp-SingleIdentityNumber').val(),
            MobilePhone:          $('#qp-MobilePhone').val(),
            PlaceOfBirth:         $('#qp-PlaceOfBirth').val(),
            DateOfBirth:          $('#qp-DateOfBirth').val(),
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

            unggahKtp(hasil, function (pesan_ktp) {
                Swal.fire({
                    title: hasil.sudah_ada ? 'Konsumen sudah terdaftar' : 'Konsumen ditambahkan',
                    html:  hasil.message + pesan_ktp,
                    icon:  hasil.sudah_ada ? 'info' : 'success',
                    timer: (hasil.sudah_ada || pesan_ktp !== '') ? undefined : 1800,
                    showConfirmButton: hasil.sudah_ada || pesan_ktp !== ''
                });
            });
        }).fail(function () {
            tampilkanPesan('Data gagal disimpan. Coba ulangi, atau daftarkan lewat menu Business Partner.');
            $tombol.prop('disabled', false).html('<i class="fas fa-save me-1"></i> Simpan &amp; Pakai');
        });
    }

    // Hitungan digit tampil sambil mengetik: salah ketik NIK paling sering
    // ketahuan dari jumlah digitnya, jauh sebelum tombol simpan ditekan.
    $('#qp-SingleIdentityNumber').on('input', function () {
        var isi   = $.trim(this.value);
        var angka = /^[0-9]+$/.test(isi);
        var $info = $('#qp-nik-info');

        if (isi === '') {
            $(this).removeClass('is-invalid is-valid');
            $info.removeClass('text-danger').html(
                'NIK harus 16 digit angka. NIK yang sudah terdaftar dipakai ulang, bukan dibuat kembar.');
            return;
        }

        if (angka && isi.length !== 16) {
            $(this).addClass('is-invalid').removeClass('is-valid');
            $info.addClass('text-danger').text('Baru ' + isi.length + ' dari 16 digit.');
            return;
        }

        $(this).removeClass('is-invalid').addClass('is-valid');
        $info.removeClass('text-danger').text(angka ? 'NIK lengkap 16 digit.' : 'Diperlakukan sebagai nomor paspor.');
    });

    $tombol.on('click', simpan);

    // Enter di kolom mana pun ikut menyimpan, kecuali di alamat yang butuh baris baru
    $('#qp-PartnerName, #qp-SingleIdentityNumber, #qp-MobilePhone, #qp-PlaceOfBirth, #qp-DateOfBirth, #qp-Zip').on('keydown', function (e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            simpan();
        }
    });
});
</script>
