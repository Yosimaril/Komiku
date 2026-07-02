<?php

namespace App\Middleware;

use App\Enums\Action;
use App\Response;

class RequestMiddleware
{
    public static function getAction(): Action
    {
        $action = $_POST['action'] ?? 'OPTIONS';

        $enum = Action::tryFrom($action);

        if (!$enum) {
            Response::error([
                'Invalid action payload.',
            ]);
        }

        return $enum;
    }
}