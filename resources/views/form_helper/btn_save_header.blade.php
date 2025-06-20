<button id="btn-save-header" class="btn btn-primary" type="button" onClick="saveHeader('{{ $url_save_header }}');">
    <i class="far fa-save fa-1x"></i> 
    @if(isset($btn_text))
        {{ $btn_text }}
    @else 
        Save
    @endif
</button>