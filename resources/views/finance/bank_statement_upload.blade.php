@extends('layouts.master')

@section('title')
    {{ $form_title }}
@endsection

@section('active_link')
	$('#nav-transaction').addClass('mm-active');
    $('#nav-ul-transaction').addClass('mm-show');
    $('#nav-li-view-bs-upload').addClass('mm-active');
@endsection

@section('content')

    <div class="row">
        <div class="col-12">
            <div class="card">
                <div class="card-header card-header-bordered">
                    <h3 class="card-title">{{ $form_sub_title }}</h3>
                    <div class="card-addon">
                        <a href="{{ $url_cancel }}" class="btn btn-secondary">
                            <i class="fas fa-list me-1"></i> Daftar Rekening Koran
                        </a>
                    </div>
                </div>

                <div class="card-body">
                    <div class="alert alert-label-info">
                        <span class="text-muted">{{ $upload_info }}</span>
                    </div>

                    @if(!empty($error))
                    <div class="alert alert-danger">{{ $error }}</div>
                    @endif

                    {{-- ============================ STEP 1: UPLOAD ============================ --}}
                    @if($state == 'upload')
                    <form action="{{ url('fm-bank-statement/preview') }}" method="POST" enctype="multipart/form-data"
                          onsubmit="this.querySelector('button[type=submit]').disabled = true;">
                        <input type="hidden" name="_token" value="{{ csrf_token() }}" />

                        <div class="row">
                            <label class="col-sm-3 col-form-label text-secondary">File Rekening Koran (.pdf)</label>
                            <div class="col-sm-9">
                                <input type="file" name="file_statement" class="form-control" accept=".pdf" required />
                                <small class="text-muted">Account Statement dari Kopra by Mandiri.</small>
                            </div>
                        </div>
                        <hr>
                        <div class="d-flex justify-content-end">
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-search me-1"></i> Upload &amp; Tampilkan
                            </button>
                        </div>
                    </form>
                    @endif

                    {{-- ============================ STEP 2: PREVIEW ============================ --}}
                    @if($state == 'preview')
                    @php($header = $statement['header'])
                    <form action="{{ url('fm-bank-statement/save') }}" method="POST"
                          onsubmit="this.querySelector('button[type=submit]').disabled = true;">
                        <input type="hidden" name="_token" value="{{ csrf_token() }}" />

                        <div class="row mb-3">
                            <div class="col-md-6">
                                <table class="table table-sm table-borderless mb-0">
                                    <tr><td class="text-secondary" width="40%">No Rekening</td><td>{{ $header['account_no'] }}</td></tr>
                                    <tr><td class="text-secondary">Nama Rekening</td><td>{{ $header['account_name'] }}</td></tr>
                                    <tr><td class="text-secondary">Periode</td>
                                        <td>{{ date('d M Y', strtotime($header['period_start'])) }} - {{ date('d M Y', strtotime($header['period_end'])) }}</td></tr>
                                    <tr><td class="text-secondary">Mata Uang</td><td>{{ $header['currency'] }}</td></tr>
                                </table>
                            </div>
                            <div class="col-md-6">
                                <table class="table table-sm table-borderless mb-0">
                                    <tr><td class="text-secondary" width="40%">Saldo Awal</td><td class="text-end">{{ number_format($header['opening_balance'], 2) }}</td></tr>
                                    <tr><td class="text-secondary">Total Debit</td><td class="text-end">{{ number_format($header['total_debit'], 2) }}</td></tr>
                                    <tr><td class="text-secondary">Total Kredit</td><td class="text-end">{{ number_format($header['total_credit'], 2) }}</td></tr>
                                    <tr><td class="text-secondary">Saldo Akhir</td><td class="text-end">{{ number_format($header['closing_balance'], 2) }}</td></tr>
                                </table>
                            </div>
                        </div>

                        @if(count($statement['warnings']))
                        <div class="alert alert-label-warning text-dark">
                            <div>
                                <b>Periksa kembali, hasil baca PDF tidak cocok dengan ringkasan rekening koran:</b>
                                @foreach($statement['warnings'] as $warning)
                                    <span style="display:block;">{{ $warning }}</span>
                                @endforeach
                            </div>
                        </div>
                        @else
                        <div class="alert alert-success">
                            <div>
                                <b>{{ count($statement['rows']) }}</b> transaksi terbaca. Saldo setiap baris dan total debit/kredit
                                sudah sesuai dengan ringkasan rekening koran.
                            </div>
                        </div>
                        @endif

                        <div class="d-grid gap-3 mb-3">
                            <x-select-horizontal label="Financial Account" id="IDX_M_FinancialAccount" :value="$IDX_M_FinancialAccount" class="required" :array="$dd_financial_account"/>
                            <x-textbox-horizontal label="Catatan" id="Notes" value="" placeholder="Catatan (opsional)" class="" />
                        </div>

                        <div class="alert alert-label-warning text-dark mb-2">
                            <div>
                                Baris yang dicentang pada kolom <b>Biaya Admin</b> akan dijumlahkan menjadi satu jurnal biaya admin.
                                Terpilih: <b id="admin-fee-count">0</b> baris, total <b id="admin-fee-total">0</b>.
                            </div>
                        </div>

                        <div class="table-responsive" style="max-height: 600px;">
                            <table class="table table-sm table-bordered table-hover">
                                <thead class="table-light" style="position: sticky; top: 0;">
                                    <tr>
                                        <th>No</th>
                                        <th>Tanggal</th>
                                        <th>Keterangan</th>
                                        <th>Reference No</th>
                                        <th class="text-end">Debit</th>
                                        <th class="text-end">Kredit</th>
                                        <th class="text-end">Saldo</th>
                                        <th class="text-center">Biaya Admin</th>
                                    </tr>
                                </thead>
                                <tbody>
                                @foreach($statement['rows'] as $row)
                                    <tr>
                                        <td>{{ $row['seq'] }}</td>
                                        <td class="text-nowrap">{{ date('d/m/Y H:i', strtotime($row['posting_date'])) }}</td>
                                        <td><small>{{ $row['remark'] }}</small></td>
                                        <td><small>{{ $row['reference_no'] }}</small></td>
                                        <td class="text-end">{{ $row['debit'] > 0 ? number_format($row['debit'], 2) : '' }}</td>
                                        <td class="text-end">{{ $row['credit'] > 0 ? number_format($row['credit'], 2) : '' }}</td>
                                        <td class="text-end">{{ number_format($row['balance'], 2) }}</td>
                                        <td class="text-center">
                                            @if($row['debit'] > 0)
                                            <input type="checkbox" class="form-check-input chk-admin-fee" name="admin_fee[]"
                                                   value="{{ $row['seq'] }}" data-amount="{{ $row['debit'] }}" {{ $row['is_admin_fee'] ? 'checked' : '' }}/>
                                            @endif
                                        </td>
                                    </tr>
                                @endforeach
                                </tbody>
                            </table>
                        </div>

                        <hr>
                        <div class="d-flex justify-content-end gap-2">
                            <a href="{{ url('fm-bank-statement/upload') }}" class="btn btn-secondary">
                                <i class="fas fa-redo me-1"></i> Upload Ulang
                            </a>
                            <button type="submit" class="btn btn-primary">
                                <i class="far fa-save me-1"></i> Simpan Rekening Koran
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
            function sumAdminFee()
            {
                var total = 0, count = 0;
                $('.chk-admin-fee:checked').each(function () {
                    total += parseFloat($(this).data('amount'));
                    count++;
                });
                $('#admin-fee-count').text(count);
                $('#admin-fee-total').text(total.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2}));
            }

            $('.chk-admin-fee').change(sumAdminFee);
            sumAdminFee();
        });
    </script>
@endsection
