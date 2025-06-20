@extends('layouts.master-without-nav')

@section('title')
    Login
@endsection

@section('css')
@endsection

@section('content')
    <div class="container-fluid authentication-bg overflow-hidden">
        <div class="bg-overlay"></div>
        <div class="row align-items-center justify-content-center min-vh-100">
            <div class="col-10 col-md-6 col-lg-4 col-xxl-3">
                <div class="card mb-0">
                    <div class="card-body">
                        <div class="text-center">
                            <a href="#" class="logo-dark">
                                <img src="{{ URL::asset('assets/images/avk-logo.png') }}" alt="" height="40"
                                    class="auth-logo logo-dark mx-auto">                                    
                            </a>
                            <a href="#" class="logo-light">
                                <img src="{{ URL::asset('assets/images/avk-logo.png') }}" alt="" height="40"
                                    class="auth-logo logo-light mx-auto">                                    
                            </a>


                            <h4 class="mt-4">Welcome Back !</h4>
                            <p class="text-muted">Sign in to continue.</p>
                        </div>

                        <div class="p-2 mt-5">
                            <form id="form-login" autocomplete="off" action="{{ $url }}" method="post">

                                <!-- CSRF TOKEN -->
                                <input type="hidden" id="_token" name="_token" value="{{ csrf_token() }}"/>

                                <div class="input-group auth-form-group-custom mb-3">
                                    <span class="input-group-text bg-primary bg-opacity-10 fs-16 " id="basic-addon1"><i
                                            class="mdi mdi-account-outline auti-custom-input-icon"></i></span>
                                    <input type="text" id="UserID" name="UserID" class="form-control" placeholder="Enter username"
                                        aria-label="UserID" aria-describedby="basic-addon1">
                                </div>

                                <div class="input-group auth-form-group-custom mb-3">
                                    <span class="input-group-text bg-primary bg-opacity-10 fs-16" id="basic-addon2"><i
                                            class="mdi mdi-lock-outline auti-custom-input-icon"></i></span>
                                    <input type="password" id="UserPassword" name="UserPassword" class="form-control" id="userpassword"
                                        placeholder="Enter password" aria-label="UserPassword" aria-describedby="basic-addon1">
                                </div>

                                <div class="mb-sm-5">
                                    {{-- <div class="form-check float-sm-start">
                                        <input type="checkbox" class="form-check-input" id="customControlInline">
                                        <label class="form-check-label" for="customControlInline">Remember me</label>
                                    </div> --}}
                                    <div class="float-sm-end">
                                        <a href="#" class="text-muted"><i class="mdi mdi-lock me-1"></i>
                                            Forgot your password?</a>
                                    </div>
                                </div>

                                <div class="pt-3 text-center">
                                    <button id="btn-submit" class="btn btn-primary w-xl waves-effect waves-light" type="button">Log
                                        In</button>
                                </div>

                                {{-- <div class="mt-3 text-center">
                                    <p class="mb-0">Don't have an account ? <a href="auth-register.html"
                                            class="fw-medium text-primary"> Register </a> </p>
                                </div>

                                <div class="mt-4 text-center">
                                    <div class="signin-other-title position-relative">
                                        <h5 class="mb-0 title">or</h5>
                                    </div>
                                    <div class="mt-4 pt-1 hstack gap-3">
                                        <div class="vstack gap-2">
                                            <button type="button" class="btn btn-label-info d-block"><i
                                                    class="ri-facebook-fill fs-18 align-middle me-2"></i>Sign in with
                                                facebook</button>
                                            <button type="button" class="btn btn-label-danger d-block"><i
                                                    class="ri-google-fill fs-18 align-middle me-2"></i>Sign in with
                                                google</button>
                                        </div>
                                        <div class="vstack gap-2">
                                            <button type="button" class="btn btn-label-dark d-block"><i
                                                    class="ri-github-fill fs-18 align-middle me-2"></i>Sign in with
                                                github</button>
                                            <button type="button" class="btn btn-label-success d-block"><i
                                                    class="ri-twitter-fill fs-18 align-middle me-2"></i>Sign in with
                                                twitter</button>
                                        </div>

                                    </div>
                                </div> --}}
                            </form>
                        </div>

                        <div class="mt-5 text-center">
                            <p>©
                                <script>
                                    document.write(new Date().getFullYear())
                                </script> Federasoft
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection

@section('script')
    {{-- <script src="{{ URL::asset('assets/js/app.js') }}"></script> --}}

    <script>

        $(document).ready(function() {

            $("#UserID").focus();

            $("input:text").focus(function() { $(this).select(); } );

            $(document).keypress(function(e) {
                if(e.which == 13) {
                    $('#btn-submit').click();
                }
            });

            $("#UserPassword").keypress(function(e) {
                if(e.which == 13) {
                    $('#btn-submit').click();
                }
            });

            // $("#form-login").validate({
					
            //     errorClass: 'text-danger',
            //     successClass: 'validation-valid-label',					
                
            //     highlight: function(element, errorClass) {
            //         $(element).removeClass(errorClass);
            //     },
            //     unhighlight: function(element, errorClass) {
            //         $(element).removeClass(errorClass);
            //     },                
            //     validClass: "validation-valid-label",
            //     /*
            //     success: function(label) {
            //         label.addClass("validation-valid-label").text("Successfully")
            //     },
            //     */
            //     rules: {
            //         'UserID': {
            //             required: true,
            //             minlength: 3
            //         },
            //         'UserPassword': {
            //             required: true,
            //             minlength: 5
            //         }
            //     },
            //     messages: {
            //         'UserID': {
            //             required: 'Please enter your User ID',
            //             minlength: 'Your username must consist of at least 3 characters'
            //         },
            //         'UserPassword': {
            //             required: 'Please provide a password',
            //             minlength: 'Your password must be at least 5 characters long'
            //         }
            //     }
            // });

            $('#btn-submit').click(function (e){			
					
                e.preventDefault();			
                
                var t = Swal.mixin({
                    toast: !0,
                    position: "top-end",
                    //position: "top",
                    showConfirmButton: !1,
                    timer: 3e3,
                    timerProgressBar: !0,
                    didOpen: function(t) {
                        t.addEventListener("mouseenter", Swal.stopTimer), t.addEventListener("mouseleave", Swal.resumeTimer)
                    }
                });

                // if($("#form-login").valid())
                // {							
                    url = "{{ $url }}";				
                    
                    $.ajax({
                        type: "POST",
                        url: url,
                        data: $("form#form-login").serialize(), // serializes the form's elements.
                        dataType: "json", 
                        success: function(data)
                        {							
                            if(data['flag'] == 'success')
                            {							
                                t.fire({
                                    icon:"success",
                                    title:"Signed in successfully"
                                });

                                window.location.href = data['url_next'];
                                
                            } else {	
                                
                                //alert('error nih');

                                

                                t.fire({
                                    icon:"error",
                                    title:"Signed in failed",
                                    //text: data['message'],
                                    html: data['message'],
                                });

                                // swal({
                                //     title: "Error",
                                //     text: data['message'],
                                //     type: "error",
                                //     html: true
                                // });
                    
                                $("#UserID").focus();
                            }								
                        },
                        error: function() 
                        {
                            //if fails 
                            alert('Error Processing Data!');
                            
                            $("#UserID").focus();
                        }
                    });
                                            
                    return true;
                    
                // } else {
                    
                //     $("#UserID").focus();
                // }
                
            });	

        });

    </script>

@endsection
