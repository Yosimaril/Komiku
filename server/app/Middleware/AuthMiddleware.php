<?php

namespace App\Middleware;

use App\Response;
use App\Service\JwtService;

class AuthMiddleware
{
    private static ?array $user = null;

    public static function authenticate(): void
    {
        $header = $_SERVER["HTTP_AUTHORIZATION"] ?? "";

        if (
            !preg_match(
                "/Bearer\s+(.+)/",
                $header,
                $matches
            )
        ) {
            Response::error([
                "Authorization header is missing."
            ], 401);
        }

        $payload =
            JwtService::validateAndGetPayload(
                $matches[1]
            );

        if ($payload === null) {
            Response::error([
                "Invalid or expired token."
            ], 401);
        }

        self::$user = $payload;
    }

    public static function getUser(): array
    {
        return self::$user;
    }
}