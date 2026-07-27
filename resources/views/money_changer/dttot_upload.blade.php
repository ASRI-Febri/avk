@extends('layouts.master')

@section('topbar-title')
    {{ $form_title }}
@endsection

@section('title')
    {{ $form_title }}
@endsection

@section('content')

    <div class="row">
        <div class="col-xl-12 col-md-12 col-sm-12">
            <div class="card">
                <div class="card-header card-header-bordered">
                    <h3 class="card-title">{{ $form_sub_title }}</h3>
                    <div class="card-addon">
                        <a href="{{ $url_cancel }}" class="btn btn-secondary">
                            <i class="fas fa-arrow-left me-1"></i> Kembali ke Daftar
                        </a>
                    </div>
                </div>

                <div class="card-body">
                    <div class="alert alert-label-info">
                        <span class="text-muted">
                            Upload file Excel DTTOT resmi (contoh: <b>DTTOT 20260709 (RENEWAL JULI).xlsx</b>).
                            Urutan kolom harus sesuai file resmi: Nama, Deskripsi, Terduga, Kode Densus,
                            Tempat Lahir, Tanggal Lahir, WN/Asal Negara, Alamat.
                            Setiap upload akan <b>mengganti seluruh</b> daftar DTTOT yang tersimpan.
                        </span>
                    </div>

                    @if(!empty($error))
                    <div class="alert alert-danger">{{ $error }}</div>
                    @endif

                    {{-- ============================ HASIL SIMPAN ============================ --}}
                    @if(!empty($result))
                    <div class="alert {{ $result['failed'] > 0 ? 'alert-warning' : 'alert-success' }}">
                        <b>Hasil upload:</b> {{ $result['success'] }} baris berhasil disimpan,
                        {{ $result['failed'] }} gagal.
                        @if(count($result['messages']))
                            <hr>
                            @foreach($result['messages'] as $msg)
                                <span style="display:block;">{{ $msg }}</span>
                            @endforeach
                        @endif
                        @if($result['success'] > 0)
                            <hr>
                            Daftar DTTOT sudah diperbarui — jalankan screening untuk mencocokkan nama konsumen.
                            <a href="{{ url('mc-dttot/screening') }}" class="btn btn-sm btn-primary ms-2">
                                <i class="fas fa-user-shield me-1"></i> Jalankan Screening
                            </a>
                        @endif
                    </div>
                    @endif

                    {{-- ============================ STEP 1: UPLOAD ============================ --}}
                    @if($state == 'upload')
                    <form action="{{ url('mc-dttot/preview') }}" method="POST" enctype="multipart/form-data"
                        data-loader="Membaca file DTTOT...">
                        <input type="hidden" name="_token" value="{{ csrf_token() }}" />

                        <div class="d-grid gap-3">
                            <div class="row">
                                <label class="col-sm-3 col-form-label text-secondary">File Excel (.xlsx)</label>
                                <div class="col-sm-9">
                                    <input type="file" id="file_import" name="file_import" class="form-control" accept=".xlsx,.xls" required />
                                    <small class="text-muted">Gunakan file DTTOT resmi tanpa mengubah susunan kolom.</small>
                                </div>
                            </div>
                        </div>

                        <hr>
                        <div class="d-flex justify-content-end gap-2">
                            <button type="submit" class="btn btn-primary" data-loader-text="Membaca file...">
                                <i class="fas fa-search me-1"></i> Upload &amp; Preview
                            </button>
                        </div>
                    </form>
                    @endif

                    {{-- ============================ STEP 2: PREVIEW ============================ --}}
                    @if($state == 'preview')

                    <div class="alert {{ $error_count > 0 ? 'alert-warning' : 'alert-success' }}">
                        File <b>{{ $file_name }}</b>:
                        <b>{{ $valid_count }}</b> baris valid siap disimpan,
                        <b>{{ $error_count }}</b> baris bermasalah (tidak akan disimpan).
                        @if($existing_count > 0)
                            <br>Saat ini tersimpan <b>{{ $existing_count }}</b> baris DTTOT —
                            seluruhnya akan <b>dihapus dan diganti</b> dengan isi file ini.
                        @endif
                    </div>

                    <div class="table-responsive" style="max-height: 500px; overflow-y: auto;">
                        <table class="table table-sm table-bordered table-striped">
                            <thead>
                                <tr>
                                    <th>Baris</th>
                                    <th>Nama</th>
                                    <th>Terduga</th>
                                    <th>Kode Densus</th>
                                    <th>Tempat Lahir</th>
                                    <th>Tanggal Lahir</th>
                                    <th>WN/Asal Negara</th>
                                    <th>Alamat</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                            @foreach($preview as $item)
                                <tr class="{{ count($item['errors']) ? 'table-danger' : '' }}">
                                    <td>{{ $item['row_no'] }}</td>
                                    <td>{{ \Illuminate\Support\Str::limit($item['FullName'], 80) }}</td>
                                    <td>{{ $item['SuspectType'] }}</td>
                                    <td>{{ $item['DensusCode'] }}</td>
                                    <td>{{ \Illuminate\Support\Str::limit($item['PlaceOfBirth'], 40) }}</td>
                                    <td>{{ $item['DateOfBirth'] }}</td>
                                    <td>{{ \Illuminate\Support\Str::limit($item['Nationality'], 40) }}</td>
                                    <td>{{ \Illuminate\Support\Str::limit($item['Address'], 60) }}</td>
                                    <td>
                                        @if(count($item['errors']))
                                            <span class="text-danger">{{ implode('; ', $item['errors']) }}</span>
                                        @else
                                            <span class="text-success">OK</span>
                                        @endif
                                    </td>
                                </tr>
                            @endforeach
                            </tbody>
                        </table>
                    </div>

                    <hr>

                    <form id="form-save" action="{{ url('mc-dttot/save') }}" method="POST">
                        <input type="hidden" name="_token" value="{{ csrf_token() }}" />

                        <div class="d-flex justify-content-end gap-2">
                            <a href="{{ url('mc-dttot/upload') }}" class="btn btn-light">Upload Ulang</a>
                            <button type="submit" id="btn-save" class="btn btn-primary" {{ $valid_count == 0 ? 'disabled' : '' }}>
                                <i class="fas fa-database me-1"></i> Simpan Data ({{ $valid_count }} baris)
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
            $('#nav-transaction').addClass('mm-active');
            $('#nav-ul-transaction').addClass('mm-show');
            $('#nav-li-dttot').addClass('mm-active');

            $('#form-save').on('submit', function (e) {
                e.preventDefault();
                var form = this;

                Swal.fire({
                    title: 'Simpan Data DTTOT?',
                    html: 'Seluruh daftar DTTOT lama akan <b>dihapus</b> dan diganti dengan isi file ini.',
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonText: 'Ya, Simpan',
                    cancelButtonText: 'Batal'
                }).then(function (result) {
                    if (result.isConfirmed) {
                        $('#btn-save').prop('disabled', true)
                            .html('<i class="fa fa-spinner fa-spin me-1"></i> Menyimpan...');
                        showPageLoader('Menyimpan daftar DTTOT...');
                        form.submit();
                    }
                });
            });
        });
    </script>
@endsection
