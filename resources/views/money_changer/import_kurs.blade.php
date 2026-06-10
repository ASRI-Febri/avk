@extends('layouts.master')

@section('title', $title ?? 'Import Kurs')

@section('content')

    @php
        $state       = $state ?? 'edit';
        $pasted      = $pasted ?? '';
        $rateset     = $rateset ?? '';
        $preview     = $preview ?? null;
        $result      = $result ?? null;
        $error       = $error ?? null;
        $source_name = $source_name ?? 'Bank';
        $source_url  = $source_url ?? '#';
        $options     = $rate_options ?? [];
        $rateset_label = function ($key) use ($options) { return $options[$key] ?? $key; };
    @endphp

    <div class="row">

        <!-- ===================== KIRI: FORM PASTE ===================== -->
        <div class="col-lg-6">
            <div class="card">
                <div class="card-body">
                    <h5 class="card-title mb-1">Tempel Tabel Kurs {{ $source_name }}</h5>
                    <p class="text-muted mb-3">
                        Buka <a href="{{ $source_url }}" target="_blank" rel="noopener">{{ preg_replace('#^https?://#', '', $source_url) }}</a>,
                        blok seluruh tabel kurs, salin (Ctrl/Cmd&nbsp;+&nbsp;C), lalu tempel di kotak bawah ini dan klik
                        <strong>Preview</strong>. Data baru tersimpan setelah Anda konfirmasi.
                    </p>

                    <form action="{{ $url_preview }}" method="POST">
                        @csrf

                        <div class="mb-3">
                            <label class="form-label">Sumber kolom kurs</label>
                            <div>
                                @foreach($options as $key => $label)
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" name="rateset" id="rateset-{{ $key }}"
                                            value="{{ $key }}" {{ $rateset === $key ? 'checked' : '' }}>
                                        <label class="form-check-label" for="rateset-{{ $key }}">{{ $label }}</label>
                                    </div>
                                @endforeach
                            </div>
                            @if(!empty($rateset_note))
                                <small class="text-muted">{{ $rateset_note }}</small>
                            @endif
                        </div>

                        <div class="mb-3">
                            <label class="form-label" for="pasted">Teks kurs</label>
                            <textarea class="form-control" id="pasted" name="pasted" rows="14"
                                style="font-family: monospace; white-space: pre;"
                                placeholder="{{ $paste_placeholder ?? '' }}">{{ $pasted }}</textarea>
                        </div>

                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-search me-1"></i> {{ $state === 'preview' ? 'Preview Ulang' : 'Preview' }}
                        </button>
                        <a href="{{ $url_cancel ?? url('mc-currency') }}" class="btn btn-light">Batal</a>
                    </form>
                </div>
            </div>
        </div>

        <!-- ===================== KANAN: PREVIEW / HASIL ===================== -->
        <div class="col-lg-6">
            <div class="card">
                <div class="card-body">

                    @if($error)
                        <h5 class="card-title mb-3">Preview</h5>
                        <div class="alert alert-warning mb-0">{{ $error }}</div>

                    @elseif($preview)
                        {{-- ---------- STATE: PREVIEW (belum tersimpan) ---------- --}}
                        <h5 class="card-title mb-1">Preview — periksa sebelum simpan</h5>
                        <p class="mb-3">
                            Sumber kolom: <strong>{{ $rateset_label($preview['rateset']) }}</strong>
                            &middot; Akan diperbarui: <strong>{{ count($preview['parsed']) }}</strong> mata uang.
                        </p>

                        @if(count($preview['parsed']))
                            <div class="table-responsive">
                                <table class="table table-sm table-bordered align-middle mb-3">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Mata Uang</th>
                                            <th class="text-end">Rate Beli</th>
                                            <th class="text-end">Rate Jual</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        @foreach($preview['parsed'] as $u)
                                            <tr>
                                                <td>{{ $u['currency'] }}</td>
                                                <td class="text-end">{{ number_format($u['buy'], 2, ',', '.') }}</td>
                                                <td class="text-end">{{ number_format($u['sell'], 2, ',', '.') }}</td>
                                            </tr>
                                        @endforeach
                                    </tbody>
                                </table>
                            </div>
                        @else
                            <div class="alert alert-warning">
                                Tidak ada baris kurs yang dikenali. Periksa kembali teks yang ditempel atau pilihan kolom kurs.
                            </div>
                        @endif

                        @if(!empty($preview['skipped']))
                            <div class="alert alert-info py-2 mb-2">
                                <strong>Akan dilewati (tidak ada di master aktif):</strong>
                                {{ implode(', ', $preview['skipped']) }}
                            </div>
                        @endif

                        @if(!empty($preview['unparsed']))
                            <div class="alert alert-secondary py-2 mb-3">
                                <strong>Baris tak terbaca:</strong>
                                <ul class="mb-0 mt-1">
                                    @foreach($preview['unparsed'] as $line)
                                        <li><code>{{ \Illuminate\Support\Str::limit($line, 80) }}</code></li>
                                    @endforeach
                                </ul>
                            </div>
                        @endif

                        @if(count($preview['parsed']))
                            <form action="{{ $url_save }}" method="POST" class="mt-2">
                                @csrf
                                <input type="hidden" name="rateset" value="{{ $preview['rateset'] }}">
                                <input type="hidden" name="pasted" value="{{ $pasted }}">
                                <button type="submit" class="btn btn-success">
                                    <i class="fas fa-check me-1"></i> Konfirmasi &amp; Simpan {{ count($preview['parsed']) }} Kurs
                                </button>
                                <span class="text-muted ms-2">atau ubah teks di kiri lalu Preview Ulang.</span>
                            </form>
                        @endif

                    @elseif($result && isset($result['error']))
                        <h5 class="card-title mb-3">Hasil Import</h5>
                        <div class="alert alert-warning mb-0">{{ $result['error'] }}</div>

                    @elseif($result)
                        {{-- ---------- STATE: HASIL SIMPAN ---------- --}}
                        <h5 class="card-title mb-2">Hasil Import</h5>
                        <div class="alert alert-success py-2">
                            <strong>{{ count($result['updated']) }}</strong> mata uang berhasil diperbarui
                            (sumber: {{ $rateset_label($result['rateset']) }}).
                        </div>

                        @if(count($result['updated']))
                            <div class="table-responsive">
                                <table class="table table-sm table-bordered align-middle mb-3">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Mata Uang</th>
                                            <th class="text-end">Rate Beli</th>
                                            <th class="text-end">Rate Jual</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        @foreach($result['updated'] as $u)
                                            <tr>
                                                <td>{{ $u['currency'] }}</td>
                                                <td class="text-end">{{ number_format($u['buy'], 2, ',', '.') }}</td>
                                                <td class="text-end">{{ number_format($u['sell'], 2, ',', '.') }}</td>
                                            </tr>
                                        @endforeach
                                    </tbody>
                                </table>
                            </div>
                        @endif

                        @if(!empty($result['notfound']))
                            <div class="alert alert-info py-2 mb-2">
                                <strong>Dilewati (tidak ada di master aktif):</strong>
                                {{ implode(', ', $result['notfound']) }}
                            </div>
                        @endif

                        @if(!empty($result['unparsed']))
                            <div class="alert alert-secondary py-2 mb-0">
                                <strong>Baris tak terbaca:</strong>
                                <ul class="mb-0 mt-1">
                                    @foreach($result['unparsed'] as $line)
                                        <li><code>{{ \Illuminate\Support\Str::limit($line, 80) }}</code></li>
                                    @endforeach
                                </ul>
                            </div>
                        @endif

                    @else
                        <h5 class="card-title mb-3">Preview</h5>
                        <p class="text-muted mb-0">Tempel data di kiri lalu klik <em>Preview</em> untuk memeriksa hasil sebelum disimpan.</p>
                    @endif

                </div>
            </div>
        </div>
    </div>

@endsection
