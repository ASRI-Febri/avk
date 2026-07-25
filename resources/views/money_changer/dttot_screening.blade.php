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
                            <i class="fas fa-arrow-left me-1"></i> Kembali ke Daftar DTTOT
                        </a>
                    </div>
                </div>

                <div class="card-body">
                    <div class="alert alert-label-info">
                        <span class="text-muted">{{ $form_remark }}</span>
                    </div>

                    @if(!empty($result))
                    <div class="alert alert-success">
                        <b>Screening tersimpan:</b> {{ $result['set_yes'] }} konsumen ditandai DTTOT,
                        {{ $result['set_no'] }} konsumen dihapus tandanya.
                    </div>
                    @endif

                    <form id="form-screening" action="{{ $url_save }}" method="POST">
                        <input type="hidden" name="_token" value="{{ csrf_token() }}" />

                        {{-- ==================== HASIL PENCOCOKAN ==================== --}}
                        <h5 class="mb-3">Hasil Pencocokan Nama Konsumen dengan Daftar DTTOT</h5>

                        <div class="table-responsive">
                            <table class="table table-bordered table-striped table-sm">
                                <thead>
                                    <tr>
                                        <th class="text-center">Tandai</th>
                                        <th>#</th>
                                        <th>Kode Nasabah</th>
                                        <th>Nama Konsumen</th>
                                        <th>No KTP</th>
                                        <th>Nama di Daftar DTTOT</th>
                                        <th>Kode Densus</th>
                                        <th>Terduga</th>
                                        <th class="text-center">Match</th>
                                        <th class="text-center">Flag Saat Ini</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @php $no = 0; @endphp
                                    @if($matches)
                                    @foreach($matches as $row)
                                        @php
                                            $no++;
                                            $checked = ($row->MatchType == 'EXACT') || ($row->IsDTTOT == 'Y');
                                        @endphp
                                        <tr class="{{ $row->MatchType == 'EXACT' ? 'table-danger' : 'table-warning' }}">
                                            <td class="text-center">
                                                <input type="checkbox" name="mark[]" value="{{ $row->IDX_M_Partner }}" {{ $checked ? 'checked' : '' }} />
                                                <input type="hidden" name="matched[]" value="{{ $row->IDX_M_Partner }}" />
                                            </td>
                                            <td>{{ $no }}</td>
                                            <td>{{ $row->PartnerID }}</td>
                                            <td>{{ $row->PartnerName }}</td>
                                            <td>{{ $row->SingleIdentityNumber }}</td>
                                            <td title="{{ $row->DTTOTName }}">{{ \Illuminate\Support\Str::limit($row->DTTOTName, 80) }}</td>
                                            <td class="text-center">{{ $row->DensusCode }}</td>
                                            <td class="text-center">{{ $row->SuspectType }}</td>
                                            <td class="text-center">
                                                @if($row->MatchType == 'EXACT')
                                                    <span class="badge bg-danger">EXACT</span>
                                                @else
                                                    <span class="badge bg-warning text-dark">PARTIAL</span>
                                                @endif
                                            </td>
                                            <td class="text-center">{{ $row->IsDTTOT == 'Y' ? 'Y' : '' }}</td>
                                        </tr>
                                    @endforeach
                                    @endif

                                    @if($no == 0)
                                        <tr>
                                            <td colspan="10" class="text-center text-muted">
                                                Tidak ada nama konsumen yang cocok dengan daftar DTTOT.
                                            </td>
                                        </tr>
                                    @endif
                                </tbody>
                            </table>
                        </div>

                        {{-- ==================== FLAG LAMA TANPA MATCH ==================== --}}
                        @if(count($unmatched_flagged) > 0)
                            <hr>
                            <h5 class="mb-3">Konsumen Bertanda DTTOT yang Tidak Ditemukan di Daftar Terbaru</h5>
                            <div class="alert alert-label-info">
                                <span class="text-muted">
                                    Konsumen berikut saat ini bertanda IsDTTOT = Y tetapi namanya tidak cocok
                                    dengan daftar DTTOT terbaru. Centang untuk menghapus tandanya.
                                </span>
                            </div>

                            <div class="table-responsive">
                                <table class="table table-bordered table-striped table-sm">
                                    <thead>
                                        <tr>
                                            <th class="text-center">Hapus Tanda</th>
                                            <th>#</th>
                                            <th>Kode Nasabah</th>
                                            <th>Nama Konsumen</th>
                                            <th>No KTP</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        @foreach($unmatched_flagged as $i => $row)
                                            <tr>
                                                <td class="text-center">
                                                    <input type="checkbox" name="unflag[]" value="{{ $row->IDX_M_Partner }}" />
                                                </td>
                                                <td>{{ $i + 1 }}</td>
                                                <td>{{ $row->PartnerID }}</td>
                                                <td>{{ $row->PartnerName }}</td>
                                                <td>{{ $row->SingleIdentityNumber }}</td>
                                            </tr>
                                        @endforeach
                                    </tbody>
                                </table>
                            </div>
                        @endif

                        <hr>

                        <div class="d-flex justify-content-end gap-2">
                            <a href="{{ $url_cancel }}" class="btn btn-light">Batal</a>
                            <button type="submit" id="btn-save" class="btn btn-primary" {{ ($no == 0 && count($unmatched_flagged) == 0) ? 'disabled' : '' }}>
                                <i class="fas fa-user-shield me-1"></i> Simpan Penandaan DTTOT
                            </button>
                        </div>
                    </form>
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

            $('#form-screening').on('submit', function (e) {
                e.preventDefault();
                var form = this;
                var mark = $('input[name="mark[]"]:checked').length;
                var unflag = $('input[name="unflag[]"]:checked').length;

                Swal.fire({
                    title: 'Simpan Penandaan DTTOT?',
                    html: '<b>' + mark + '</b> konsumen akan ditandai DTTOT.<br>' +
                        'Baris hasil pencocokan yang tidak dicentang dan <b>' + unflag + '</b> konsumen ' +
                        'di daftar bawah akan dihapus tandanya.',
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonText: 'Ya, Simpan',
                    cancelButtonText: 'Batal'
                }).then(function (result) {
                    if (result.isConfirmed) {
                        $('#btn-save').prop('disabled', true)
                            .html('<i class="fa fa-spinner fa-spin me-1"></i> Menyimpan...');
                        form.submit();
                    }
                });
            });
        });
    </script>
@endsection
