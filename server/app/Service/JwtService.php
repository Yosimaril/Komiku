<?php

namespace App\Service;

class JwtService
{
    /**
     * Generate JWT.
     *
     * @param int $userId
     *
     * @return string
     */
    public static function generate(
        int $userId,
    ): string
    {
        $header = [
            "alg" => "HS256",
            "typ" => "JWT"
        ];

        $payload = [
            "sub" => $userId,
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
            JWT_SECRET,
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

    private static function base64UrlDecode(
        string $data
    ): string
    {
        return base64_decode(
            strtr(
                $data,
                '-_',
                '+/'
            )
        );
    }

    /**
     * Validate JWT.
     *
     * @param string $token
     *
     * @return bool
     */
    public static function validate(
        string $token
    ): bool
    {
        $parts = explode(".", $token);

        if (count($parts) !== 3) {
            return false;
        }

        [$header, $payload, $signature] = $parts;

        // Validate signature.
        $expectedSignature = self::base64UrlEncode(
            hash_hmac(
                "sha256",
                "$header.$payload",
                JWT_SECRET,
                true
            )
        );

        if (!hash_equals($expectedSignature, $signature)) {
            return false;
        }

        // Decode payload.
        $payload = json_decode(
            self::base64UrlDecode($payload),
            true
        );

        if (!is_array($payload)) {
            return false;
        }

        // Validate required claims.
        foreach (["sub", "iat", "exp"] as $claim) {
            if (!isset($payload[$claim])) {
                return false;
            }
        }

        // Validate issued-at and expiration time.
        $currentTime = time();

        if ($payload["exp"] <= $currentTime) {
            return false;
        }

        if ($payload["iat"] > $currentTime) {
            return false;
        }

        return true;
    }

    /**
     * Get JWT payload.
     *
     * Assumes the token has already been validated.
     * So, remember to validate first.
     *
     * @param string $token
     *
     * @return array
     */
    public static function payload(
        string $token
    ): array
    {
        [, $payload,] = explode(".", $token);

        return json_decode(
            self::base64UrlDecode($payload),
            true
        );
    }

    /**
     * Validate and get payload.
     *
     * @param string $token
     *
     * @return array|null
     */
    public static function validateAndGetPayload(
        string $token
    ): ?array
    {
        if (!self::validate($token)) {
            return null;
        }

        return self::payload($token);
    }
}