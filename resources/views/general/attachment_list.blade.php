@if($can_write)
<div class="row g-2 align-items-end mb-3">
    <div class="col-md-3">
        <label class="form-label text-secondary mb-1" for="attachment-category">Kategori</label>
        <select id="attachment-category" class="form-select">
            <option value="">--SELECT--</option>
            @foreach(\App\Http\Controllers\General\AttachmentController::CATEGORIES as $value => $label)
                <option value="{{ $value }}">{{ $label }}</option>
            @endforeach
        </select>
    </div>
    <div class="col-md-4">
        <label class="form-label text-secondary mb-1" for="attachment-files">File (PDF / JPG / PNG, maks. 10 MB per file)</label>
        <input id="attachment-files" type="file" class="form-control" accept=".pdf,.jpg,.jpeg,.png" multiple>
    </div>
    <div class="col-md-3">
        <label class="form-label text-secondary mb-1" for="attachment-description">Keterangan</label>
        <input id="attachment-description" type="text" class="form-control" maxlength="500" placeholder="(opsional)">
    </div>
    <div class="col-md-2 d-grid">
        <button type="button" class="btn btn-outline-dark" id="btn-attachment-upload">
            <i class="fas fa-upload me-1"></i> Upload
        </button>
    </div>
</div>
@endif

<div class="table-responsive">
    <table class="table table-sm table-bordered mb-0">
        <thead class="table-light">
            <tr>
                <th width="1%">#</th>
                <th>Kategori</th>
                <th>Nama File</th>
                <th class="text-end">Ukuran</th>
                <th>Keterangan</th>
                <th>Diupload</th>
                <th class="text-center">Action</th>
            </tr>
        </thead>
        <tbody>
        @forelse($records_attachment as $i => $row)
            @php($is_image = in_array(strtolower(pathinfo($row->StoredName, PATHINFO_EXTENSION)), $image_extensions))
            <tr>
                <td>{{ $i + 1 }}</td>
                <td>{{ $row->Category }}</td>
                <td>
                    <i class="far {{ $is_image ? 'fa-file-image text-success' : 'fa-file-pdf text-danger' }} me-1"></i>
                    {{ $row->FileName }}
                </td>
                <td class="text-end text-nowrap">{{ number_format($row->FileSize / 1024, 0) }} KB</td>
                <td>{{ $row->Description }}</td>
                <td class="text-nowrap"><small>{{ date('d/m/Y H:i', strtotime($row->DCreate)) }}<br>{{ $row->CreateByName }}</small></td>
                <td class="text-center text-nowrap">
                    @if($is_image)
                        <a href="{{ url('gn-attachment/view/'.$row->IDX_T_Attachment) }}" class="btn btn-sm btn-outline-success btn-attachment-image"
                           data-title="{{ $row->FileName }}" title="Lihat"><i class="fa fa-eye"></i></a>
                    @else
                        <a href="{{ url('gn-attachment/view/'.$row->IDX_T_Attachment) }}" target="_blank" class="btn btn-sm btn-outline-success" title="Lihat">
                            <i class="fa fa-eye"></i></a>
                    @endif
                    <a href="{{ url('gn-attachment/download/'.$row->IDX_T_Attachment) }}" class="btn btn-sm btn-outline-info" title="Download">
                        <i class="fa fa-download"></i></a>
                    @if($can_write)
                        <button type="button" class="btn btn-sm btn-outline-danger btn-attachment-delete" title="Hapus"
                                data-id="{{ $row->IDX_T_Attachment }}" data-name="{{ $row->FileName }}"><i class="fa fa-trash"></i></button>
                    @endif
                </td>
            </tr>
        @empty
            <tr><td colspan="7" class="text-center text-muted">Belum ada lampiran.</td></tr>
        @endforelse
        </tbody>
    </table>
</div>
