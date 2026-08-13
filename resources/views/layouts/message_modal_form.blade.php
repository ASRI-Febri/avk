{{-- MODAL PESAN SEDERHANA (tanpa tombol simpan), dipakai untuk menolak aksi
     yang tidak boleh dijalankan, mis. input pembayaran untuk nota yang belum approved --}}
<div class="modal-header">
    <h5 class="modal-title"><i class="icon-table2"></i>{{ $form_desc ?? 'Informasi' }}</h5>

    <div class="card-addon">
        <button type="button" class="btn btn-danger" data-bs-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
        </button>
    </div>
</div>

<div class="modal-body with-padding">
    <div class="card">
        <div class="card-body">
            <h6 class="text-danger">{{ $message_title ?? 'Aksi tidak bisa dilanjutkan' }}</h6>
            <hr>
            <p class="text-secondary">{{ $message_body ?? '' }}</p>
        </div>
    </div>
</div>

<div class="modal-footer">
    <button id="btn-close-modal" type="button" class="btn btn-danger" data-bs-dismiss="modal">
        <i class="fas fa-undo"></i> Close
    </button>
</div>
