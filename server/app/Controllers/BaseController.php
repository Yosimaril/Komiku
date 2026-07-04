<?php

namespace App\Controllers;

use App\Response;
use Exception;

abstract class BaseController
{
    protected static function execute(callable $callback): void
    {
        try {
            $callback();
        } catch (Exception $e) {
            Response::error([
                $e->getMessage()
            ], 500);
        }
    }
}