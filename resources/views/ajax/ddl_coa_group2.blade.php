<x-select-horizontal label="COA Group 2" id="COAGroup2" value="" class="" :array="$dd_coa_group2"/>
                
<div id="div-coa-group3">
    <x-select-horizontal label="COA Group 3" id="COAGroup3" value="" class="" :array="$dd_coa_group3"/>
</div>

<script>
    $('#COAGroup2, #COAGroup3').select2({            
        width: "100%"
    });    

    $("#COAGroup2").change(function(){
        var data = {
            _token: $('#_token').val(),
            COAGroup2:$("#COAGroup2").val()
        };

        $.ajax({
                type: "POST",
                url : "{{ url('ac-select-coa-group3') }}",
                data: data,
                beforeSend: function()
                {
                    $('#div-coa-group3').block({ 
                        message: '<span class="text-semibold"><i class="fa fa-spinner spinner position-center"></i>&nbsp; Loading...</span>', 
                        overlayCSS: {
                            backgroundColor: '#fff',
                            opacity: 0.8,
                            cursor: 'wait'
                        },
                        css: {
                            border: 0,
                            padding: '10px 15px',
                            color: '#fff',
                            width: 'auto',
                            '-webkit-border-radius': 2,
                            '-moz-border-radius': 2,
                            backgroundColor: '#333'
                        }
                    });	
                },
                success: function(msg){
                    $('#div-coa-group3').unblock();
                    $('#div-coa-group3').html(msg);
                }
        });
    });
</script>