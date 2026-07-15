<?php

namespace App\Middleware;

use App\Controllers\BaseController;
use App\Enums\Action;
use App\Response;

class RequestMiddleware
{
    public static function getAction(): Action
    {
        $payload = BaseController::getRequestPayload();
        $action = $payload['action'] ?? 'OPTIONS';

        $enum = Action::tryFrom($action);

        if (!$enum) {
            Response::error([
                'Invalid action payload.',
            ]);
        }

        return $enum;
    }
}