<?php

use Illuminate\Support\Facades\Route;

// USER
Route::get('/sm-user', 'UserManagement\UserController@inquiry');
Route::post('/sm-user-list', 'UserManagement\UserController@inquiry_data');
Route::get('/sm-user/create/{id?}', 'UserManagement\UserController@create');
Route::get('/sm-user/update/{id}', 'UserManagement\UserController@update');
Route::post('/sm-user/save', 'UserManagement\UserController@save');
Route::post('/sm-user/reset/', 'UserManagement\UserController@reset_password');
Route::post('/sm-user/save-reset-password/', 'UserManagement\UserController@save_reset_password');

Route::get('/sm-user/change-password/{id}', 'UserManagement\UserController@change_password');
Route::post('/sm-user/save-change-password', 'UserManagement\UserController@save_change_password');

// USER GROUP - ROLE
Route::post('/sm-user-group/create', 'UserManagement\UserController@create_group');
Route::post('/sm-user-group/save', 'UserManagement\UserController@save_group');

Route::post('/sm-user-group/delete', 'UserManagement\UserController@delete_group');
Route::post('/sm-user-group/save-delete', 'UserManagement\UserController@save_delete_group');

Route::post('/sm-user-group/activate', 'UserManagement\UserController@activate_group');
Route::post('/sm-user-group/save-activate/', 'UserManagement\UserController@save_activate_group');

Route::get('/sm-user-group/reload/{id}', 'UserManagement\UserController@reload_group');

// USER BRANCH
Route::post('/sm-user-branch/create', 'UserManagement\UserBranchController@create_branch');
Route::post('/sm-user-branch/save', 'UserManagement\UserBranchController@save_branch');

Route::post('/sm-user-branch/delete', 'UserManagement\UserBranchController@delete_branch');
Route::post('/sm-user-branch/save-delete', 'UserManagement\UserBranchController@save_delete_branch');

Route::post('/sm-user-branch/activate', 'UserManagement\UserBranchController@activate_branch');
Route::post('/sm-user-branch/save-activate', 'UserManagement\UserBranchController@save_activate_branch');

Route::get('/sm-user-branch/reload/{id}', 'UserManagement\UserBranchController@reload_branch');

// USER PROJECT
Route::post('/sm-user-project/create', 'UserManagement\UserProjectController@create_project');
Route::post('/sm-user-project/save', 'UserManagement\UserProjectController@save_project');

Route::post('/sm-user-project/delete', 'UserManagement\UserProjectController@delete_project');
Route::post('/sm-user-project/save-delete', 'UserManagement\UserProjectController@save_delete_project');

Route::post('/sm-user-project/activate', 'UserManagement\UserProjectController@activate_project');
Route::post('/sm-user-project/save-activate', 'UserManagement\UserProjectController@save_activate_project');

Route::get('/sm-user-project/reload/{id}', 'UserManagement\UserProjectController@reload_project');

// GROUP
Route::get('/sm-group-user', 'UserManagement\GroupUserController@inquiry');
Route::post('/sm-group-user-list', 'UserManagement\GroupUserController@inquiry_data');
Route::post('/sm-group-user-specific-list/{id?}', 'UserManagement\GroupUserController@inquiry_data_by_user');
Route::get('/sm-group-user/create/{id?}', 'UserManagement\GroupUserController@create');
Route::get('/sm-group-user/update/{id}', 'UserManagement\GroupUserController@update');
Route::post('/sm-group-user/save', 'UserManagement\GroupUserController@save');

// GROUP - FORM
Route::post('/sm-group-form/create', 'UserManagement\GroupUserController@create_form');
Route::post('/sm-group-form/update/{id}', 'UserManagement\GroupUserController@update_form');
Route::post('/sm-group-form/save', 'UserManagement\GroupUserController@save_form');
Route::post('/sm-group-form/delete', 'UserManagement\GroupUserController@delete_form');
Route::post('/sm-group-form/save-delete', 'UserManagement\GroupUserController@save_delete_form');

// RELOAD TABLE USER GROUP AFTER SAVE
Route::get('/sm-group-form/reload/{id}', 'UserManagement\GroupUserController@reload_form');

// APPLICATION
Route::get('/sm-application', 'UserManagement\ApplicationController@inquiry');
Route::post('/sm-application-list', 'UserManagement\ApplicationController@inquiry_data');
Route::get('/sm-application/create', 'UserManagement\ApplicationController@create');
Route::get('/sm-application/update/{id}', 'UserManagement\ApplicationController@update');
Route::post('/sm-application/save', 'UserManagement\ApplicationController@save');

// FORM - MENU (ACCESS CONTROL FORM)
Route::get('/sm-form', 'UserManagement\FormController@inquiry');
Route::post('/sm-form-list', 'UserManagement\FormController@inquiry_data');
Route::post('/sm-form-specific-list/{id?}', 'UserManagement\FormController@inquiry_data_by_group');
Route::get('/sm-form/create/{id?}', 'UserManagement\FormController@create');
Route::get('/sm-form/update/{id}', 'UserManagement\FormController@update');
Route::post('/sm-form/save', 'UserManagement\FormController@save');