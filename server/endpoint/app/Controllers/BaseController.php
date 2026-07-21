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

        // Multipart/form-data
        if (!empty($_POST)) {

            self::$request = $_POST;

            foreach (self::$request as $key => $value) {

                // If its already parsed by PHP.
                if (is_array($value)) {
                    continue;
                }

                if (!is_string($value)) {
                    continue;
                }

                $decoded = json_decode($value, true);

                if (json_last_error() === JSON_ERROR_NONE) {
                    self::$request[$key] = $decoded;
                }
            }

            return self::$request;
        }

        // JSON
        $input = file_get_contents("php://input");

        if (trim($input) === "") {
            return [];
        }

        self::$request = json_decode($input, true);

        if (json_last_error() !== JSON_ERROR_NONE) {
            Response::error(["Invalid JSON payload."], 400);
        }

        return self::$request;
    }
}