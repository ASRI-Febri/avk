@extends('layouts.master')

@section('topbar-title')
    {{ $form_title }}
@endsection

@section('title')
    {{ $form_title }}
@endsection

@section('content')

    <div class="row">
        <div class="col-xl-10 col-md-12 col-sm-12">
            <div class="card">
                <div class="card-header card-header-bordered">
                    <h3 class="card-title">{{ $form_sub_title }}</h3>
                    <div class="card-addon">
                        <a href="{{ url('ac-fa-asset-import/template') }}" class="btn btn-info me-1">
                            <i class="fas fa-file-download me-1"></i> Download Template
                        </a>
                        <a href="{{ $url_cancel }}" class="btn btn-secondary">
                            <i class="fas fa-arrow-left me-1"></i> Kembali
                        </a>
                    </div>
                </div>

                <div class="card-body">
                    <div class="alert alert-label-info">
                        <span class="text-muted">{{ $form_remark }}</span>
                    </div>

                    @if(!empty($error))
                    <div class="alert alert-danger">{{ $error }}</div>
                    @endif

                    {{-- ============================ HASIL SIMPAN ============================ --}}
                    @if(!empty($result))
                    <div class="alert {{ $result['failed'] > 0 ? 'alert-warning' : 'alert-success' }}">
                        <b>Hasil import:</b> {{ $result['success'] }} aset berhasil disimpan,
                        {{ $result['failed'] }} gagal.
                        @if(count($result['messages']))
                            <hr>
                            @foreach($result['messages'] as $msg)
                                <span style="display:block;">{{ $msg }}</span>
                            @endforeach
                        @endif
                    </div>
                    @endif

                    {{-- ============================ STEP 1: UPLOAD ============================ --}}
                    @if($state == 'upload')
                    <form action="{{ url('ac-fa-asset-import/preview') }}" method="POST" enctype="multipart/form-data">
                        <input type="hidden" name="_token" value="{{ csrf_token() }}" />

                        <div class="d-grid gap-3">
                            <div class="row">
                                <label class="col-sm-3 col-form-label text-secondary">Company</label>
                                <div class="col-sm-9">
                                    <select id="IDX_M_Company" name="IDX_M_Company" class="form-select required" required>
                                        @foreach($dd_company as $key => $val)
                                        <option value="{{ $key }}">{{ $val }}</option>
                                        @endforeach
                                    </select>
                                    <small class="text-muted">Company berlaku untuk seluruh baris dalam file.</small>
                                </div>
                            </div>
                            <div class="row">
                                <label class="col-sm-3 col-form-label text-secondary">File Excel (.xlsx)</label>
                                <div class="col-sm-9">
                                    <input type="file" id="file_import" name="file_import" class="form-control" accept=".xlsx,.xls" required />
                                    <small class="text-muted">Gunakan template di tombol <b>Download Template</b>.
                                        Kolom kategori diisi <b>CategoryCode</b>, cabang diisi <b>BranchID</b>.</small>
                                </div>
                            </div>
                        </div>

                        <hr>
                        <div class="d-flex justify-content-end gap-2">
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-search me-1"></i> Upload &amp; Preview
                            </button>
                        </div>
                    </form>
                    @endif

                    {{-- ============================ STEP 2: PREVIEW ============================ --}}
                    @if($state == 'preview')

                    <div class="alert {{ $error_count > 0 ? 'alert-warning' : 'alert-success' }}">
                        <b>{{ $valid_count }}</b> baris valid siap disimpan,
                        <b>{{ $error_count }}</b> baris bermasalah (tidak akan disimpan).
                        Periksa kolom <b>Status</b> di bawah sebelum konfirmasi.
                    </div>

                    <div class="table-responsive">
                        <table class="table table-sm table-bordered">
                            <thead>
                                <tr>
                                    <th>Baris</th>
                                    <th>Kode</th>
                                    <th>Nama Aset</th>
                                    <th>Kategori</th>
                                    <th>Cabang</th>
                                    <th>Tgl Perolehan</th>
                                    <th>Mulai Pakai</th>
                                    <th class="text-end">Harga Perolehan</th>
                                    <th class="text-end">Residu</th>
                                    <th class="text-end">Umur</th>
                                    <th>Metode</th>
                                    <th class="text-end">Akum. Awal</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                            @foreach($preview as $item)
                                <tr class="{{ count($item['errors']) ? 'table-danger' : '' }}">
                                    <td>{{ $item['row_no'] }}</td>
                                    <td>{{ $item['kode_aset'] !== '' ? $item['kode_aset'] : '(otomatis)' }}</td>
                                    <td>{{ $item['nama_aset'] }}</td>
                                    <td>{{ $item['kategori'] }}</td>
                                    <td>{{ $item['cabang'] }}</td>
                                    <td>{{ $item['tgl_perolehan'] }}</td>
                                    <td>{{ $item['tgl_mulai_pakai'] }}</td>
                                    <td class="text-end">{{ number_format(max($item['harga_perolehan'],0),2) }}</td>
                                    <td class="text-end">{{ number_format(max($item['nilai_residu'],0),2) }}</td>
                                    <td class="text-end">{{ $item['umur_bulan'] }}</td>
                                    <td>{{ $item['metode'] }}</td>
                                    <td class="text-end">{{ number_format(max($item['akum_awal'],0),2) }}</td>
                                    <td>
                                        @if(count($item['errors']))
                                            <span class="text-danger">{{ implode('; ', $item['errors']) }}</span>
                                        @else
                                            <span class="badge bg-success">OK</span>
                                        @endif
                                    </td>
                                </tr>
                            @endforeach
                            </tbody>
                        </table>
                    </div>

                    <hr>
                    <form action="{{ url('ac-fa-asset-import/save') }}" method="POST"
                          onsubmit="this.querySelector('button[type=submit]').disabled = true;">
                        <input type="hidden" name="_token" value="{{ csrf_token() }}" />
                        <div class="d-flex justify-content-end gap-2">
                            <a href="{{ url('ac-fa-asset-import') }}" class="btn btn-light">Ulangi Upload</a>
                            <button type="submit" class="btn btn-primary" {{ $valid_count == 0 ? 'disabled' : '' }}>
                                <i class="far fa-save me-1"></i> Simpan {{ $valid_count }} Aset
                            </button>
                        </div>
                    </form>
                    @endif

                </div>
            </div>
        </div>
    </div>

@endsection

@section('script')
    <script>
        $(document).ready(function () {
            $('#nav-fixed-asset').addClass('mm-active');
            $('#nav-ul-fixed-asset').addClass('mm-show');
            $('#nav-li-fa-import').addClass('mm-active');
        });
    </script>
@endsection
