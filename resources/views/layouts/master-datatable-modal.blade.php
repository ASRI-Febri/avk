<div class="modal-header">
    <h5 class="modal-title"><i class="icon-table2"></i>{{ $form_desc }}</h5> 

    <div class="card-addon">
        <button type="button" class="btn btn-danger" data-bs-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
        </button>   
    </div>
</div>

<div class="modal-body">	

    <div class="row">	
		<div class="col-md-12">			
            
            <form id="form-modal" name="form-modal" autocomplete="off" enctype="multipart/form-data" class="" action="#" role="form" method="post">

            <!-- FOR SEARCHING FORM OR CUSTOM FIELD -->
            <div class="card portlet text-start border">
                <div class="card-body">
                    @yield('advance-search')

                    <div class="row mb-1">
                        <div class="col-6">
                            <button id="btn-search" class="btn btn-success"><i class="fas fa-search me-2"></i>Search</button>
                        </div>
                    </div>
                </div>
            </div>

            <div class="">
                <table id="datatable" class="table table-bordered table-striped">
                    <thead>
                        <tr>
                            <?php            
                            foreach ($table_header as $header){
                                echo '<th>'.$header.'</th>';
                            }  
                            ?>									
                        </tr>
                    </thead>	
                    {{-- <tfoot>
                        <tr>
                            <?php            
                            foreach ($table_footer as $footer){
                                if(trim($footer !== '' && $footer !== 'Action')){
                                    echo '<td>'.$footer.'</td>';
                                } else if(trim($footer !== '' && $footer == 'Action')){
                                    echo '<td class="action"></td>';
                                } else {
                                    echo '<td class="hide-search"></td>';
                                }
                                
                            }  
                            ?>									
                        </tr>
                    </tfoot>							 --}}
                </table>            
            </div>	
            
            </form>
            
		</div>
	</div>

</div>

<div class="modal-footer">
    <button id="btn-close-modal" class="btn btn-danger" data-bs-dismiss="modal">Close</button>	
    
    @yield('button')
</div>

{{-- <style>
	tfoot {
		display: table-header-group;
	}
</style> --}}

<script>

    $(document).ready(function()
    {
        $('.tip').tooltip();
        $("input:text").focus(function() { $(this).select(); } );

        // Individual column searching with text inputs
        // $('#datatable tfoot td').each(function ()
        // {            
        //     if($(this).hasClass("hide-search"))
        //     {
                
        //     } 
        //     else if($(this).hasClass("action"))
        //     {
        //         $(this).html('<button id="btn-search" class="btn btn-outline-success btn-icon btn-sm" title="Search data"><i class="fas fa-search"></i></button>');	
        //     } 
        //     else 
        //     {  
        //         var title = $('#datatable thead th').eq($(this).index()).text();
        //         var column_name = $('#datatable tfoot td').eq($(this).index()).text();				

        //         $(this).html('<input id="'+column_name+'" name="'+column_name+'" type="text" class="form-control input-sm text-danger" placeholder="Search '+title+'"/>');
        //     }		
        // });

        $("input").keyup(function(e){
            if(e.which == 13)
            {
                $('#btn-search').click();
            }
        });
        
        var table = $('#datatable').DataTable({
            stateSave: false,
            processing: true,
            serverSide: true,
            filter: true,
            responsive: true,
            autoWidth: false,
            pagingType: 'full_numbers',
            serverMethod: "POST",
            ajax: {
                url: "{{ $url_search }}",                
                data: function ( d ) {
                    return $.extend( {}, d, {	
                        @php 
                            foreach($array_filter as $field):										
                                echo '"'.$field.'":$(\'#'.$field.'\').val(),'."\n";																				
                            endforeach;										
                        @endphp 									
                        "_token": "{{ csrf_token() }}"								
                    });
                } 
            },   
            @yield('datatables_array') 
        });

        $('#btn-search').click(function (e) {	
            table.draw();
            e.preventDefault();  
        });

        $("#datatable_filter").hide(); 

    });

    @yield('script')

</script>