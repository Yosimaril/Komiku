<?php

namespace App\Middleware;

use App\Enums\Action;

class RequestMiddleware
{
    public static function getAction(): Action
    {
        $action = $_POST['action'] ?? 'OPTIONS';

        $enum = Action::tryFrom($action);

        if (!$enum) {
            self::error($action, ['Invalid action.']);
        }

        return $enum;
    }

    private static function error(string $action, array $errors): never
    {
        echo json_encode([
            'ACTION' => $action,
            'STATUS' => 'ERROR',
            'DATA' => [],
            'ERROR_MESSAGE' => $errors
        ]);

        exit;
    }
}