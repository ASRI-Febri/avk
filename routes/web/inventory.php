<?php

use Illuminate\Support\Facades\Route;

// ITEM
Route::get('/in-item', 'Inventory\ItemController@inquiry');
Route::post('/in-item-list', 'Inventory\ItemController@inquiry_data');
Route::get('/in-item/create', 'Inventory\ItemController@create');
Route::get('/in-item/update/{id}', 'Inventory\ItemController@update');
Route::post('/in-item/save', 'Inventory\ItemController@save');

// REPORT
Route::get('/in-rpt-stock-period', 'Inventory\RptStockController@period');
Route::post('/in-rpt-stock-period', 'Inventory\RptStockController@period_report');

Route::get('/in-rpt-stock-card', 'Inventory\RptStockController@stock_card');
Route::post('/in-rpt-stock-card', 'Inventory\RptStockController@stock_card_report');