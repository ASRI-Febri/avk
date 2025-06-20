<?php

use Illuminate\Support\Facades\Route;

// LOAN LIST
Route::get('/cf-loan', 'Loan\LoanController@inquiry');
Route::post('/cf-loan-list', 'Loan\LoanController@inquiry_data');
Route::get('/cf-loan-create', 'Loan\LoanController@create');
Route::get('/cf-loan-update/{id}', 'Loan\LoanController@update');
Route::post('/cf-loan/save', 'Loan\LoanController@save');
