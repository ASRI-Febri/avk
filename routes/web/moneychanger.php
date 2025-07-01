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

// SALES ORDER
Route::get('/mc-sales-order', 'MoneyChanger\SalesOrderController@inquiry');
Route::post('/mc-sales-order-list', 'MoneyChanger\SalesOrderController@inquiry_data');
Route::get('/mc-sales-order/create', 'MoneyChanger\SalesOrderController@create');
Route::get('/mc-sales-order/update/{id}', 'MoneyChanger\SalesOrderController@update');
Route::post('/mc-sales-order/save', 'MoneyChanger\SalesOrderController@save');
Route::post('/mc-sales-order/approve', 'MoneyChanger\SalesOrderController@approve');
Route::post('/mc-sales-order/save-approve', 'MoneyChanger\SalesOrderController@save_approve');
Route::post('/mc-sales-order/reverse', 'MoneyChanger\SalesOrderController@reverse');
Route::post('/mc-sales-order/save-reverse', 'MoneyChanger\SalesOrderController@save_reverse');
Route::get('/mc-sales-order/download-pdf/{id}', 'MoneyChanger\SalesOrderController@download_pdf');
Route::post('/mc-sales-order/duplicate', 'MoneyChanger\SalesOrderController@duplicate');
Route::post('/mc-sales-order/save-duplicate', 'MoneyChanger\SalesOrderController@save_duplicate');

// SALES ORDER - DETAIL
Route::get('/mc-sales-order-detail', 'MoneyChanger\SalesOrderDetailController@inquiry');
Route::post('/mc-sales-order-detail-list', 'MoneyChanger\SalesOrderDetailController@inquiry_data');
Route::post('/mc-sales-order-detail/create', 'MoneyChanger\SalesOrderDetailController@create');
Route::post('/mc-sales-order-detail/update/{id}', 'MoneyChanger\SalesOrderDetailController@update');
Route::post('/mc-sales-order-detail/save', 'MoneyChanger\SalesOrderDetailController@save');
Route::get('/mc-sales-order-detail/reload/{id}', 'MoneyChanger\SalesOrderDetailController@reload'); // RELOAD TABLE AFTER SAVE
Route::post('mc-sales-order-detail/delete', 'MoneyChanger\SalesOrderDetailController@delete');
Route::post('/mc-sales-order-detail/save-delete', 'MoneyChanger\SalesOrderDetailController@save_delete');

// STOCK CARD SUMMARY
Route::get('/mc-stock-card', 'MoneyChanger\StockCardController@inquiry');
Route::post('/mc-stock-card-list', 'MoneyChanger\StockCardController@inquiry_data');

// LOOKUP BUSINESS PARTNER
Route::get('/mc-partner', 'MoneyChanger\PartnerController@inquiry');
Route::post('/mc-partner-list', 'MoneyChanger\PartnerController@inquiry_data');
Route::get('/mc-partner/create', 'MoneyChanger\PartnerController@create');
Route::get('/mc-partner/update/{id}', 'MoneyChanger\PartnerController@update');
Route::post('/mc-partner/save', 'MoneyChanger\PartnerController@save');

// LOOKUP VENDOR
Route::post('/mc-select-partner', 'MoneyChanger\PartnerController@show_lookup');

// BUSINESS PARTNER ADDRESS
Route::post('/mc-partner-address/create', 'MoneyChanger\PartnerAddressController@create');
Route::post('/mc-partner-address/update/{id}', 'MoneyChanger\PartnerAddressController@update');
Route::post('/mc-partner-address/save', 'MoneyChanger\PartnerAddressController@save');
Route::post('/mc-partner-address/delete', 'MoneyChanger\PartnerAddressController@delete');
Route::post('/mc-partner-address/save-delete', 'MoneyChanger\PartnerAddressController@save_delete');
Route::get('/mc-partner-address/reload/{id}', 'MoneyChanger\PartnerAddressController@reload');

// VENDOR BANK
Route::post('/mc-partner-bank/create', 'MoneyChanger\PartnerBankController@create');
Route::post('/mc-partner-bank/update/{id}', 'MoneyChanger\PartnerBankController@update');
Route::post('/mc-partner-bank/save', 'MoneyChanger\PartnerBankController@save');
Route::post('/mc-partner-bank/delete', 'MoneyChanger\PartnerBankController@delete');
Route::post('/mc-partner-bank/save-delete', 'MoneyChanger\PartnerBankController@save_delete');
Route::get('/mc-partner-bank/reload/{id}', 'MoneyChanger\PartnerBankController@reload');

Route::get('/mc-sop', 'MoneyChanger\SOPController@sop');
Route::get('/mc-sop-risk-management', 'MoneyChanger\SOPController@sop_risk_management');
Route::get('/mc-sop-money-laundry', 'MoneyChanger\SOPController@sop_money_laundry');
Route::get('/mc-sop-penetapan-kurs', 'MoneyChanger\SOPController@sop_penetapan_kurs');
Route::get('/mc-sop-perlindungan-konsumen', 'MoneyChanger\SOPController@sop_perlindungan_konsumen');

// REPORT
Route::get('/mc-rpt-transaction', 'MoneyChanger\RptTransactionController@period');
Route::post('/mc-rpt-transaction', 'MoneyChanger\RptTransactionController@period_report');

Route::get('/mc-rpt-inventory', 'MoneyChanger\RptInventoryController@period');
Route::post('/mc-rpt-inventory', 'MoneyChanger\RptInventoryController@period_report');