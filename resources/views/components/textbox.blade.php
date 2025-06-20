<div>
    <label for="exampleFormControlInput1" class="form-label">{{ $label }}</label> 
    <input type="text" id="{{ $id ?? '' }}" name="{{ $id ?? '' }}" class="form-control {{ $class ?? '' }}" placeholder="{{ $placeholder ?? '' }}" value="{{ $value ?? '' }}" />
</div>