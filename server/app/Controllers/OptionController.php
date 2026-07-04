<?php

namespace App\Controllers;

use App\Docs\ApiDocumentation;
use App\Enums\Action;
use App\Response;

class OptionController extends BaseController
{
    public static function info(): void
    {
        self::execute(function () {
            Response::success(ApiDocumentation::API);
        });
    }
}