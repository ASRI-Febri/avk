<div class="modal-header">
    <h5 class="modal-title"><i class="icon-table2"></i>{{ $form_desc }}</h5> 

    <div class="card-addon">
        <button type="button" class="btn btn-danger" data-bs-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
        </button>   
    </div>
</div>

<div class="modal-body with-padding">	
    <form id="form-modal" name="form-modal" autocomplete="off" enctype="multipart/form-data" class="" action="#" role="form" method="post">
        
        <input type="hidden" id="_token" name="_token" value="{{ csrf_token() }}"/>
        <input type="hidden" id="state" name="state" value="{{ $state ?? '' }}"/>
        <input type="hidden" id="RecordStatus" name="RecordStatus" value="{{ $fields->RecordStatus ?? 'A' }}"/>

        @yield('modal-content')
        
    </form>
</div>

<div class="modal-footer">
    <button id="btn-close-modal" type="button" class="btn btn-danger" data-bs-dismiss="modal">
        <i class="fas fa-undo"></i> Close
    </button>	

    @if(!isset($show_save) || $show_save == TRUE)
        @yield('button-save')    
    @endif
</div>

@yield('style')  

<style>        
    .ui-autocomplete {				
        z-index: 9999;
    }
    
    .ui-draggable, .ui-droppable {
        background-position: top;
    }
    
    .ui-widget {
        font-family: Arial,Helvetica,sans-serif;
        font-size: 1em;
    }
    .ui-widget .ui-widget {
        font-size: 1em;
    }
    .ui-widget input,
    .ui-widget select,
    .ui-widget textarea,
    .ui-widget button {
        font-family: Arial,Helvetica,sans-serif;
        font-size: 1em;
    }        
</style>

<script>
    $(document).ready(function(){   
        $('input.auto').autoNumeric();
        $("input:text").focus(function() { $(this).select(); } );

        $('.readonly').attr('readonly', true);

        // $('#form-modal').validate({
        //     errorClass: 'text-danger',
        //     successClass: 'text-success',					
            
        //     highlight: function(element, errorClass) {
        //         //$(element).removeClass(errorClass);
        //     },
        //     unhighlight: function(element, errorClass) {
        //         $(element).removeClass(errorClass);
        //     },
        //     errorPlacement: function(error, element) {
        //         // Styled checkboxes, radios, bootstrap switch
        //         if (element.parents('div').hasClass("checker") || element.parents('div').hasClass("choice") || element.parent().hasClass('bootstrap-switch-container') ) {
        //             if(element.parents('label').hasClass('checkbox-inline') || element.parents('label').hasClass('radio-inline')) {
        //                 error.appendTo( element.parent().parent().parent().parent() );
        //             }
        //             else {
        //                 error.appendTo( element.parent().parent().parent().parent().parent() );
        //             }
        //         }

        //         // Unstyled checkboxes, radios
        //         else if (element.parents('div').hasClass('checkbox') || element.parents('div').hasClass('radio')) {
        //             error.appendTo( element.parent().parent().parent() );
        //         }

        //         // Input with icons and Select2
        //         else if (element.parents('div').hasClass('has-feedback') || element.hasClass('select2-hidden-accessible')) {
        //             error.appendTo( element.parent() );
        //         }

        //         // Inline checkboxes, radios
        //         else if (element.parents('label').hasClass('checkbox-inline') || element.parents('label').hasClass('radio-inline')) {
        //             error.appendTo( element.parent().parent() );
        //         }

        //         // Input group, styled file input
        //         else if (element.parent().hasClass('uploader') || element.parents().hasClass('input-group')) {
        //             error.appendTo( element.parent().parent() );
        //         }

        //         else {
        //             error.insertAfter(element);
        //         }
        //     },
        //     validClass: "validation-valid-label"            
        // });

        var t = "rtl" === $("html").attr("dir") ? "right" : "left";
        $(".datepicker2").datepicker({
            orientation: t,
            todayBtn: "linked",
            clearBtn: !0,
            todayHighlight: !0,

            showOtherMonths: true,
            todayHighlight: true,	
            //todayBtn: true,		
            changeMonth: true,
            changeYear: true,
            yearRange: '1900:+30',
            format: 'yyyy-mm-dd',
            autoclose: true,
            container: '#div-form-modal',
        });  

        $(".inputmask-date").inputmask("9999-99-99", {
            "placeholder": "yyyy-mm-dd",
            autoUnmask: true
        });

        var e = "rtl" === $("html").attr("dir") ? "rtl" : "ltr";
        $('.select2').select2({		
            dir: e,            
            dropdownAutoWidth: !0,            
            width: "100%",     
            dropdownParent: $("#div-form-modal")                   
        });	

        // codes works on all bootstrap modal windows in application
        $('.modal').on('hidden.bs.modal', function(e){ 
            $(this).removeData('bs.modal');							
        });
        
    });
</script>

@yield('script')    