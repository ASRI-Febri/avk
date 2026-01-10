<!-- JAVASCRIPT -->
<script src="{{ URL::asset('assets/libs/jquery/jquery.min.js') }}"></script>
<script src="{{ URL::asset('assets/libs/bootstrap/js/bootstrap.bundle.min.js') }}"></script>
<script src="{{ URL::asset('assets/libs/metismenu/metisMenu.min.js') }}"></script>
<script src="{{ URL::asset('assets/libs/simplebar/simplebar.min.js') }}"></script>
<script src="{{ URL::asset('assets/libs/node-waves/waves.min.js') }}"></script>

<!-- FORM VALIDATION -->
<script src="{{ URL::asset('assets/libs/parsleyjs/parsley.min.js') }}"></script>
<script src="{{ URL::asset('assets/js/pages/form-validation.init.js') }}"></script>

<!-- SWEETALERT -->
<script src="{{ URL::asset('assets/libs/sweetalert2/sweetalert2.min.js') }}"></script>

<!-- blockUI -->
<script src="{{ URL::asset('assets/libs/block-ui/jquery.blockUI.js') }}"></script>

<!-- SELECT2 -->
<script src="{{ URL::asset('assets/libs/select2/js/select2.min.js') }}"></script>

<!-- DATEPICKER -->
<script src="{{ URL::asset('assets/libs/bootstrap-datepicker/js/bootstrap-datepicker.min.js') }}"></script>
{{-- <script src="{{ URL::asset('assets/js/pages/form-datepicker.init.js') }}"></script> --}}

<!-- AUTO NUMERIC -->
<script src="{{ URL::asset('public/js/autoNumeric-1.6.2.js') }}"></script>

<!-- INPUT MASK -->
<script src="{{ URL::asset('assets/libs/inputmask/jquery.inputmask.min.js') }}"></script>

<!-- DATATABLE -->
<script src="{{ URL::asset('assets/libs/datatables.net/js/jquery.dataTables.min.js') }}"></script>
<script src="{{ URL::asset('assets/libs/datatables.net-bs5/js/dataTables.bootstrap5.min.js') }}"></script>

<!-- COMPONENT SCRIPT -->
<script>
    function clearMe(a) { document.getElementById(a).value = ''; }
    
    function getScrollPosition()
    {
        var scroll = $(window).scrollTop();
        $("#scroll-position").val(scroll);
    }

    $(document).ready(function(){
        $('input.auto').autoNumeric();

        $("input:text").focus(function(){ 
            $(this).select();
        });

        var t = "rtl" === $("html").attr("dir") ? "right" : "left";
        $(".datepicker2").datepicker({
            //orientation: t,
            orientation: "bottom auto",
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
            zIndexOffset: 9999999,
        });

        $('.readonly').attr('readonly', true);

        var e = "rtl" === $("html").attr("dir") ? "rtl" : "ltr";
        $('.select2').select2({		
            dir: e,            
            dropdownAutoWidth: !0,            
            width: "100%",                        
        });	

    });

</script>

@yield('script')

<script src="{{ URL::asset('assets/js/app.js') }}"></script>
