<?php

use Illuminate\Support\Facades\Route;

// FINANCIAL ACCOUNT
Route::get('/fm-financial-account', 'Finance\FinancialAccountController@inquiry');
Route::post('/fm-financial-account-list', 'Finance\FinancialAccountController@inquiry_data');
Route::get('/fm-financial-account/create', 'Finance\FinancialAccountController@create');
Route::get('/fm-financial-account/update/{id}', 'Finance\FinancialAccountController@update');
Route::post('/fm-financial-account/save', 'Finance\FinancialAccountController@save');

// BANK
Route::get('/fm-bank', 'Finance\BankController@inquiry');
Route::post('/fm-bank-list', 'Finance\BankController@inquiry_data');
Route::get('/fm-bank/create', 'Finance\BankController@create');
Route::get('/fm-bank/update/{id}', 'Finance\BankController@update');
Route::post('/fm-bank/save', 'Finance\BankController@save');

// CURRENCY
Route::get('/fm-currency', 'Finance\CurrencyController@inquiry');
Route::post('/fm-currency-list', 'Finance\CurrencyController@inquiry_data');
Route::get('/fm-currency/create', 'Finance\CurrencyController@create');
Route::get('/fm-currency/update/{id}', 'Finance\CurrencyController@update');
Route::post('/fm-currency/save', 'Finance\CurrencyController@save');

//LOOKUP
Route::post('/fm-coa-list', 'Finance\FinancialAccountController@inquiry_data_coa');
Route::post('/fm-select-coa', 'Finance\FinancialAccountController@show_lookup_coa');

// CASHFLOW
Route::get('/fm-cashflow', 'Finance\CashflowController@inquiry');
Route::post('/fm-cashflow-list', 'Finance\CashflowController@inquiry_data');
Route::get('/fm-cashflow/create', 'Finance\CashflowController@create');
Route::get('/fm-cashflow/update/{id}', 'Finance\CashflowController@update');
Route::post('/fm-cashflow/save', 'Finance\CashflowController@save');

    //LOOKUP
    Route::post('/fm-cashflowparent-list', 'Finance\CashflowController@inquiry_data_cashflowparent');
    Route::post('/fm-select-cashflowparent', 'Finance\CashflowController@show_lookup_cashflowparent');

// // CHART OF ACCOUNT
// Route::get('/fm-coa', 'Finance\COAController@inquiry');
// Route::post('/fm-coa-list', 'Finance\COAController@inquiry_data');
// Route::get('/fm-coa/create', 'Finance\COAController@create');
// Route::get('/fm-coa/update/{id}', 'Finance\COAController@update');
// Route::post('/fm-coa/save', 'Finance\COAController@save');

//     //LOOKUP
//     Route::post('/fm-coaparent-list', 'Finance\COAController@inquiry_data_coaparent');
//     Route::post('/fm-select-coaparent', 'Finance\COAController@show_lookup_coaparent');
//     Route::post('/fm-cfin-list', 'Finance\COAController@inquiry_data_cfin');
//     Route::post('/fm-select-cfin', 'Finance\COAController@show_lookup_cfin');
//     Route::post('/fm-cfout-list', 'Finance\COAController@inquiry_data_cfout');
//     Route::post('/fm-select-cfout', 'Finance\COAController@show_lookup_cfout');

//     // //POPULATE DROPDOWN
//     Route::get('fm-coa/getCOAGroup1/{id}', 'Finance\COAController@getCOA1');
//     Route::get('/fm-coa/update/getCOAGroup1/{id}', 'Finance\COAController@getCOA1');
//     Route::get('fm-coa/getCOAGroup2/{id}', 'Finance\COAController@getCOA2');
//     Route::get('/fm-coa/update/getCOAGroup2/{id}', 'Finance\COAController@getCOA2');
//     Route::get('fm-coa/getCOAGroup3/{id}', 'Finance\COAController@getCOA3'); 
//     Route::get('/fm-coa/update/getCOAGroup3/{id}', 'Finance\COAController@getCOA3');

// // COA GROUP 1
// Route::get('/fm-coa-1', 'Finance\COAGroup1Controller@inquiry');
// Route::post('/fm-coa-1-list', 'Finance\COAGroup1Controller@inquiry_data');
// Route::get('/fm-coa-1/create', 'Finance\COAGroup1Controller@create');
// Route::get('/fm-coa-1/update/{id}', 'Finance\COAGroup1Controller@update');
// Route::post('/fm-coa-1/save', 'Finance\COAGroup1Controller@save');

// // COA GROUP 2
// Route::get('/fm-coa-2', 'Finance\COAGroup2Controller@inquiry');
// Route::post('/fm-coa-2-list', 'Finance\COAGroup2Controller@inquiry_data');
// Route::get('/fm-coa-2/create', 'Finance\COAGroup2Controller@create');
// Route::get('/fm-coa-2/update/{id}', 'Finance\COAGroup2Controller@update');
// Route::post('/fm-coa-2/save', 'Finance\COAGroup2Controller@save');

// // COA GROUP 3
// Route::get('/fm-coa-3', 'Finance\COAGroup3Controller@inquiry');
// Route::post('/fm-coa-3-list', 'Finance\COAGroup3Controller@inquiry_data');
// Route::get('/fm-coa-3/create', 'Finance\COAGroup3Controller@create');
// Route::get('/fm-coa-3/update/{id}', 'Finance\COAGroup3Controller@update');
// Route::post('/fm-coa-3/save', 'Finance\COAGroup3Controller@save');

// PURCHASE INVOICE
Route::get('/fm-purchase-invoice', 'Finance\PurchaseInvoiceController@inquiry');
Route::post('/fm-purchase-invoice-list', 'Finance\PurchaseInvoiceController@inquiry_data');
Route::get('/fm-purchase-invoice/create', 'Finance\PurchaseInvoiceController@create');
Route::get('/fm-purchase-invoice/update/{id}', 'Finance\PurchaseInvoiceController@update');
Route::post('/fm-purchase-invoice/save', 'Finance\PurchaseInvoiceController@save');
Route::post('/fm-purchase-invoice/approve', 'Finance\PurchaseInvoiceController@approve');
Route::post('/fm-purchase-invoice/save-approve', 'Finance\PurchaseInvoiceController@save_approve');
Route::post('/fm-purchase-invoice/reverse', 'Finance\PurchaseInvoiceController@reverse');
Route::post('/fm-purchase-invoice/save-reverse', 'Finance\PurchaseInvoiceController@save_reverse');
Route::get('/fm-purchase-invoice/download-pdf/{id}', 'Finance\PurchaseInvoiceController@download_pdf');
Route::post('/fm-purchase-invoice/duplicate', 'Finance\PurchaseInvoiceController@duplicate');
Route::post('/fm-purchase-invoice/save-duplicate', 'Finance\PurchaseInvoiceController@save_duplicate');

//LOOKUP
Route::post('/fm-partner-list-pi', 'Finance\PurchaseInvoiceController@inquiry_data_partner');
Route::post('/fm-select-partner-pi', 'Finance\PurchaseInvoiceController@show_lookup_partner');
Route::post('/fm-coa-list', 'Finance\PurchaseInvoiceController@inquiry_data_coa');
Route::post('/fm-select-coa', 'Finance\PurchaseInvoiceController@show_lookup_coa');

//SEARCH
Route::post('/fm-purchase-order/search', 'Finance\PurchaseInvoiceController@search_po_no');
Route::get('fm-purchase-invoice/update/getInvoiceInfo/{id}', 'Finance\PurchaseInvoiceController@getInvoiceInfo');

// PURCHASE INVOICE - DETAIL
Route::get('/fm-purchase-invoice-detail', 'Finance\PurchaseInvoiceDetailController@inquiry');
Route::post('/fm-purchase-invoice-detail-list', 'Finance\PurchaseInvoiceDetailController@inquiry_data');
Route::post('/fm-purchase-invoice-detail/create', 'Finance\PurchaseInvoiceDetailController@create');
Route::post('/fm-purchase-invoice-detail/update/{id}', 'Finance\PurchaseInvoiceDetailController@update');
Route::post('/fm-purchase-invoice-detail/save', 'Finance\PurchaseInvoiceDetailController@save');
Route::get('/fm-purchase-invoice-detail/reload/{id}', 'Finance\PurchaseInvoiceDetailController@reload'); // RELOAD TABLE AFTER SAVE
Route::post('fm-purchase-invoice-detail/delete/{id?}', 'Finance\PurchaseInvoiceDetailController@delete');
Route::post('/fm-purchase-invoice-detail/save-delete', 'Finance\PurchaseInvoiceDetailController@save_delete');

// SEARCH
Route::post('/fm-account/search', 'Finance\PurchaseInvoiceDetailController@search_account');
//Route::post('/fm-item/search', 'Procurement\ItemController@search_item');

// PURCHASE INVOICE - TAX
Route::get('/fm-purchase-invoice-tax', 'Finance\PurchaseInvoiceTaxController@inquiry');
Route::post('/fm-purchase-invoice-tax-list', 'Finance\PurchaseInvoiceTaxController@inquiry_data');
Route::post('/fm-purchase-invoice-tax/create', 'Finance\PurchaseInvoiceTaxController@create');
Route::post('/fm-purchase-invoice-tax/update/{id}', 'Finance\PurchaseInvoiceTaxController@update');
Route::post('/fm-purchase-invoice-tax/save', 'Finance\PurchaseInvoiceTaxController@save');
Route::get('/fm-purchase-invoice-tax/reload/{id}', 'Finance\PurchaseInvoiceTaxController@reload'); // RELOAD TABLE AFTER SAVE
Route::post('fm-purchase-invoice-tax/delete/{id?}', 'Finance\PurchaseInvoiceTaxController@delete');
Route::post('/fm-purchase-invoice-tax/save-delete', 'Finance\PurchaseInvoiceTaxController@save_delete');

// PURCHASE INVOICE - INVOICE PAYMENT
Route::get('/fm-purchase-invoice-payment', 'Finance\PurchaseInvoicePaymentController@inquiry');
Route::post('/fm-purchase-invoice-payment-list', 'Finance\PurchaseInvoicePaymentController@inquiry_data');
Route::post('/fm-purchase-invoice-payment/create', 'Finance\PurchaseInvoicePaymentController@create');
Route::post('/fm-purchase-invoice-payment/update/{id}', 'Finance\PurchaseInvoicePaymentController@update');
Route::post('/fm-purchase-invoice-payment/save', 'Finance\PurchaseInvoicePaymentController@save');
Route::get('/fm-purchase-invoice-payment/reload/{id}', 'Finance\PurchaseInvoicePaymentController@reload'); // RELOAD TABLE AFTER SAVE
Route::post('fm-purchase-invoice-payment/delete/{id?}', 'Finance\PurchaseInvoicePaymentController@delete');
Route::post('/fm-purchase-invoice-payment/save-delete', 'Finance\PurchaseInvoicePaymentController@save_delete');

// SALES INVOICE
Route::get('/fm-sales-invoice', 'Finance\SalesInvoiceController@inquiry');
Route::post('/fm-sales-invoice-list', 'Finance\SalesInvoiceController@inquiry_data');
Route::get('/fm-sales-invoice/create', 'Finance\SalesInvoiceController@create');
Route::get('/fm-sales-invoice/update/{id}', 'Finance\SalesInvoiceController@update');
Route::post('/fm-sales-invoice/save', 'Finance\SalesInvoiceController@save');
Route::post('/fm-sales-invoice/approve', 'Finance\SalesInvoiceController@approve');
Route::post('/fm-sales-invoice/save-approve', 'Finance\SalesInvoiceController@save_approve');
Route::post('/fm-sales-invoice/reverse', 'Finance\SalesInvoiceController@reverse');
Route::post('/fm-sales-invoice/save-reverse', 'Finance\SalesInvoiceController@save_reverse');
Route::post('/fm-sales-invoice/void', 'Finance\SalesInvoiceController@void');
Route::post('/fm-sales-invoice/save-void', 'Finance\SalesInvoiceController@save_void');
Route::get('/fm-sales-invoice/download-pdf/{id}', 'Finance\SalesInvoiceController@download_pdf');
Route::get('/fm-sales-invoice/downloadreceipt-pdf/{id}', 'Finance\SalesInvoiceController@downloadreceipt_pdf');
Route::get('/fm-sales-invoice/daily-summary-pdf/{id}', 'Finance\SalesInvoiceController@daily_summary_pdf');
Route::post('/fm-sales-invoice/duplicate', 'Finance\SalesInvoiceController@duplicate');
Route::post('/fm-sales-invoice/save-duplicate', 'Finance\SalesInvoiceController@save_duplicate');
Route::post('/fm-sales-invoice/auditnotes', 'Finance\SalesInvoiceController@auditnotes');
Route::post('/fm-sales-invoice/save-auditnotes', 'Finance\SalesInvoiceController@save_auditnotes');

//LOOKUP
Route::post('/fm-partner-list-si', 'Finance\SalesInvoiceController@inquiry_data_partner');
Route::post('/fm-select-partner-si', 'Finance\SalesInvoiceController@show_lookup_partner');
Route::post('/fm-coa-list', 'Finance\SalesInvoiceController@inquiry_data_coa');
Route::post('/fm-select-coa', 'Finance\SalesInvoiceController@show_lookup_coa');
// Route::post('/fm-tax-list', 'Finance\SalesInvoiceController@inquiry_data_tax');
// Route::post('/fm-select-tax', 'Finance\SalesInvoiceController@show_lookup_tax');

//SEARCH
Route::post('/fm-sales-order/search', 'Finance\PurchaseInvoiceController@search_so_no');
Route::get('fm-sales-invoice/update/getInvoiceInfo/{id}', 'Finance\SalesInvoiceController@getInvoiceInfo');

// SALES INVOICE - DETAIL
Route::get('/fm-sales-invoice-detail', 'Finance\SalesInvoiceDetailController@inquiry');
Route::post('/fm-sales-invoice-detail-list', 'Finance\SalesInvoiceDetailController@inquiry_data');
Route::post('/fm-sales-invoice-detail/create', 'Finance\SalesInvoiceDetailController@create');
Route::post('/fm-sales-invoice-detail/update/{id}', 'Finance\SalesInvoiceDetailController@update');
Route::post('/fm-sales-invoice-detail/save', 'Finance\SalesInvoiceDetailController@save');
Route::get('/fm-sales-invoice-detail/reload/{id}', 'Finance\SalesInvoiceDetailController@reload'); // RELOAD TABLE AFTER SAVE
Route::post('fm-sales-invoice-detail/delete/{id?}', 'Finance\SalesInvoiceDetailController@delete');
Route::post('/fm-sales-invoice-detail/save-delete', 'Finance\SalesInvoiceDetailController@save_delete');

// SALES INVOICE - TAX
Route::get('/fm-sales-invoice-tax', 'Finance\SalesInvoiceTaxController@inquiry');
Route::post('/fm-sales-invoice-tax-list', 'Finance\SalesInvoiceTaxController@inquiry_data');
Route::post('/fm-sales-invoice-tax/create', 'Finance\SalesInvoiceTaxController@create');
Route::post('/fm-sales-invoice-tax/update/{id}', 'Finance\SalesInvoiceTaxController@update');
Route::post('/fm-sales-invoice-tax/save', 'Finance\SalesInvoiceTaxController@save');
Route::get('/fm-sales-invoice-tax/reload/{id}', 'Finance\SalesInvoiceTaxController@reload'); // RELOAD TABLE AFTER SAVE
Route::post('fm-sales-invoice-tax/delete/{id?}', 'Finance\SalesInvoiceTaxController@delete');
Route::post('/fm-sales-invoice-tax/save-delete', 'Finance\SalesInvoiceTaxController@save_delete');

// SALES INVOICE - INVOICE PAYMENT
Route::get('/fm-sales-invoice-payment', 'Finance\SalesInvoicePaymentController@inquiry');
Route::post('/fm-sales-invoice-payment-list', 'Finance\SalesInvoicePaymentController@inquiry_data');
Route::post('/fm-sales-invoice-payment/create', 'Finance\SalesInvoicePaymentController@create');
Route::post('/fm-sales-invoice-payment/update/{id}', 'Finance\SalesInvoicePaymentController@update');
Route::post('/fm-sales-invoice-payment/save', 'Finance\SalesInvoicePaymentController@save');
Route::get('/fm-sales-invoice-payment/reload/{id}', 'Finance\SalesInvoicePaymentController@reload'); // RELOAD TABLE AFTER SAVE
Route::post('fm-sales-invoice-payment/delete/{id?}', 'Finance\SalesInvoicePaymentController@delete');
Route::post('/fm-sales-invoice-payment/save-delete', 'Finance\SalesInvoicePaymentController@save_delete');

// FINANCIAL RECEIVE
Route::get('/fm-financial-receive', 'Finance\FinancialReceiveController@inquiry');
Route::post('/fm-financial-receive-list', 'Finance\FinancialReceiveController@inquiry_data');
Route::get('/fm-financial-receive/create', 'Finance\FinancialReceiveController@create');
Route::get('/fm-financial-receive/update/{id}', 'Finance\FinancialReceiveController@update');
Route::post('/fm-financial-receive/save', 'Finance\FinancialReceiveController@save');
Route::post('/fm-financial-receive/approve', 'Finance\FinancialReceiveController@approve');
Route::post('/fm-financial-receive/save-approve', 'Finance\FinancialReceiveController@save_approve');
Route::post('/fm-financial-receive/reverse', 'Finance\FinancialReceiveController@reverse');
Route::post('/fm-financial-receive/save-reverse', 'Finance\FinancialReceiveController@save_reverse');
Route::post('/fm-financial-receive/cancel', 'Finance\FinancialReceiveController@cancel_payment');
Route::post('/fm-financial-receive/save-cancel', 'Finance\FinancialReceiveController@save_cancel');
Route::get('/fm-financial-receive/download-pdf/{id}', 'Finance\FinancialReceiveController@download_pdf');
Route::post('/fm-financial-receive/duplicate', 'Finance\FinancialReceiveController@duplicate');
Route::post('/fm-financial-receive/save-duplicate', 'Finance\FinancialReceiveController@save_duplicate');

// SEARCH
Route::get('fm-financial-receive/update/getDocumentNo/{id}', 'Finance\FinancialReceiveController@getDocumentNo');
Route::get('fm-financial-receive/update/getDocumentInfo/{id}', 'Finance\FinancialReceiveController@getDocumentInfo');  

//LOOKUP
Route::post('/fm-partner-list-fr', 'Finance\FinancialReceiveController@inquiry_data_partner');
Route::post('/fm-select-partner-fr', 'Finance\FinancialReceiveController@show_lookup_partner');

// FINANCIAL RECEIVE - DETAIL
Route::get('/fm-financial-receive-detail', 'Finance\FinancialReceiveDetailController@inquiry');
Route::post('/fm-financial-receive-detail-list', 'Finance\FinancialReceiveDetailController@inquiry_data');
Route::post('/fm-financial-receive-detail/create', 'Finance\FinancialReceiveDetailController@create');
Route::post('/fm-financial-receive-detail/update/{id}', 'Finance\FinancialReceiveDetailController@update');
Route::post('/fm-financial-receive-detail/save', 'Finance\FinancialReceiveDetailController@save');
Route::get('/fm-financial-receive-detail/reload/{id}', 'Finance\FinancialReceiveDetailController@reload'); // RELOAD TABLE AFTER SAVE
Route::post('fm-financial-receive-detail/delete/{id?}', 'Finance\FinancialReceiveDetailController@delete');
Route::post('/fm-financial-receive-detail/save-delete', 'Finance\FinancialReceiveDetailController@save_delete');
Route::post('/fm-financial-receive-detail/create-allocation/{id}', 'Finance\FinancialReceiveDetailController@create_allocation');
Route::post('/fm-financial-receive-detail/update-allocation/{id}', 'Finance\FinancialReceiveDetailController@update_allocation');
Route::post('/fm-financial-receive-detail/save-allocation', 'Finance\FinancialReceiveDetailController@save_allocation');
Route::post('fm-financial-receive-detail/delete-allocation/{id?}', 'Finance\FinancialReceiveDetailController@delete_allocation');
Route::post('/fm-financial-receive-detail/save-delete-allocation', 'Finance\FinancialReceiveDetailController@save_delete_allocation');
Route::post('fm-financial-receive-detail/approve-allocation/{id?}', 'Finance\FinancialReceiveDetailController@approve_allocation');
Route::post('/fm-financial-receive-detail/save-approve-allocation', 'Finance\FinancialReceiveDetailController@save_approve_allocation');

// FINANCIAL PAYMENT
Route::get('/fm-financial-payment', 'Finance\FinancialPaymentController@inquiry');
Route::post('/fm-financial-payment-list', 'Finance\FinancialPaymentController@inquiry_data');
Route::get('/fm-financial-payment/create', 'Finance\FinancialPaymentController@create');
Route::get('/fm-financial-payment/update/{id}', 'Finance\FinancialPaymentController@update');
Route::post('/fm-financial-payment/save', 'Finance\FinancialPaymentController@save');
Route::post('/fm-financial-payment/approve', 'Finance\FinancialPaymentController@approve');
Route::post('/fm-financial-payment/save-approve', 'Finance\FinancialPaymentController@save_approve');
Route::post('/fm-financial-payment/reverse', 'Finance\FinancialPaymentController@reverse');
Route::post('/fm-financial-payment/save-reverse', 'Finance\FinancialPaymentController@save_reverse');
Route::post('/fm-financial-payment/validate', 'Finance\FinancialPaymentController@validate_payment');
Route::post('/fm-financial-payment/save-validate', 'Finance\FinancialPaymentController@save_validate');
Route::post('/fm-financial-payment/cancel', 'Finance\FinancialPaymentController@cancel_payment');
Route::post('/fm-financial-payment/save-cancel', 'Finance\FinancialPaymentController@save_cancel');
Route::get('/fm-financial-payment/download-pdf/{id}', 'Finance\FinancialPaymentController@download_pdf');
Route::post('/fm-financial-payment/duplicate', 'Finance\FinancialPaymentController@duplicate');
Route::post('/fm-financial-payment/save-duplicate', 'Finance\FinancialPaymentController@save_duplicate');

// SEARCH
Route::get('fm-financial-payment/update/getDocumentNo/{id}', 'Finance\FinancialPaymentController@getDocumentNo');
Route::get('fm-financial-payment/update/getDocumentInfo/{id}', 'Finance\FinancialPaymentController@getDocumentInfo'); 

//LOOKUP
Route::post('/fm-partner-list-fp', 'Finance\FinancialPaymentController@inquiry_data_partner');
Route::post('/fm-select-partner-fp', 'Finance\FinancialPaymentController@show_lookup_partner');

// FINANCIAL PAYMENT - DETAIL
Route::get('/fm-financial-payment-detail', 'Finance\FinancialPaymentDetailController@inquiry');
Route::post('/fm-financial-payment-detail-list', 'Finance\FinancialPaymentDetailController@inquiry_data');
Route::post('/fm-financial-payment-detail/create', 'Finance\FinancialPaymentDetailController@create');
Route::post('/fm-financial-payment-detail/update/{id}', 'Finance\FinancialPaymentDetailController@update');
Route::post('/fm-financial-payment-detail/save', 'Finance\FinancialPaymentDetailController@save');
Route::get('/fm-financial-payment-detail/reload/{id}', 'Finance\FinancialPaymentDetailController@reload'); // RELOAD TABLE AFTER SAVE
Route::post('fm-financial-payment-detail/delete/{id?}', 'Finance\FinancialPaymentDetailController@delete');
Route::post('/fm-financial-payment-detail/save-delete', 'Finance\FinancialPaymentDetailController@save_delete');
Route::post('/fm-financial-payment-detail/create-allocation/{id}', 'Finance\FinancialPaymentDetailController@create_allocation');
Route::post('/fm-financial-payment-detail/update-allocation/{id}', 'Finance\FinancialPaymentDetailController@update_allocation');
Route::post('/fm-financial-payment-detail/save-allocation', 'Finance\FinancialPaymentDetailController@save_allocation');
Route::post('fm-financial-payment-detail/delete-allocation/{id?}', 'Finance\FinancialPaymentDetailController@delete_allocation');
Route::post('/fm-financial-payment-detail/save-delete-allocation', 'Finance\FinancialPaymentDetailController@save_delete_allocation');
Route::post('fm-financial-payment-detail/approve-allocation/{id?}', 'Finance\FinancialPaymentDetailController@approve_allocation');
Route::post('/fm-financial-payment-detail/save-approve-allocation', 'Finance\FinancialPaymentDetailController@save_approve_allocation');

// SEARCH
Route::post('/fm-partner/search', 'Finance\FinancialPaymentDetailController@search_partner');

// REPORT
Route::get('/fm-rpt-financial-payment', 'Finance\RptFinancialPaymentController@financial_payment');
Route::post('/fm-rpt-financial-payment', 'Finance\RptFinancialPaymentController@financial_payment_report');

Route::get('/fm-rpt-financial-receive', 'Finance\RptFinancialReceiveController@financial_receive');
Route::post('/fm-rpt-financial-receive', 'Finance\RptFinancialReceiveController@financial_receive_report');

Route::get('/fm-rpt-payment-po', 'Finance\RptPaymentPOController@payment_po');
Route::post('/fm-rpt-payment-po', 'Finance\RptPaymentPOController@payment_po_report');

Route::get('/fm-rpt-payment-spk', 'Finance\RptPaymentSPKController@payment_spk');
Route::post('/fm-rpt-payment-spk', 'Finance\RptPaymentSPKController@payment_spk_report');

Route::get('/fm-rpt-purchase-invoice', 'Finance\RptPurchaseInvoiceController@purchase_invoice');
Route::post('/fm-rpt-purchase-invoice', 'Finance\RptPurchaseInvoiceController@purchase_invoice_report');

Route::get('/fm-rpt-sales-invoice', 'Finance\RptSalesInvoiceController@sales_invoice');
Route::post('/fm-rpt-sales-invoice', 'Finance\RptSalesInvoiceController@sales_invoice_report');

Route::get('/fm-rpt-bank-transfer', 'Finance\RptBankTransferController@bank_transfer');
Route::post('/fm-rpt-bank-transfer', 'Finance\RptBankTransferController@bank_transfer_report');

//LOOKUP
Route::post('/fm-select-partner-rpt', 'Finance\RptPaymentPOController@show_lookup_partner');
Route::post('/fm-select-partner-rpt', 'Finance\RptPaymentPOController@inquiry_partner_data');

