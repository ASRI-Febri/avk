<?php

use Illuminate\Support\Facades\Route;

// COA
Route::get('/ac-coa', 'Accounting\COAController@inquiry');
Route::post('/ac-coa-list', 'Accounting\COAController@inquiry_data');
Route::get('/ac-coa/create/{id?}', 'Accounting\COAController@create');
Route::get('/ac-coa/update/{id}', 'Accounting\COAController@update');
Route::post('/ac-coa/save', 'Accounting\COAController@save');

// LOOKUP COA
Route::post('/ac-select-coa', 'Accounting\COAController@show_lookup');
Route::post('/ac-coa/select-multiple', 'Accounting\COAController@show_multiple_lookup');

// SEARC COA FROM AJAX FORM
Route::post('/ac-search-coa-journal-detail', 'Accounting\COAController@search_coa');

// CHART OF ACCOUNT - GROUP 1
Route::get('/ac-coa-group1', 'Accounting\COAGroup1Controller@inquiry');
Route::post('/ac-coa-group1-list', 'Accounting\COAGroup1Controller@inquiry_data');
Route::get('/ac-coa-group1/create/{id?}', 'Accounting\COAGroup1Controller@create');
Route::get('/ac-coa-group1/update/{id}', 'Accounting\COAGroup1Controller@update');
Route::post('/ac-coa-group1/save', 'Accounting\COAGroup1Controller@save');
Route::post('/ac-select-coa-group1', 'Accounting\COAController@select_group1');

// CHART OF ACCOUNT - GROUP 2
Route::get('/ac-coa-group2', 'Accounting\COAGroup2Controller@inquiry');
Route::post('/ac-coa-group2-list', 'Accounting\COAGroup2Controller@inquiry_data');
Route::get('/ac-coa-group2/create/{id?}', 'Accounting\COAGroup2Controller@create');
Route::get('/ac-coa-group2/update/{id}', 'Accounting\COAGroup2Controller@update');
Route::post('/ac-coa-group2/save', 'Accounting\COAGroup2Controller@save');
Route::post('/ac-select-coa-group2', 'Accounting\COAController@select_group2');

// CHART OF ACCOUNT - GROUP 3
Route::get('/ac-coa-group3', 'Accounting\COAGroup3Controller@inquiry');
Route::post('/ac-coa-group3-list', 'Accounting\COAGroup3Controller@inquiry_data');
Route::get('/ac-coa-group3/create/{id?}', 'Accounting\COAGroup3Controller@create');
Route::get('/ac-coa-group3/update/{id}', 'Accounting\COAGroup3Controller@update');
Route::post('/ac-coa-group3/save', 'Accounting\COAGroup3Controller@save');
Route::post('/ac-select-coa-group3', 'Accounting\COAController@select_group3');

// JOURNAL HEADER
Route::get('/ac-journal', 'Accounting\JournalController@inquiry');
Route::post('/ac-journal-list', 'Accounting\JournalController@inquiry_data');
Route::get('/ac-journal/create', 'Accounting\JournalController@create');
Route::get('/ac-journal/update/{id}', 'Accounting\JournalController@update');
Route::post('/ac-journal/save', 'Accounting\JournalController@save');
Route::post('/ac-journal/posting', 'Accounting\JournalController@posting');
Route::post('/ac-journal/save-posting', 'Accounting\JournalController@save_posting');
Route::post('/ac-journal/unposting', 'Accounting\JournalController@unposting');
Route::post('/ac-journal/save-unposting', 'Accounting\JournalController@save_unposting');
Route::post('/ac-journal/duplicate', 'Accounting\JournalController@duplicate');
Route::post('/ac-journal/save-duplicate', 'Accounting\JournalController@save_duplicate');
Route::get('/ac-journal/download-pdf/{id}', 'Accounting\JournalController@download_pdf');

// JOURNAL DETAIL
Route::get('/ac-journal-detail', 'Accounting\JournalDetailController@inquiry');
Route::post('/ac-journal-detail-list', 'Accounting\JournalDetailController@inquiry_data');
Route::post('/ac-journal-detail/create', 'Accounting\JournalDetailController@create');
Route::post('/ac-journal-detail/update/{id}', 'Accounting\JournalDetailController@update');
Route::post('/ac-journal-detail/save', 'Accounting\JournalDetailController@save');
Route::post('/ac-journal-detail/duplicate/{id}', 'Accounting\JournalDetailController@duplicate');
Route::post('/ac-journal-detail/save-duplicate', 'Accounting\JournalDetailController@save_duplicate');
Route::get('/ac-journal-detail/reload/{id}', 'Accounting\JournalDetailController@reload'); // RELOAD TABLE AFTER SAVE
Route::post('ac-journal-detail/delete', 'Accounting\JournalDetailController@delete');
Route::post('/ac-journal-detail/save-delete', 'Accounting\JournalDetailController@save_delete');

// JOURNAL ITEM
Route::get('/ac-journal-item', 'Accounting\JournalItemController@inquiry');
Route::post('/ac-journal-item-list', 'Accounting\JournalItemController@inquiry_data');
Route::get('/ac-journal-item/create', 'Accounting\JournalItemController@create');
Route::get('/ac-journal-item/update/{id}', 'Accounting\JournalItemController@update');
Route::post('/ac-journal-item/save', 'Accounting\JournalItemController@save');

// REPORT
Route::get('/ac-rpt-gl', 'Accounting\RptGLController@period');
Route::post('/ac-rpt-gl', 'Accounting\RptGLController@period_report');

Route::get('/ac-rpt-tb', 'Accounting\RptTBController@period');
Route::post('/ac-rpt-tb', 'Accounting\RptTBController@period_report');
Route::post('/ac-rpt-tb/get-detail', 'Accounting\RptTBController@get_detail_from_gl');

Route::get('/ac-rpt-bs', 'Accounting\RptBSController@balance_sheet');
Route::post('/ac-rpt-bs', 'Accounting\RptBSController@balance_sheet_report');

Route::get('/ac-rpt-pl', 'Accounting\RptPLController@period');
Route::post('/ac-rpt-pl', 'Accounting\RptPLController@period_report');