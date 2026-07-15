<?php

namespace App\Controllers;

use App\Response;
use Exception;

abstract class BaseController
{
    protected static ?array $request = null;

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

    /**
     * Get the request payload from php://input (JSON).
     *
     * @return array
     */
    public static function getRequestPayload(): array
    {
        if (self::$request !== null) {
            return self::$request;
        }

        // Documentation page / GET request
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            self::$request = [];
            return self::$request;
        }

        $input = file_get_contents('php://input');

        // Empty body
        if (trim($input) === '') {
            self::$request = [];
            return self::$request;
        }

        self::$request = json_decode($input, true);

        if (json_last_error() !== JSON_ERROR_NONE) {
            Response::error(['Invalid JSON payload.'], 400);
        }

        return self::$request;
    }
}