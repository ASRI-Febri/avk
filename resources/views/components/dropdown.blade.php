<label for="{{ $id }}" class="required form-label">{{ $label }}</label>
<select id="{{ $id }}" class="form-select" aria-label="Select">
    {{ $slot }}
</select>