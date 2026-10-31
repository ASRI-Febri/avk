{{-- Lampiran transaksi. Pakai: @include('general.attachment_panel', ['attachment_type' => 'FP', 'attachment_id' => $id]) --}}
<div id="div-attachment" data-type="{{ $attachment_type }}" data-id="{{ $attachment_id }}"
     data-url="{{ url('gn-attachment/list') }}">
    <div class="text-center text-muted p-3"><i class="fa fa-spinner fa-spin"></i> Memuat lampiran...</div>
</div>

<div class="modal fade" id="modal-view-attachment-image" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body text-center">
                <img src="" alt="" class="img-fluid" style="max-height: 75vh;">
            </div>
        </div>
    </div>
</div>

<script>
    // jQuery dimuat di akhir halaman, jadi tunggu DOMContentLoaded.
    document.addEventListener('DOMContentLoaded', function () {
        var panel = $('#div-attachment');

        // MODAL DIPINDAH KE BODY AGAR TIDAK TERTUTUP OLEH FORM / TAB
        $('#modal-view-attachment-image').appendTo('body');

        function reload()
        {
            panel.load(panel.data('url') + '?' + $.param({ type: panel.data('type'), id: panel.data('id') }));
        }

        function result(data)
        {
            Swal.fire({ icon: data.flag == 'success' ? 'success' : 'error', title: data.flag == 'success' ? 'Berhasil' : 'Gagal', html: data.message });
            if (data.flag == 'success') {
                reload();
            }
        }

        panel.on('click', '#btn-attachment-upload', function () {
            var files = $('#attachment-files')[0].files;
            if ($('#attachment-category').val() == '' || files.length == 0) {
                Swal.fire({ icon: 'warning', title: 'Belum lengkap', text: 'Pilih kategori dan minimal satu file.' });
                return;
            }

            var form = new FormData();
            form.append('_token', $('#_token').val());
            form.append('SourceType', panel.data('type'));
            form.append('SourceID', panel.data('id'));
            form.append('Category', $('#attachment-category').val());
            form.append('Description', $('#attachment-description').val());
            $.each(files, function (i, file) { form.append('files[]', file); });

            var button = $(this).prop('disabled', true);
            $.ajax({
                type: 'POST', url: '{{ url('gn-attachment/upload') }}', data: form,
                processData: false, contentType: false, dataType: 'json',
                success: result,
                error: function (xhr) {
                    Swal.fire({ icon: 'error', title: 'Gagal', text: xhr.status == 413 ? 'Ukuran file terlalu besar.' : 'Upload gagal.' });
                },
                complete: function () { button.prop('disabled', false); }
            });
        });

        panel.on('click', '.btn-attachment-delete', function () {
            var id = $(this).data('id');
            Swal.fire({
                icon: 'warning', title: 'Hapus lampiran?', text: $(this).data('name'),
                showCancelButton: true, confirmButtonText: 'Hapus', cancelButtonText: 'Batal'
            }).then(function (answer) {
                if (answer.value) {
                    $.post('{{ url('gn-attachment/delete') }}', { _token: $('#_token').val(), IDX_T_Attachment: id }, result, 'json');
                }
            });
        });

        panel.on('click', '.btn-attachment-image', function (e) {
            e.preventDefault();
            var modal = $('#modal-view-attachment-image');
            modal.find('.modal-title').text($(this).data('title'));
            modal.find('img').attr('src', $(this).attr('href'));
            bootstrap.Modal.getOrCreateInstance(modal[0]).show();
        });

        reload();
    });
</script>
