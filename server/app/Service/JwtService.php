<?php

class JwtService
{
    public static function generate(
        int    $userId,
        string $username
    )
    {
        $header = [
            "alg" => "HS256",
            "typ" => "JWT"
        ];

        $payload = [
            "sub" => $userId,
            "username" => $username,
            "iat" => time(),
            "exp" => time() + 24 * 3600
        ];

        $header = self::base64UrlEncode(
            json_encode($header)
        );

        $payload = self::base64UrlEncode(
            json_encode($payload)
        );

        $signature = hash_hmac(
            "sha256",
            "$header.$payload",
            "1234567890",
            true
        );

        $signature = self::base64UrlEncode(
            $signature
        );

        return "$header.$payload.$signature";
    }

    private static function base64UrlEncode(
        string $data
    ): string
    {
        return rtrim(
            strtr(
                base64_encode($data),
                "+/",
                "-_"
            ),
            "="
        );
    }
}