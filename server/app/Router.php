<?php

namespace App;

use App\Enums\Action;

class Router
{
    private const ROUTES = [
        Action::GET_CATEGORIES => [CategoryController::class, 'index'],
    ];

    public static function dispatch(Action $action): void
    {
        if (!isset(self::ROUTES[$action])) {
            Response::error([
                "Action not implemented."
            ]);
        }

        call_user_func(self::ROUTES[$action]);
    }
}