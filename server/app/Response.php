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
            "STATUS" => "SUCCESS",
            "DATA" => $data,
            "ERROR_MESSAGE" => []
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
            "STATUS" => "ERROR",
            "DATA" => [],
            "ERROR_MESSAGE" => $errors
        ]);

        exit();
    }
}