<?php

use Illuminate\Support\Facades\Route;

// ================================================================================================
// EZITAMA
// ================================================================================================

// 1. UPLOAD EXCEL EZITAMA
Route::get('/qp-upload-ezitama', 'Parking\UploadController@upload_excel_ezitama');
Route::post('/qp-upload-ezitama', 'Parking\UploadController@upload_excel_ezitama_save');

// 2. CONFIRMATION & SAVE DATA FROM EZITAMA INTO SALES INVOICE
Route::get('/qp-upload-ezitama/result/{id}', 'Parking\UploadController@upload_excel_ezitama_result');
Route::get('/qp-upload-ezitama-member/result/{id}', 'Parking\UploadController@upload_excel_ezitama_result');
Route::get('/qp-upload-ezitama/update/{id}', 'Parking\UploadController@update_ezitama');
Route::post('/qp-upload-ezitama/save-result', 'Parking\UploadController@upload_excel_ezitama_result_save');

// 3. UPLOAD EXCEL EZITAMA - HISTORY
Route::get('/qp-upload-ezitama-sales-history', 'Parking\UploadController@ezitama_sales');
Route::post('/qp-upload-ezitama-sales-history-list', 'Parking\UploadController@ezitama_sales_inquiry_data');
Route::get('/qp-upload-ezitama-member-history', 'Parking\UploadController@ezitama_member');
Route::post('/qp-upload-ezitama-member-history-list', 'Parking\UploadController@ezitama_member_inquiry_data');

// ================================================================================================
// OTHERS LOCATION
// ================================================================================================

// 1. UPLOAD EXCEL OTHERS
Route::get('/qp-upload-other', 'Parking\UploadController@upload_excel_other');
Route::post('/qp-upload-other', 'Parking\UploadController@upload_excel_other_save');

// 2. CONFIRMATION & SAVE DATA FROM OTHERS LOCATION
Route::get('/qp-upload-other/result/{id}', 'Parking\UploadController@upload_excel_other_result');
Route::get('/qp-upload-other/save-result', 'Parking\UploadController@upload_excel_other_result_save');
Route::get('/qp-upload-other/update/{id}', 'Parking\UploadController@update_other');

// 3. UPLOAD EXCEL OTHERS - HISTORY
Route::get('/qp-upload-other-history', 'Parking\UploadController@other');
Route::post('/qp-upload-other-history-list', 'Parking\UploadController@other_inquiry_data');

// 1. ENTRY DATA PARKING FROM OTHERS LOCATION
Route::get('/qp-other-location', 'Parking\OtherLocationController@inquiry');
Route::post('/qp-other-location-list', 'Parking\OtherLocationController@inquiry_data');
Route::get('/qp-other-location/create', 'Parking\OtherLocationController@create');
Route::get('/qp-other-location/update/{id}', 'Parking\OtherLocationController@update');
Route::post('/qp-other-location/save', 'Parking\OtherLocationController@save');
Route::post('/qp-other-location/approve', 'Parking\OtherLocationController@approve');
Route::post('/qp-other-location/save-approve', 'Parking\OtherLocationController@save_approve');

// 2. ENTRY DATA MEMBER FROM OTHERS LOCATION
Route::get('/qp-other-member', 'Parking\OtherMemberController@inquiry');
Route::post('/qp-other-member-list', 'Parking\OtherMemberController@inquiry_data');
Route::get('/qp-other-member/create', 'Parking\OtherMemberController@create');
Route::get('/qp-other-member/update/{id}', 'Parking\OtherMemberController@update');
Route::post('/qp-other-member/save', 'Parking\OtherMemberController@save');
Route::post('/qp-other-member/approve', 'Parking\OtherMemberController@approve');
Route::post('/qp-other-member/save-approve', 'Parking\OtherMemberController@save_approve');