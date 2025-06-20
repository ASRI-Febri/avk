<?php

use Illuminate\Support\Facades\Route;

// VALAS LIST
Route::get('/mc-valas', 'MoneyChanger\ValasController@inquiry');
Route::post('/mc-valas-list', 'MoneyChanger\ValasController@inquiry_data');
Route::get('/mc-valas/create', 'MoneyChanger\ValasController@create');
Route::get('/mc-valas/update/{id}', 'MoneyChanger\ValasController@update');
Route::get('/mc-valas/duplicate/{id}', 'MoneyChanger\ValasController@duplicate');
Route::post('/mc-valas/save', 'MoneyChanger\ValasController@save');

// VALAS CHANGE LIST
Route::get('/mc-valas-change', 'MoneyChanger\ValasChangeController@inquiry');
Route::post('/mc-valas-change-list', 'MoneyChanger\ValasChangeController@inquiry_data');
Route::get('/mc-valas-change/create', 'MoneyChanger\ValasChangeController@create');
Route::get('/mc-valas-change/update/{id}', 'MoneyChanger\ValasChangeController@update');
Route::post('/mc-valas-change/save', 'MoneyChanger\ValasChangeController@save');

// PURCHASE ORDER
Route::get('/mc-purchase-order', 'MoneyChanger\PurchaseOrderController@inquiry');
Route::post('/mc-purchase-order-list', 'MoneyChanger\PurchaseOrderController@inquiry_data');
Route::get('/mc-purchase-order/create', 'MoneyChanger\PurchaseOrderController@create');
Route::get('/mc-purchase-order/update/{id}', 'MoneyChanger\PurchaseOrderController@update');
Route::post('/mc-purchase-order/save', 'MoneyChanger\PurchaseOrderController@save');
Route::post('/mc-purchase-order/approve', 'MoneyChanger\PurchaseOrderController@approve');
Route::post('/mc-purchase-order/save-approve', 'MoneyChanger\PurchaseOrderController@save_approve');
Route::post('/mc-purchase-order/reverse', 'MoneyChanger\PurchaseOrderController@reverse');
Route::post('/mc-purchase-order/save-reverse', 'MoneyChanger\PurchaseOrderController@save_reverse');
Route::get('/mc-purchase-order/download-pdf/{id}', 'MoneyChanger\PurchaseOrderController@download_pdf');
Route::post('/mc-purchase-order/duplicate', 'MoneyChanger\PurchaseOrderController@duplicate');
Route::post('/mc-purchase-order/save-duplicate', 'MoneyChanger\PurchaseOrderController@save_duplicate');

// PURCHASE ORDER - DETAIL
Route::get('/mc-purchase-order-detail', 'MoneyChanger\PurchaseOrderDetailController@inquiry');
Route::post('/mc-purchase-order-detail-list', 'MoneyChanger\PurchaseOrderDetailController@inquiry_data');
Route::post('/mc-purchase-order-detail/create', 'MoneyChanger\PurchaseOrderDetailController@create');
Route::post('/mc-purchase-order-detail/update/{id}', 'MoneyChanger\PurchaseOrderDetailController@update');
Route::post('/mc-purchase-order-detail/save', 'MoneyChanger\PurchaseOrderDetailController@save');
Route::get('/mc-purchase-order-detail/reload/{id}', 'MoneyChanger\PurchaseOrderDetailController@reload'); // RELOAD TABLE AFTER SAVE
Route::post('mc-purchase-order-detail/delete/{id?}', 'MoneyChanger\PurchaseOrderDetailController@delete');
Route::post('/mc-purchase-order-detail/save-delete', 'MoneyChanger\PurchaseOrderDetailController@save_delete');

// STOCK CARD SUMMARY
Route::get('/mc-stock-card', 'MoneyChanger\StockCardController@inquiry');
Route::post('/mc-stock-card-list', 'MoneyChanger\StockCardController@inquiry_data');

// LOOKUP BUSINESS PARTNER
Route::post('/mc-partner-list', 'MoneyChanger\PurchaseOrderController@inquiry_data_partner');
Route::post('/mc-select-partner', 'MoneyChanger\PurchaseOrderController@show_lookup_partner');


Route::get('/mc-sop', 'MoneyChanger\PurchaseOrderController@sop');