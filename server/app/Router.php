<?php

namespace App;

use App\Controllers\OptionController;
use App\Enums\Action;
use App\Controllers\CategoryController;

class Router
{
    private const ROUTES = [
        Action::OPTIONS->value => [OptionController::class, 'info'],

        Action::GET_CATEGORIES->value => [CategoryController::class, 'get'],
        Action::INSERT_CATEGORY->value => [CategoryController::class, 'insert'],
        Action::UPDATE_CATEGORY->value => [CategoryController::class, 'update'],
        Action::DELETE_CATEGORY->value => [CategoryController::class, 'delete'],
    ];

    public static function dispatch(Action $action): void
    {
        $handler = self::ROUTES[$action->value] ?? null;

        if ($handler === null) {
            Response::error([
                'Action not implemented.',
            ]);
        }

        $handler();
    }
}