<div class="card mb-3">
    <div class="card-body">
        <div class="d-flex flex-wrap justify-content-between align-items-center">
            <div class="mb-2 mb-md-0">
                <h4 class="mb-1">{{ $form_sub_title }}</h4>
                <p class="text-muted mb-0">{{ $form_remark ?? '' }}</p>
            </div>
            <form method="get" action="" class="row g-2 align-items-end">
                <div class="col-auto">
                    <label class="form-label text-muted mb-1">Periode (YYYYMM)</label>
                    <input type="text" name="Period" value="{{ $Period }}" maxlength="6"
                           class="form-control" placeholder="YYYYMM" />
                </div>
                <div class="col-auto">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-sync-alt me-1"></i> Tampilkan
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
