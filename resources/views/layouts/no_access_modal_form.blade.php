<div class="modal-header">
    <h5 class="modal-title text-secondary"><i class="icon-table2"></i>{{ $fields['form_desc'] }}</h5> 
    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
        <span aria-hidden="true">&times;</span>
    </button>   
</div>

<div class="modal-body with-padding">

    <!-- BEGIN PANEL -->
    <div class="card">
        
        {{-- <div class="panel-heading">
            <h6 class="panel-title text-semibold">{{ $form_desc }}</h6>	            
        </div>		 --}}

        <!-- BEGIN PANEL BODY -->
        <div class="card-body">
            <h6 class="text-danger">You dont have access!</h6>    
            <hr>
            <p class="text-secondary font-weight-bold">FORM ID : {{ $fields['form_id'] ?? '' }}</p>
            <p class="text-secondary font-weight-bold">NOTES : {{ strtoupper($fields['form_desc']) ?? '' }}</p>
        </div>
        <!-- END PANEL BODY -->
        
    </div>
    <!-- END PANEL --> 
</div>

<div class="modal-footer">
    <button id="btn-close-modal" class="btn btn-outline-secondary" data-dismiss="modal">Close</button>    
</div>