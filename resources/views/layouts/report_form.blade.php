@extends('layouts.master')

@section('content')  

    @include('form_helper.header_breadcrumb')

    {{-- <!-- START: Breadcrumbs-->
    <div class="row">
        <div class="col-12  align-self-center">
            <div class="sub-header mt-3 py-3 align-self-center d-sm-flex w-100 rounded">
                <div class="w-sm-100 mr-auto">
                    <h4 class="mb-0">{{ $form_title ?? '' }}</h4>
                    <p>{{ $form_sub_title ?? '' }}</p>
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
                                $class = 'class="breadcrumb-item active text-primary"';
                            }
                            echo '<li ' . $class . '>'.$bread.'</li>';
                        }  
                    @endphp	                
                </ol>
            </div>
        </div>
    </div>
    <!-- END: Breadcrumbs--> --}}

    <!-- BEGIN FORM -->
    <form id="form-report" name="form-report" enctype="multipart/form-data" action="{{ $url_show_repoprt }}" role="form" method="post" target="_blank">   
        <input type="hidden" id="_token" name="_token" value="{{ csrf_token() }}"/> 
        <input type="hidden" id="state" name="state" value="{{ $state ?? '' }}"/>    

        <!-- BEGIN ROW -->
        <div class="row">
            <div class="col-12">
                <div class="card outline-badge-primary">
                    <div class="card-content">
                        <div class="card-body p-2">
                            <div class="d-md-flex">
                                <p class="mb-0 my-auto font-w-500 tx-s-12">@yield('form_remark')</p>
                                <div class="my-auto ml-auto">
                                    <a href="#" class="btn btn-outline-primary font-w-600 my-auto text-nowrap"><i
                                            class="fas fa-info"></i></a>
                                </div>
                            </div>
        
                        </div>
                    </div>
                </div>
            </div>    
            <div class="col-12 col-lg-12  mt-3">
                <div class="card">
                    <div class="card-header bg-transparent">
                        <div class="row">
                            <div class="text-left col-md-6 col-sm-12">
                                @yield('left_header')                           
                            </div>                    
                            <div class="text-right col-md-6 col-sm-12">
                                @yield('right_header')
                            </div>
                        </div>
                    </div>
                    <div class="card-body"> 
                        @yield('content_form')   

                        @include('form_helper.btn_show_report')
                    </div>
                </div>
            </div>          
        </div>
        <!-- END ROW -->

    </form>
    <!-- END FORM -->
@endsection

@section('script')
    @yield('script') 

    <script>
        $(document).ready(function(){   
            $('input.auto').autoNumeric();
            $("input:text").focus(function() { $(this).select(); } );

            $('#form-report').validate({
                errorClass: 'text-danger',
                successClass: 'text-success',					
                
                highlight: function(element, errorClass) {
                    //$(element).removeClass(errorClass);
                },
                unhighlight: function(element, errorClass) {
                    $(element).removeClass(errorClass);
                },
                errorPlacement: function(error, element) {
                    // Styled checkboxes, radios, bootstrap switch
                    if (element.parents('div').hasClass("checker") || element.parents('div').hasClass("choice") || element.parent().hasClass('bootstrap-switch-container') ) {
                        if(element.parents('label').hasClass('checkbox-inline') || element.parents('label').hasClass('radio-inline')) {
                            error.appendTo( element.parent().parent().parent().parent() );
                        }
                        else {
                            error.appendTo( element.parent().parent().parent().parent().parent() );
                        }
                    }

                    // Unstyled checkboxes, radios
                    else if (element.parents('div').hasClass('checkbox') || element.parents('div').hasClass('radio')) {
                        error.appendTo( element.parent().parent().parent() );
                    }

                    // Input with icons and Select2
                    else if (element.parents('div').hasClass('has-feedback') || element.hasClass('select2-hidden-accessible')) {
                        error.appendTo( element.parent() );
                    }

                    // Inline checkboxes, radios
                    else if (element.parents('label').hasClass('checkbox-inline') || element.parents('label').hasClass('radio-inline')) {
                        error.appendTo( element.parent().parent() );
                    }

                    // Input group, styled file input
                    else if (element.parent().hasClass('uploader') || element.parents().hasClass('input-group')) {
                        error.appendTo( element.parent().parent() );
                    }

                    else {
                        error.insertAfter(element);
                    }
                },
                validClass: "validation-valid-label"            
            });
        });
    </script>
@endsection
