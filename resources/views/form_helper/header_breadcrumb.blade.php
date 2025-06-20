<!-- BEGIN BREADCRUMBS -->
<div class="row">
    <div class="col-12  align-self-center">
        <div class="sub-header mt-3 py-3 align-self-center d-sm-flex w-100 rounded">
            <div class="w-sm-100 mr-auto">
                <h4 class="mb-0 text-secondary">{{ $form_title ?? ''}}</h4>
                <p class="text-secondary">{{ $form_sub_title ?? '' }}</p>
            </div>

            <ol class="breadcrumb bg-transparent align-self-center m-0 p-0">
                @php      
                    $length = sizeof($breads);
                    $i = 0; 
                    $class = 'class="breadcrumb-item"';     
                    $icon = '';
                    foreach ($breads as $bread){
                        $i += 1;
            
                        if($i == $length){
                            $class = 'class="breadcrumb-item active text-secondary"';
                        }
                        echo '<li ' . $class . '>'.$bread.'</li>';
                    }  
                @endphp	                
            </ol>
        </div>
    </div>
</div>
<!-- END BREADCRUMBS -->