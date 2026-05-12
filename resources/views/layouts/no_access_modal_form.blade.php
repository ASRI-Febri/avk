<div class="modal-header">
    <h5 class="modal-title"><i class="icon-table2"></i>{{ $form_desc }}</h5> 

    <div class="card-addon">
        <button type="button" class="btn btn-danger" data-bs-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
        </button>   
    </div>
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
    <button id="btn-close-modal" type="button" class="btn btn-danger" data-bs-dismiss="modal">
        <i class="fas fa-undo"></i> Close
    </button>	
</div>