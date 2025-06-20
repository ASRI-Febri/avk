<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

// Route::get('/', 'LandingController@index');

Route::get('/', 'LoginController@index');

// LOGIN & LOGOUT
Route::get('/login', 'LoginController@index');
Route::post('/login/validate_user', 'LoginController@validate_user');
Route::get('/logout', 'LoginController@logout');

// // FORGOT PASSWORD
// Route::get('/forgot-password', 'ForgotPasswordController@show_forget_password');
// Route::post('/forgot-password/send', 'ForgotPasswordController@save_forget_password');
// Route::get('/forgot-password/check', 'ForgotPasswordController@show_check_password');
// Route::post('/forgot-password/save-check', 'ForgotPasswordController@check_password');
// Route::get('/forgot-password/reset', 'ForgotPasswordController@show_reset_password');
// Route::post('/forgot-password/save-reset', 'ForgotPasswordController@save_reset_password');

// PORTAL
Route::get('/portal', 'HomeController@portal');

// HOME
Route::get('/home', 'HomeController@portal');
Route::get('/home/{id}', 'HomeController@portal');
Route::get('/money-changer', 'HomeController@money_changer');
Route::get('/procurement', 'HomeController@procurement');
Route::get('/inventory', 'HomeController@inventory');
Route::get('/finance', 'HomeController@finance');
Route::get('/accounting', 'HomeController@accounting');
Route::get('/user-management', 'HomeController@user_management');
Route::get('/general', 'HomeController@general');
Route::get('/pawn', 'HomeController@pawn');
Route::get('/loan', 'HomeController@loan');

// USER PROFILE & PASSWORD
Route::get('/user-profile', 'UserController@user_profile');
Route::get('/change-password', 'UserController@change_password');

// TEST DATATABLE
Route::get('/test-datatable', 'Finance\FinancialAccountController@inquiry');
Route::post('/test-datatable-list', 'Finance\FinancialAccountController@inquiry_data');
