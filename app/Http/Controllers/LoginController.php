<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

// BASE CONTROLLER
use App\Http\Controllers\MyController;

use Validator;
use Mail;

class LoginController extends MyController
{  
    public function index(Request $request)
    {   
        $this->data['form_title'] = 'Home';
        $this->data['form_sub_title'] = 'Modules';
        $this->data['form_desc'] = 'Home';
        $this->data['breads'] = array('Home'); 
        $this->data['state'] = 'read';
        $this->data['url_save_header'] = '#';

        // URL
        $this->data['url'] = url('login/validate_user');

        // VIEW
        return view('login', $this->data);
    } 

    public function validate_user(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'UserID' => 'required',
            'UserPassword' => 'required',
        ],[
            'UserID.required' => 'User ID belum diisi!',
            'UserPassword.required' => 'Password belum diisi!',
        ]);

        if ($validator->fails())
        {
            return $this->validation_fails($validator->errors(), $request->input('UserID'));
        } 
        else 
        {

            $user_id = trim($request->post('UserID'));
            //$user_password = md5(trim($request->post('UserPassword')));

            $user_password = trim($request->post('UserPassword'));           
            
            $sql = "EXEC [USP_SM_CheckLoginValidation] '$user_id','$user_password'";
            $query = DB::connection('sqlsrv')->select($sql);

            $obj = array();        

            if($query)
            {
                foreach ($query as $row)
                {
                    if(strtolower($row->Result) == 'success')
                    {
                        session(['user_id' => $request['UserID']]);
                        session(['user_name' => $row->LogDesc]);
                        session(['user_index' => $row->ID]);
                        session(['token' => $request['_token']]);                    

                        $obj['flag'] = 'success';
                        $obj['message'] = 'Login Success!';
                        $obj['url_next'] = url('/home');

                    } else {

                        $obj['flag'] = 'error';
                        $obj['message'] = 'Invalid User Name or Password!';
                    }                
                }

            } else {

                $obj['flag'] = 'error';
                $obj['message'] = 'Invalid User Name or Password!';
            }        

            echo json_encode($obj);
        }
    }

    public function logout(Request $request)
    {
        $request->session()->flush();

        return redirect('/login');
    }
}