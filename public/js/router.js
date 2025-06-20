function initUI()
{
	$(".datepicker").datepicker({
		showOtherMonths: true,
		todayHighlight: true,	
		todayBtn: true,		
		changeMonth: true,
		changeYear: true,
		yearRange: '1900:+30',
		format: 'yyyy-mm-dd',
		autoclose: true
	});
	
	$('.select2').select2({		
		theme: 'bootstrap4',
		width: "100%",
		placeholder: $(this).attr('placeholder'),		
	});	

	$(".inputmask-date").inputmask("9999-99-99", {
		"placeholder": "yyyy-mm-dd",
		autoUnmask: true
	});

	$(".inputmask-npwp").inputmask("99.999.999.9-999.999", {		
		autoUnmask: true
	});
	
	$("input:text").focus(function() { $(this).select(); } );	

	$('.modal').on('hidden.bs.modal', function(e){ 
		$('.modal-content').html('');
		$(this).removeData('bs.modal');							
	});

	$('input.auto').autoNumeric();	

	$('#form-entry,#form-modal').validate({
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
}		

function callAjaxView(url,div)
{
	// alert('click1');

	// $(this).parent().addClass('active');

	// $("#side-menu li a").click(function() {
	// 	//alert('click menu');
	// 	$("#side-menu li").removeClass('active');
	 	//$(this).parents().addClass('active');
		//$(this).parents().addClass('active').siblings().removeClass('active');
	// });

	// $('.sidebar-menu .dropdown>a').on('click', function () {
	// 	alert('click menu');
	// 	if ($(this).parent().hasClass('active'))
	// 	{            
	// 		$(this).parent().find('>.sub-menu').slideUp('slow');
	// 		$(this).parent().removeClass('active');
	// 	} else
	// 	{
		
	// 		$(this).parent().find('>.sub-menu').slideDown('slow');
	// 		$(this).parent().addClass('active');
	// 	}

	// 	return false;
	// });	

	var data = {					
		_token:$("#_token").val()
	};	
	
	$.ajax({
		type: "POST",
		url : url,
		data: data,		
		beforeSend: function()
		{	
			$('#div-main-content').block({ 
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
			$('#'+div).html(msg);   
			initUI(); 
			$.unblockUI(); 
			$('#div-main-content').unblock();                    
		},
		error: function(msg) 
		{			
			swal({
				title: "ERROR",
				text: 'Error Processing Data!',
				type: "error",
				html: 'Error while processing this request Or session expired!'
			});		
			$.unblockUI();		
			$('#div-main-content').unblock(); 
		},
		complete: function(){
			$('#btn-save-header').prop('disabled',false);
			$.unblockUI();	
			$('#div-main-content').unblock(); 		
		}
	});	
}

function callAjaxModalView(url,data)
{
	// var data = {					
	// 	_token:$("#_token").val()
	// };

	if(data == '')
	{
		data = {					
			_token:$("#_token").val()
		};
	}
	
	// GET CURRENT SCROLL TOP POSITION
	getScrollPosition();

	$.ajax({
		url: url,
		type: 'post',
		data: data,
		success: function(response){ 

			//$('body').css('overflow', 'hidden');

			//var scroll = $(window).scrollTop();
			//alert(scroll);			

			// Add response in Modal body
			$('.modal-content').html(response);

			// Display Modal
			$('#div-form-modal').modal('show'); 

			//initUI(); 
		}
	});
}

function callAjaxModalView2(url,data)
{
	// var data = {					
	// 	_token:$("#_token").val()
	// };

	if(data == '')
	{
		data = {					
			_token:$("#_token").val()
		};
	}
	
	// GET CURRENT SCROLL TOP POSITION
	getScrollPosition();

	$.ajax({
		url: url,
		type: 'post',
		data: data,
		success: function(response){ 

			//$('body').css('overflow', 'hidden');

			//var scroll = $(window).scrollTop();
			//alert(scroll);			

			// Add response in Modal body
			$('#modal-content-2').html(response);

			// Display Modal
			$('#div-form-modal-2').modal('show'); 

			//initUI(); 
		}
	});

}

function initSelect2()
{
	$('.select2').select2({
		width: "100%"
	});
}
		
	