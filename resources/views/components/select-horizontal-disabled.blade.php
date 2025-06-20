<div class="form-group row">
    <label class="col-sm-3 col-form-label text-secondary">{{ $label }}</label>
    <div class="col-sm-9">
        <select id="{{ $id ?? ''}}" name="{{ $id ?? ''}}" class="select2 {{ $class ?? '' }}" disabled="disabled">            
            @foreach($array as $key => $value_component)
                <option value="{{ $key }}" {{ trim($value) == $key ? 'selected=' : '' }}>
                    {{ $value_component }}
                </option>
            @endforeach
        </select>
    </div>
</div>