@extends('layouts.master')

@section('topbar-title')
    {{ $form_title }}
@endsection

@section('title')
    {{ $form_title }}
@endsection

@section('sub-title')
    {{ $form_sub_title }}
@endsection

@section('css')

    <!-- DataTables -->
    <link href="{{ URL::asset('assets/libs/datatables.net-bs5/css/dataTables.bootstrap5.min.css') }}" rel="stylesheet" type="text/css" />

    <!-- searchpanes datatable examples -->
    <link href="{{ URL::asset('assets/libs/datatables.net-searchpanes-bs5/css/searchPanes.bootstrap5.min.css') }}" rel="stylesheet" type="text/css" />

    <!-- Responsive datatable -->
    <link href="{{ URL::asset('assets/libs/datatables.net-responsive-bs5/css/responsive.bootstrap5.min.css') }}" rel="stylesheet" type="text/css" />

    <style>
		tfoot {
			display: table-header-group;
		}
	</style>

@endsection

@section('content')

    <div class="row">
        <div class="col-12">
            <div class="card">
                <div class="card-header">
                    <h4 class="card-title">{{ $form_sub_title }}</h4>

                    <div class="card-addon">
                        <x-btn-create-new label="Create New" :url="$url_create" />
                    </div>
                </div>

                <div class="card-body">

                    <div class="alert alert-label-info">
                        {{ $form_remark ?? '' }}
                    </div>

                    {{-- <div class="card border">
                        <div class="card-body pb-0">
                            <p class="text-muted">
                                {{ $form_description ?? '' }}
                            </p>
                        </div>
                    </div> --}}

                    {{-- <div class="row mb-3">
                        @foreach ($table_footer as $footer)
                            @if(trim($footer !== '' && $footer !== 'Action'))
                                <div class="col-4">
                                    <div class="input-group">
                                        <span class="input-group-text" id="inputGroup-sizing-default">{{ $footer }}</span> 
                                        <input id="{{ $footer }}" type="text" class="form-control" />
                                    </div>
                                </div>
                            @endif
                        @endforeach
                    </div> --}}

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
                    
                    
                    
                    <div class="table-responsive">
                        <table id="datatable" class="table table-bordered table-striped">
                            <thead>
                                <tr>
                                    <?php            
                                    foreach ($table_header as $header){
                                        echo '<th class="text-secondary">'.$header.'</th>';
                                    }  
                                    ?>									
                                </tr>
                                {{-- <tr>
                                    @foreach ($table_footer as $footer)
                                        @if(trim($footer !== '' && $footer !== 'Action'))
                                            <td>
                                                <input id="{{ $footer }}" name="{{ $footer }}" type="text" placeholder="Search Name" class="form-control input-sm text-danger" />
                                            </td>
                                        @elseif(trim($footer !== '' && $footer == 'Action'))
                                            <td class="action">

                                            </td>
                                        @else 
                                            <td class="hide-search"></td>
                                        @endif
                                    @endforeach
                                </tr> --}}
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
                </div>
            </div>
        </div>
    </div>

@endsection

@section('script')
    
    {{-- <!-- Required datatable js -->
    <script src="{{ URL::asset('assets/libs/datatables.net/js/jquery.dataTables.min.js') }}"></script>
    <script src="{{ URL::asset('assets/libs/datatables.net-bs5/js/dataTables.bootstrap5.min.js') }}"></script> --}}

    <script>
        $(document).ready(function ()
        {
            @yield('active_link')        

            // Individual column searching with text inputs
            // $('#datatable tfoot td').each(function ()
            // {            
            //     if($(this).hasClass("hide-search"))
            //     {
                    
            //     } 
            //     else if($(this).hasClass("action"))
            //     {
            //         $(this).html('<button id="btn-search" class="btn btn-warning btn-icon btn-sm" title="Search data"><i class="fas fa-search"></i></button>');	
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

            $("input:text").focus(function() { $(this).select(); } );

            //var table = $('#datatable');

            // Move tfoot before tbody
            //table.children('tfoot').insertBefore(table.children('tbody'));
            
            //var table = $('#datatable').DataTable({

            //table.DataTable({
            var table = $('#datatable').DataTable({
                stateSave: false,
                processing: true,
                language: {
                    "processing": "Loading. Please wait..."
                },
                serverSide: true,
                filter: true,
                responsive: true,
                autoWidth: false,
                order: [1, 'desc'],
                paging: true,
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
                            @yield('custom_filter')											
                            "_token": "{{ csrf_token() }}"								
                        });
                    } 
                },   
                @yield('datatables_array') 
            });

            // table.state.clear();
            // table.destroy();

            // Enable Select2 select for the length option
           // $('.dataTables_length select').select2({
                // minimumResultsForSearch: Infinity,
                // width: 'auto'
            //});

            $('#btn-search').click(function (e) {	
                table.draw();
                e.preventDefault();  
            });

            $("#datatable_filter").hide();     

            // Move tfoot before tbody
            table.children('tfoot').insertBefore(table.children('tbody'));

        });

        function editData(id,url)
        {  
            callAjaxView(url+'/'+id,'div-main-content');
        }

        function commaSeparateNumber(val)
        {	
            /*
            while (/(\d+)(\d{3})/.test(val.toString())) {
                val = val.toString().replace(/(\d+)(\d{3})/, '$1' + ',' + '$2');
            }
            return val;
            */

            
            val = parseFloat(val).toLocaleString('en')
            return val;
            
        }

        function addCommas(nStr)
        {
            nStr += '';
            x = nStr.split('.');		

            x1 = x[0];
            x2 = x.length > 1 ? '.' + x[1] : '';
            var rgx = /(\d+)(\d{3})/;
            while (rgx.test(x1)) {
                x1 = x1.replace(rgx, '$1' + ',' + '$2');
            }
            //return x1 + x2;
            return x1;			
        }

        @yield('additional_script')
        
    </script>

@endsection