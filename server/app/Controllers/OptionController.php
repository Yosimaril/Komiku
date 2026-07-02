<?php

namespace App\Controllers;

use App\Docs\ApiDocumentation;
use App\Enums\Action;
use App\Response;

class OptionController
{
    public static function info(): void
    {
        $docs = ApiDocumentation::all();

        $result = [];

        foreach (Action::cases() as $action) {

            $result[$action->value] =
                $docs[$action->value] ?? [
                'description' => 'No documentation.'
            ];

        }

        Response::success($result);
    }
}