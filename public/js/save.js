	
$(document).ready(function(){
	
	// codes works on all bootstrap modal windows in application
	$('.modal').on('hidden.bs.modal', function(e){ 
		$(this).removeData('bs.modal');							
	});				
	
});	
	
function saveHeader(url)
{	
	// if($("#form-entry").valid())
	// {	
		var form = $("#form-entry")[0];
		var data = new FormData(form);

		
	
		$.ajax({
			type: "POST",
			enctype: 'multipart/form-data',
			url: url,
			data: data, //$("form#form-entry").serialize(), // serializes the form's elements.
			processData: false,
			contentType: false,
			cache: false,
			dataType: "json", 
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
			success: function(data)
			{	
				if(data['flag'] == 'success')
				{														
					if(data['next_action'] == 'reload')
					{
						window.location.href = data['url'];	

						// swal({
						// 	title: "Success!",
						// 	html: data['message'],
						// 	type: "success",
						// 	buttonsStyling: false,
						// 	confirmButtonText: "<i class='la la-info'></i> Close",
						// 	confirmButtonClass: "btn btn-success",
						// }); 

						Swal.fire({
							title: "Success!",
							html: data['message'],
							icon: "success",
							confirmButtonText: "<i class='la la-info'></i> Close",
							confirmButtonClass: "btn btn-success",
						});

						// t.fire({
						// 	title: "<strong>Success</strong>",
						// 	icon: "success",
						// 	text: data['message'],						
						// 	html: data['message'],						
						// });
						
					}
					else if(data['next_action'] == 'reload-all')
					{
						window.location.href = data['url'];	
					}
					else if(data['next_action'] == 'redirect')
					{
						window.location.href = data['url'];	
					}  
					else if(data['next_action'] == 'reload-no-alert')
					{
						window.location.href = data['url'];
					} 
					else 
					{
						$.unblockUI();
						$('#div-main-content').unblock(); 

						// swal({
						// 	title: "Success!",							
						// 	html: data['message'],
						// 	type: "success",
						// 	buttonsStyling: false,
						// 	confirmButtonText: "Close",
						// 	confirmButtonClass: "btn btn-success",
						// }); 	

						Swal.fire({
							title: "Success!",
							html: data['message'],
							icon: "success",
							confirmButtonText: "<i class='la la-info'></i> Close",
							confirmButtonClass: "btn btn-success",
						});
					}							
				} 
				else 
				{	
					$.unblockUI();
					$('#div-main-content').unblock(); 

					// swal({
					// 	title: "Error!",						
					// 	html: data['message'],
					// 	type: "error",
					// 	buttonsStyling: false,
					// 	confirmButtonText: "Close",
					// 	confirmButtonClass: "btn btn-danger",
					// }); 

					// t.fire({
					// 	title: "<strong>Error</strong>",
					// 	icon: "error",
					// 	text: "Error processing data",						
					// 	html: data['message'],						
					// });

					Swal.fire({
						title: "Error!",
						html: data['message'],
						icon: "error",
						confirmButtonText: "<i class='fas fa-times-circle'></i> Close",
						confirmButtonClass: "btn btn-danger",
					});
				}								
			},
			error: function() 
			{
				$.unblockUI();
				$('#div-main-content').unblock(); 

				// swal({
				// 	title: "Error!",
				// 	html: data['message'],
				// 	type: "error",
				// 	buttonsStyling: false,
				// 	confirmButtonText: "<i class='la la-info'></i> Close",
				// 	confirmButtonClass: "btn btn-danger",
				// });	
				
				Swal.fire({
					title: "Error!",
					html: data['message'],
					icon: "error",
					confirmButtonText: "<i class='fas fa-times-circle'></i> Close",
					confirmButtonClass: "btn btn-danger",
				});
			},
			complete: function(){
				$('#btn-save-header').prop('disabled',false);
				$.unblockUI();
				$('#div-main-content').unblock(); 
			}
		});
					
	// } 
	// else 
	// {
	// 	//alert('not valid');
	// 	$.unblockUI();
	// 	$('#div-main-content').unblock(); 
	// 	$('#btn-save-header').prop('disabled',false);
	// }					
}

function postHeader()
{						
	url = "<?php echo $url_save_header; ?>";
	
	$.ajax({
		type: "POST",
		url: url,
		data: $("form#form-entry").serialize(), // serializes the form's elements.
		dataType: "json", 
		success: function(data)
		{							
			if(data['flag'] == 'success')
			{														
				if(data['next_action'] == 'reload'){
					window.location.href = data['url'];	
				} else {
					swal({
						title: "SUCCESS",
						html: data['message'],
						type: "success",
						html: true
					});
				}							
			} else {
				const p = document.createElement('div');
				p.innerHTML = data['message'];
				p.className = 'text-danger';
				swal({
					title: "ERROR",
					icon: 'error',							
					type: "error",
					buttons: {								
						confirm: {
							text: 'Ok',
							value: true,
							visible: true,
							className: 'btn btn-danger',
							closeModal: true
						}
					},
					content: p
				});
			}								
		},
		error: function() 
		{
			swal({
				title: "ERROR",
				text: 'Error Processing Data!',
				type: "error",
				html: true
			});				
		}
	});
	
	//$('#loader').hide();						
	//$('#submitBtn').show();
	
	return true;
}

/****************************************************************
						Save and Delete Detail Modal Form
*****************************************************************/

function saveDetail(url_save_detail,table_detail_id)
{	
	// Disable the submit button
	$("#btn-save-modal").attr("disabled", true);

	// if($("#form-modal").valid())
	// {				
		var url = url_save_detail;
		
		//alert(url);
		
		$.ajax({
			type: "POST",
			url: url,
			data: $("form#form-modal").serialize(), // serializes the form's elements.					
			dataType: "json", 
			beforeSend: function()
			{
				$('#div-form-modal').block({ 
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
			success: function(data)
			{				
				if(data['flag'] == 'success')
				{	
					$('#div-form-modal').unblock(); 

					Swal.fire({
						title: "Success!",
						html: data['message'],
						icon: "success",
						confirmButtonText: "<i class='la la-info'></i> Close",
						confirmButtonClass: "btn btn-success",
					}); 
		
					$('#div-form-modal').modal('hide');						
															
					$('#' + table_detail_id).load(data['url']);																
														
					return false;
				}

				if(data['flag'] == 'error')
				{
					$('#div-form-modal').unblock(); 

					Swal.fire({
						title: "Error!",
						html: data['message'],
						icon: "error",
						confirmButtonText: "<i class='fas fa-times-circle'></i> Close",
						confirmButtonClass: "btn btn-danger",
					}); 

					// Enable the submit button
					$('#btn-save-modal').removeAttr("disabled");
				}
								
			},
			error: function(data) 
			{
				$('#div-form-modal').unblock(); 

				Swal.fire({
					title: "Error!",
					html: data['message'],
					icon: "error",
					confirmButtonText: "<i class='fas fa-times-circle'></i> Close",
					confirmButtonClass: "btn btn-danger",
				}); 

				// Enable the submit button
				$('#btn-save-modal').removeAttr("disabled");
			}
		});
	// } 
	// else 
	// {
	// 	// Enable the submit button
	// 	$('#btn-save-modal').removeAttr("disabled");
	// }					
}					

function deleteDetail(url_delete,div,data)
{					
	//alert('You have successfully deleted');
	//$('#confirmation-delete').modal('hide');//hide the modal when click yes
	
	$.ajax({
		type: "POST",
		url: url_delete, 	
		dataType: "json",	
		data: data,
		processData: false,
		contentType: false,
		cache: false,
		success: function(data)
		{
			$('#' + div).load(data['url']);						
		}
	});
}

/****************************************************************
	Save Modal Form, Other than save header and save detail
	
	Untuk Approve and Void Form Transaction							
*****************************************************************/

function saveModalForm(url)
{	
	// Disable the submit button
	$("#btn-save-modal").attr("disabled", true);

	var $form = $(this);	
	
	// if($("#form-modal").valid())
	// {	
		//alert(url);	
				
		$.ajax({
			type: "POST",
			url: url,
			data: $("form#form-modal").serialize(), // serializes the form's elements.
			dataType: "json", 	
			beforeSend: function()
			{
				$('#div-form-modal').block({ 
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
			success: function(data)
			{
				//alert(nextDiv);

				if(data['flag'] == 'success')
				{					
					$('#div-form-modal').unblock(); 
					
					window.location.href = data['url'];	
				} 
			
				if(data['flag'] == 'error')
				{
					$('#div-form-modal').unblock(); 

					Swal.fire({
						title: "Error!",
						html: data['message'],
						icon: "error",
						confirmButtonText: "<i class='fas fa-times-circle'></i> Close",
						confirmButtonClass: "btn btn-danger",
					}); 					
				}
				
			},
			error: function() 
			{	
				$('#div-form-modal').unblock(); 	

				Swal.fire({
					title: "Error!",
					html: data['message'],
					icon: "error",
					confirmButtonText: "<i class='fas fa-times-circle'></i> Close",
					confirmButtonClass: "btn btn-danger",
				});

				$('#btn-save-modal').removeAttr("disabled");
			}
		});			
							
		$('#btn-save-modal').removeAttr("disabled");
		
	// } 
	// else 
	// {				
	// 	// Enable the submit button
	// 	$('#btn-save-modal').removeAttr("disabled");
	// }							
}