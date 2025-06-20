<?php

use Illuminate\Support\Facades\Route;

// PAWN LIST
Route::get('/pw-pawn', 'Pawn\PawnController@inquiry');
Route::post('/pw-pawn-list', 'Pawn\PawnController@inquiry_data');