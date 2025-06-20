<div class="form-group row">
    <label class="col-sm-3 col-form-label text-secondary">{{ $label }}</label>
    <div class="col-sm-9">
        <textarea id="{{ $id ?? '' }}" name="{{ $id ?? '' }}" class="form-control {{ $class ?? '' }}" placeholder="{{ $placeholder ?? '' }}">{{ $value ?? '' }}</textarea>        
    </div>
</div>