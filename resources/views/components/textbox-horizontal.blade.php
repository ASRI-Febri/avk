<div class="row">
    <label class="col-sm-3 col-form-label text-secondary">{{ $label }}</label>
    <div class="col-sm-9">
        <input type="text" id="{{ $id ?? '' }}" name="{{ $id ?? '' }}" {{ $flag ?? '' }} 
            class="form-control {{ $class ?? '' }}" placeholder="{{ $placeholder ?? '' }}" 
            value="{{ $value ?? '' }}">
    </div>
</div>