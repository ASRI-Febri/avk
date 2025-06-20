<?php

use Illuminate\Support\Facades\Route;

// VENDOR
Route::get('/pr-vendor', 'Procurement\VendorController@inquiry');
Route::post('/pr-vendor-list', 'Procurement\VendorController@inquiry_data');
Route::get('/pr-vendor/create', 'Procurement\VendorController@create');
Route::get('/pr-vendor/update/{id}', 'Procurement\VendorController@update');
Route::post('/pr-vendor/save', 'Procurement\VendorController@save');

// LOOKUP VENDOR
Route::post('/pr-select-vendor', 'Procurement\VendorController@show_lookup');

// VENDOR ADDRESS
Route::post('/pr-vendor-address/create', 'Procurement\VendorAddressController@create');
Route::post('/pr-vendor-address/update/{id}', 'Procurement\VendorAddressController@update');
Route::post('/pr-vendor-address/save', 'Procurement\VendorAddressController@save');
Route::post('/pr-vendor-address/delete', 'Procurement\VendorAddressController@delete');
Route::post('/pr-vendor-address/save-delete', 'Procurement\VendorAddressController@save_delete');
Route::get('/pr-vendor-address/reload/{id}', 'Procurement\VendorAddressController@reload');

// POSTAL CODE
Route::post('/search-postal-code', 'General\PostalCodeController@search_postal_code');

// VENDOR BANK
Route::post('/pr-vendor-bank/create', 'Procurement\VendorBankController@create');
Route::post('/pr-vendor-bank/update/{id}', 'Procurement\VendorBankController@update');
Route::post('/pr-vendor-bank/save', 'Procurement\VendorBankController@save');
Route::post('/pr-vendor-bank/delete', 'Procurement\VendorBankController@delete');
Route::post('/pr-vendor-bank/save-delete', 'Procurement\VendorBankController@save_delete');
Route::get('/pr-vendor-bank/reload/{id}', 'Procurement\VendorBankController@reload');

// ITEM
Route::get('/pr-item', 'Procurement\ItemController@inquiry');
Route::post('/pr-item-list', 'Procurement\ItemController@inquiry_data');
Route::get('/pr-item/create', 'Procurement\ItemController@create');
Route::get('/pr-item/update/{id}', 'Procurement\ItemController@update');
Route::post('/pr-item/save', 'Procurement\ItemController@save');
Route::post('/pr-item/search', 'Procurement\ItemController@search_item');

// PROJECT
Route::get('/pr-project', 'Procurement\ProjectController@inquiry');
Route::post('/pr-project-list', 'Procurement\ProjectController@inquiry_data');
Route::get('/pr-project/create/{id?}', 'Procurement\ProjectController@create');
Route::get('/pr-project/update/{id}', 'Procurement\ProjectController@update');
Route::post('/pr-project/save', 'Procurement\ProjectController@save');
Route::post('/pr-project/search', 'Procurement\ProjectController@search_item');

// PURCHASE ORDER
Route::get('/pr-purchase-order', 'Procurement\PurchaseOrderController@inquiry');
Route::post('/pr-purchase-order-list', 'Procurement\PurchaseOrderController@inquiry_data');
Route::post('/pr-purchase-order-draft-list', 'Procurement\PurchaseOrderController@inquiry_draft_data');
Route::post('/pr-purchase-order-approve-list', 'Procurement\PurchaseOrderController@inquiry_approve_data');
Route::get('/pr-purchase-order/create', 'Procurement\PurchaseOrderController@create');
Route::get('/pr-purchase-order/update/{id}', 'Procurement\PurchaseOrderController@update');
Route::post('/pr-purchase-order/save', 'Procurement\PurchaseOrderController@save');
Route::post('/pr-purchase-order/approve', 'Procurement\PurchaseOrderController@approve');
Route::post('/pr-purchase-order/save-approve', 'Procurement\PurchaseOrderController@save_approve');
Route::post('/pr-purchase-order/reverse', 'Procurement\PurchaseOrderController@reverse');
Route::post('/pr-purchase-order/save-reverse', 'Procurement\PurchaseOrderController@save_reverse');
Route::get('/pr-purchase-order/download-pdf/{id}', 'Procurement\PurchaseOrderController@download_pdf');

// LOOKUP VENDOR
Route::post('/pr-select-po', 'Procurement\PurchaseOrderController@show_lookup');

// PURCHASE ORDER DETAIL
Route::get('/pr-purchase-order-detail', 'Procurement\PurchaseOrderDetailController@inquiry');
Route::post('/pr-purchase-order-detail-list', 'Procurement\PurchaseOrderDetailController@inquiry_data');
Route::post('/pr-purchase-order-detail/create', 'Procurement\PurchaseOrderDetailController@create');
Route::post('/pr-purchase-order-detail/update/{id}', 'Procurement\PurchaseOrderDetailController@update');
Route::post('/pr-purchase-order-detail/save', 'Procurement\PurchaseOrderDetailController@save');
Route::post('/pr-purchase-order-detail/delete', 'Procurement\PurchaseOrderDetailController@delete');
Route::post('/pr-purchase-order-detail/save-delete', 'Procurement\PurchaseOrderDetailController@save_delete');
Route::get('/pr-purchase-order-detail/reload/{id}', 'Procurement\PurchaseOrderDetailController@reload');

// GOOD RECEIPT
Route::get('/pr-good-receipt', 'Procurement\GoodReceiptController@inquiry');
Route::post('/pr-good-receipt-list', 'Procurement\GoodReceiptController@inquiry_data');
Route::get('/pr-good-receipt/create', 'Procurement\GoodReceiptController@create');
Route::get('/pr-good-receipt/update/{id}', 'Procurement\GoodReceiptController@update');
Route::post('/pr-good-receipt/save', 'Procurement\GoodReceiptController@save');
Route::post('/pr-good-receipt/approve', 'Procurement\GoodReceiptController@approve');
Route::post('/pr-good-receipt/save-approve', 'Procurement\GoodReceiptController@save_approve');
Route::post('/pr-good-receipt/reverse', 'Procurement\GoodReceiptController@reverse');
Route::post('/pr-good-receipt/save-reverse', 'Procurement\GoodReceiptController@save_reverse');
Route::get('/pr-good-receipt/download-pdf/{id}', 'Procurement\GoodReceiptController@download_pdf');

// GOOD RECEIPT DETAIL
Route::get('/pr-good-receipt-detail', 'Procurement\GoodReceiptDetailController@inquiry');
Route::post('/pr-good-receipt-detail-list', 'Procurement\GoodReceiptDetailController@inquiry_data');
Route::post('/pr-good-receipt-detail/create', 'Procurement\GoodReceiptDetailController@create');
Route::post('/pr-good-receipt-detail/update/{id}', 'Procurement\GoodReceiptDetailController@update');
Route::post('/pr-good-receipt-detail/save', 'Procurement\GoodReceiptDetailController@save');
Route::post('/pr-good-receipt-detail/delete', 'Procurement\GoodReceiptDetailController@delete');
Route::post('/pr-good-receipt-detail/save-delete', 'Procurement\GoodReceiptDetailController@save_delete');
Route::get('/pr-good-receipt-detail/reload/{id}', 'Procurement\GoodReceiptDetailController@reload');

// REPORT
Route::get('/pr-rpt-purchase-order', 'Procurement\RptPurchaseOrderController@period');
Route::post('/pr-rpt-purchase-order', 'Procurement\RptPurchaseOrderController@period_report');