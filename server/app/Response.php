<?php

namespace App;

class Response
{
    public static function success(
        mixed $data = [],
        int $status = 200
    ): never
    {
        http_response_code($status);

        echo json_encode([
            "status" => "SUCCESS",
            "data" => $data,
            "error_message" => []
        ]);

        exit();
    }

    public static function error(
        array $errors,
        int $status = 400
    ): never
    {
        http_response_code($status);

        echo json_encode([
            "status" => "ERROR",
            "data" => [],
            "error_message" => $errors
        ]);

        exit();
    }
}