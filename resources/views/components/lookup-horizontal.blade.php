<div class="form-group row">
    <label class="col-sm-3 col-form-label text-secondary">{{ $label }}</label>
    <div class="col-sm-9">
        <div class="input-group">
            <input type="text" id="{{ $id }}" name="{{ $id }}" readonly class="form-control" placeholder="" value="{{ $value ?? '' }}">
            <div class="btn-group">
                <button class="btn btn-icon btn-outline-danger" type="button" onClick="clearMe('{{ $id }}');">
                    <i class="fa fa-times"></i>
                </button>
                <button id="{{ $button }}" class="btn btn-icon btn-outline-success" type="button" title="Search">
                    <i class="fa fa-search"></i>
                </button>                        
            </div> 
        </div>
    </div>
</div>

{{-- <div class="input-group">
    <input type="text" class="form-control" placeholder="" aria-label="Example text with two button addons"> 
    <button class="btn btn-outline-secondary" type="button">Button</button>
    <button class="btn btn-outline-secondary" type="button">Button</button>
</div> --}}