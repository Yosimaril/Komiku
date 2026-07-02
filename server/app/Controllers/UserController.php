<?php

namespace App\Controllers;

use App\Response;

class UserController
{
    public static function login()
    {
        // TODO: Implement login
        Response::success([
            'message' => 'Login'
        ]);
    }

    public static function register()
    {
        // TODO: Implement register
        Response::success([
            'message' => 'Register'
        ]);
    }
}