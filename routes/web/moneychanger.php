<?php

use Illuminate\Support\Facades\Route;

Route::get('display-kurs', 'MoneyChanger\CurrencyController@display_kurs_valas');

Route::get('/mc-display-kurs', 'MoneyChanger\CurrencyController@display_kurs');
Route::get('/mc-display-kurs-tv', 'MoneyChanger\CurrencyController@display_kurs_tv');
Route::get('/mc-display-kurs-tv-data', 'MoneyChanger\CurrencyController@display_kurs_tv_data');

// CURRENCY LIST
Route::get('/mc-currency', 'MoneyChanger\CurrencyController@inquiry');
Route::post('/mc-currency-list', 'MoneyChanger\CurrencyController@inquiry_data');
Route::get('/mc-currency/create', 'MoneyChanger\CurrencyController@create');
Route::get('/mc-currency/update/{id}', 'MoneyChanger\CurrencyController@update');
Route::get('/mc-currency/duplicate/{id}', 'MoneyChanger\CurrencyController@duplicate');
Route::post('/mc-currency/save', 'MoneyChanger\CurrencyController@save');

// IMPORT KURS BANK PANIN (paste tabel kurs -> preview -> update Rate Beli/Jual)
Route::get('/mc-currency-import-kurs', 'MoneyChanger\CurrencyController@import_kurs');
Route::post('/mc-currency-import-kurs/preview', 'MoneyChanger\CurrencyController@import_kurs_preview');
Route::post('/mc-currency-import-kurs/save', 'MoneyChanger\CurrencyController@import_kurs_save');

// IMPORT KURS BANK BCA (paste tabel kurs -> preview -> update Rate Beli/Jual)
Route::get('/mc-currency-import-kurs-bca', 'MoneyChanger\CurrencyController@import_kurs_bca');
Route::post('/mc-currency-import-kurs-bca/preview', 'MoneyChanger\CurrencyController@import_kurs_bca_preview');
Route::post('/mc-currency-import-kurs-bca/save', 'MoneyChanger\CurrencyController@import_kurs_bca_save');

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

// OPENING & CLOSING DAILY
Route::get('/mc-open-close', 'MoneyChanger\OpenCloseController@inquiry');
Route::post('/mc-open-close-list', 'MoneyChanger\OpenCloseController@inquiry_data');
Route::get('/mc-open-close/create', 'MoneyChanger\OpenCloseController@create');
Route::get('/mc-open-close/update/{id}', 'MoneyChanger\OpenCloseController@update');
Route::post('/mc-open-close/save', 'MoneyChanger\OpenCloseController@save');
Route::post('/mc-open-close/calculate', 'MoneyChanger\OpenCloseController@calculate');
Route::post('/mc-open-close/save-calculate', 'MoneyChanger\OpenCloseController@save_calculate');
Route::post('/mc-open-close/closing', 'MoneyChanger\OpenCloseController@closing');
Route::post('/mc-open-close/save-closing', 'MoneyChanger\OpenCloseController@save_closing');
Route::get('/mc-open-close/download-pdf/{id}', 'MoneyChanger\OpenCloseController@download_pdf');

// OPENING & CLOSING DETAIL DAILY
Route::get('/mc-open-close-detail', 'MoneyChanger\OpenCloseDetailController@inquiry');
Route::post('/mc-open-close-detail-list', 'MoneyChanger\OpenCloseDetailController@inquiry_data');
Route::post('/mc-open-close-detail/create', 'MoneyChanger\OpenCloseDetailController@create');
Route::post('/mc-open-close-detail/update/{id}', 'MoneyChanger\OpenCloseDetailController@update');
Route::post('/mc-open-close-detail/save', 'MoneyChanger\OpenCloseDetailController@save');
Route::get('/mc-open-close-detail/reload/{id}', 'MoneyChanger\OpenCloseDetailController@reload'); // RELOAD TABLE AFTER SAVE
Route::post('mc-open-close-detail/delete/{id?}', 'MoneyChanger\OpenCloseDetailController@delete');
Route::post('/mc-open-close-detail/save-delete', 'MoneyChanger\OpenCloseDetailController@save_delete');

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

Route::post('/mc-purchase-order-upload', 'MoneyChanger\PurchaseOrderController@upload');
Route::get('/mc-purchase-order-download', 'MoneyChanger\PurchaseOrderController@download');
Route::get('/mc-purchase-order-delete-file', 'MoneyChanger\PurchaseOrderController@delete_file');

// PURCHASE ORDER - DETAIL
Route::get('/mc-purchase-order-detail', 'MoneyChanger\PurchaseOrderDetailController@inquiry');
Route::post('/mc-purchase-order-detail-list', 'MoneyChanger\PurchaseOrderDetailController@inquiry_data');
Route::post('/mc-purchase-order-detail/create', 'MoneyChanger\PurchaseOrderDetailController@create');
Route::post('/mc-purchase-order-detail/update/{id}', 'MoneyChanger\PurchaseOrderDetailController@update');
Route::post('/mc-purchase-order-detail/save', 'MoneyChanger\PurchaseOrderDetailController@save');
Route::get('/mc-purchase-order-detail/reload/{id}', 'MoneyChanger\PurchaseOrderDetailController@reload'); // RELOAD TABLE AFTER SAVE
Route::post('mc-purchase-order-detail/delete', 'MoneyChanger\PurchaseOrderDetailController@delete');
Route::post('/mc-purchase-order-detail/save-delete', 'MoneyChanger\PurchaseOrderDetailController@save_delete');

// PURCHASE ORDER PAYMENT
Route::post('mc-purchase-order-payment/create', 'MoneyChanger\PurchaseOrderPaymentController@create');
Route::post('mc-purchase-order-payment/update', 'MoneyChanger\PurchaseOrderPaymentController@update');
Route::post('/mc-purchase-order-payment/save', 'MoneyChanger\PurchaseOrderPaymentController@save');
Route::get('/mc-purchase-order-payment/reload/{id}', 'MoneyChanger\PurchaseOrderPaymentController@reload');

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

Route::post('/mc-sales-order-upload', 'MoneyChanger\SalesOrderController@upload');
Route::get('/mc-sales-order-download', 'MoneyChanger\SalesOrderController@download');
Route::get('/mc-sales-order-delete-file', 'MoneyChanger\SalesOrderController@delete_file');

// SALES QUICK (input cepat header + detail dalam 1 form)
Route::get('/mc-sales-quick/create',     'MoneyChanger\SalesQuickController@create');
Route::get('/mc-sales-quick/update/{id}','MoneyChanger\SalesQuickController@update');
Route::post('/mc-sales-quick/save',      'MoneyChanger\SalesQuickController@save');

// PURCHASE QUICK (input cepat header + detail dalam 1 form)
Route::get('/mc-purchase-quick/create',     'MoneyChanger\PurchaseQuickController@create');
Route::get('/mc-purchase-quick/update/{id}','MoneyChanger\PurchaseQuickController@update');
Route::post('/mc-purchase-quick/save',      'MoneyChanger\PurchaseQuickController@save');

// SALES ORDER - DETAIL
Route::get('/mc-sales-order-detail', 'MoneyChanger\SalesOrderDetailController@inquiry');
Route::post('/mc-sales-order-detail-list', 'MoneyChanger\SalesOrderDetailController@inquiry_data');
Route::post('/mc-sales-order-detail/create', 'MoneyChanger\SalesOrderDetailController@create');
Route::post('/mc-sales-order-detail/update/{id}', 'MoneyChanger\SalesOrderDetailController@update');
Route::post('/mc-sales-order-detail/save', 'MoneyChanger\SalesOrderDetailController@save');
Route::get('/mc-sales-order-detail/reload/{id}', 'MoneyChanger\SalesOrderDetailController@reload'); // RELOAD TABLE AFTER SAVE
Route::post('mc-sales-order-detail/delete', 'MoneyChanger\SalesOrderDetailController@delete');
Route::post('/mc-sales-order-detail/save-delete', 'MoneyChanger\SalesOrderDetailController@save_delete');

// SALES ORDER PAYMENT
Route::post('mc-sales-order-payment/create', 'MoneyChanger\SalesOrderPaymentController@create');
Route::post('mc-sales-order-payment/update', 'MoneyChanger\SalesOrderPaymentController@update');
Route::post('/mc-sales-order-payment/save', 'MoneyChanger\SalesOrderPaymentController@save');
Route::get('/mc-sales-order-payment/reload/{id}', 'MoneyChanger\SalesOrderPaymentController@reload');

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



Route::get('/download-files/{filename}', 'MoneyChanger\FileController@servePdf');
Route::get('/show-files/{filename}', 'MoneyChanger\FileController@showPdf');

Route::get('/mc-sop', 'MoneyChanger\SOPController@sop');
Route::get('/mc-sop-risk-management', 'MoneyChanger\SOPController@sop_risk_management');
Route::get('/mc-sop-money-laundry', 'MoneyChanger\SOPController@sop_money_laundry');
Route::get('/mc-sop-penetapan-kurs', 'MoneyChanger\SOPController@sop_penetapan_kurs');
Route::get('/mc-sop-perlindungan-konsumen', 'MoneyChanger\SOPController@sop_perlindungan_konsumen');

// NOTA SCAN (OCR)
Route::get('/mc-nota-scan',           'MoneyChanger\NotaScanController@inquiry');
Route::post('/mc-nota-scan-list',     'MoneyChanger\NotaScanController@inquiry_data');
Route::get('/mc-nota-scan/create',    'MoneyChanger\NotaScanController@create');
Route::get('/mc-nota-scan/update/{id}','MoneyChanger\NotaScanController@update');
Route::post('/mc-nota-scan/scan',     'MoneyChanger\NotaScanController@scan');
Route::post('/mc-nota-scan/save',     'MoneyChanger\NotaScanController@save');

// CHECK STOCK CARD (RECONCILE KARTU STOK vs TRANSAKSI)
Route::get('/mc-check-stock-card', 'MoneyChanger\CheckStockCardController@inquiry');
Route::post('/mc-check-stock-card-report', 'MoneyChanger\CheckStockCardController@report');

// STOCK CARD CHECK (tab "Kartu Stok" di halaman update SO/PO + koreksi quantity / hapus duplikat)
Route::get('/mc-stock-card-check/reload/{type}/{idx}', 'MoneyChanger\StockCardCheckController@reload');
Route::post('/mc-stock-card-check/update/{id}', 'MoneyChanger\StockCardCheckController@update');
Route::post('/mc-stock-card-check/save', 'MoneyChanger\StockCardCheckController@save');
Route::post('/mc-stock-card-check/delete', 'MoneyChanger\StockCardCheckController@delete');
Route::post('/mc-stock-card-check/save-delete', 'MoneyChanger\StockCardCheckController@save_delete');

// ANALYTIC (CFO DASHBOARDS)
Route::get('/mc-analytic-profitability', 'MoneyChanger\AnalyticController@profitability');
Route::get('/mc-analytic-position',      'MoneyChanger\AnalyticController@position');
Route::get('/mc-analytic-volume',        'MoneyChanger\AnalyticController@volume');
Route::get('/mc-analytic-liquidity',     'MoneyChanger\AnalyticController@liquidity');

// COGS CALCULATION
Route::get('/mc-cogs-calculation', 'MoneyChanger\COGSCalculationController@inquiry');
Route::post('/mc-cogs-calculation-list', 'MoneyChanger\COGSCalculationController@inquiry_data');
Route::get('/mc-cogs-calculation/create', 'MoneyChanger\COGSCalculationController@create');
Route::post('/mc-cogs-calculation/save', 'MoneyChanger\COGSCalculationController@save');
Route::get('/mc-cogs-calculation/success', 'MoneyChanger\COGSCalculationController@success');
Route::post('/mc-cogs-calculation/generate-journal', 'MoneyChanger\COGSCalculationController@generate_journal');
Route::post('/mc-cogs-calculation/save-generate-journal', 'MoneyChanger\COGSCalculationController@save_generate_journal');

// REPORT
Route::get('/mc-rpt-so', 'MoneyChanger\RptTransactionController@period_sales');
Route::post('/mc-rpt-so', 'MoneyChanger\RptTransactionController@period_sales_report');

Route::get('/mc-rpt-po', 'MoneyChanger\RptTransactionController@period_purchase');
Route::post('/mc-rpt-po', 'MoneyChanger\RptTransactionController@period_purchase_report');

Route::get('/mc-rpt-inventory', 'MoneyChanger\RptInventoryController@period');
Route::post('/mc-rpt-inventory', 'MoneyChanger\RptInventoryController@period_report');

Route::get('/mc-rpt-inventory-calculation', 'MoneyChanger\RptInventoryController@inventory_calculation');
Route::post('/mc-rpt-inventory-calculation', 'MoneyChanger\RptInventoryController@inventory_calculation_report');

Route::get('/mc-rpt-cogs-calculation', 'MoneyChanger\RptCOGSController@cogs_calculation');
Route::post('/mc-rpt-cogs-calculation', 'MoneyChanger\RptCOGSController@cogs_calculation_report');

Route::get('/mc-rpt-daily-calculation', 'MoneyChanger\RptTransactionController@daily_calculation');
Route::post('/mc-rpt-daily-calculation', 'MoneyChanger\RptTransactionController@daily_calculation_report');

Route::get('/mc-rpt-ar', 'MoneyChanger\RptARAPController@ar');
Route::post('/mc-rpt-ar', 'MoneyChanger\RptARAPController@ar_report');

Route::get('/mc-rpt-ap', 'MoneyChanger\RptARAPController@ap');
Route::post('/mc-rpt-ap', 'MoneyChanger\RptARAPController@ap_report');

// DAFTAR KURS VALAS
Route::get('mc/kurs', 'MoneyChanger\CurrencyController@display_kurs_valas');