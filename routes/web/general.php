<?php

use Illuminate\Support\Facades\Route;

// COMPANY
Route::get('/gn-company', 'General\CompanyController@inquiry');
Route::post('/gn-company-list', 'General\CompanyController@inquiry_data');
Route::get('/gn-company/create', 'General\CompanyController@create');
Route::get('/gn-company/update/{id}', 'General\CompanyController@update');
Route::post('/gn-company/save', 'General\CompanyController@save');

// BRANCH
Route::get('/gn-branch', 'General\BranchController@inquiry');
Route::post('/gn-branch-list', 'General\BranchController@inquiry_data');
Route::post('/gn-branch-user-specific-list/{id?}', 'General\BranchController@inquiry_data_by_user');
Route::get('/gn-branch/create', 'General\BranchController@create');
Route::get('/gn-branch/update/{id}', 'General\BranchController@update');
Route::post('/gn-branch/save', 'General\BranchController@save');

// PROJECT
Route::get('/gn-project', 'General\ProjectController@inquiry');
Route::post('/gn-project-list', 'General\ProjectController@inquiry_data');
Route::post('/gn-project-user-specific-list/{id?}', 'General\ProjectController@inquiry_data_by_user');
Route::get('/gn-project/create/{id?}', 'General\ProjectController@create');
Route::get('/gn-project/update/{id}', 'General\ProjectController@update');
Route::post('/gn-project/save', 'General\ProjectController@save');

// DEPARTMENT
Route::get('/gn-department', 'General\DepartmentController@inquiry');
Route::post('/gn-department-list', 'General\DepartmentController@inquiry_data');
Route::get('/gn-department/create/{id?}', 'General\DepartmentController@create');
Route::get('/gn-department/update/{id}', 'General\DepartmentController@update');
Route::post('/gn-department/save', 'General\DepartmentController@save');

// BANK
Route::get('/gn-bank', 'General\BankController@inquiry');
Route::post('/gn-bank-list', 'General\BankController@inquiry_data');
Route::get('/gn-bank/create', 'General\BankController@create');
Route::get('/gn-bank/update/{id}', 'General\BankController@update');
Route::post('/gn-bank/save', 'General\BankController@save');

// COUNTRY
Route::get('/gn-country', 'General\CountryController@inquiry');
Route::post('/gn-country-list', 'General\CountryController@inquiry_data');
Route::get('/gn-country/create', 'General\CountryController@create');
Route::get('/gn-country/update/{id}', 'General\CountryController@update');
Route::post('/gn-country/save', 'General\CountryController@save');

// DOCUMENT TYPE
Route::get('/gn-document-type', 'General\DocumentTypeController@inquiry');
Route::post('/gn-document-type-list', 'General\DocumentTypeController@inquiry_data');
Route::get('/gn-document-type/create/{id?}', 'General\DocumentTypeController@create');
Route::get('/gn-document-type/update/{id}', 'General\DocumentTypeController@update');
Route::post('/gn-document-type/save', 'General\DocumentTypeController@save');

// BUSINESS PARTNER
Route::get('/gn-partner', 'General\PartnerController@inquiry');
Route::post('/gn-partner-list', 'General\PartnerController@inquiry_data');
Route::get('/gn-partner/create', 'General\PartnerController@create');
Route::get('/gn-partner/update/{id}', 'General\PartnerController@update');
Route::post('/gn-partner/save', 'General\PartnerController@save');

// LOOKUP VENDOR
Route::post('/gn-select-partner', 'General\PartnerController@show_lookup');

// BUSINESS PARTNER ADDRESS
Route::post('/gn-partner-address/create', 'General\PartnerAddressController@create');
Route::post('/gn-partner-address/update/{id}', 'General\PartnerAddressController@update');
Route::post('/gn-partner-address/save', 'General\PartnerAddressController@save');
Route::post('/gn-partner-address/delete', 'General\PartnerAddressController@delete');
Route::post('/gn-partner-address/save-delete', 'General\PartnerAddressController@save_delete');
Route::get('/gn-partner-address/reload/{id}', 'General\PartnerAddressController@reload');

// VENDOR BANK
Route::post('/gn-partner-bank/create', 'General\PartnerBankController@create');
Route::post('/gn-partner-bank/update/{id}', 'General\PartnerBankController@update');
Route::post('/gn-partner-bank/save', 'General\PartnerBankController@save');
Route::post('/gn-partner-bank/delete', 'General\PartnerBankController@delete');
Route::post('/gn-partner-bank/save-delete', 'General\PartnerBankController@save_delete');
Route::get('/gn-partner-bank/reload/{id}', 'General\PartnerBankController@reload');