<?php

namespace App;

class Validator
{
    /**
     * Ensures a payload exists.
     *
     * @param array $source
     * @param string $key
     *
     * @return array
     */
    public static function payload(array $source, string $key): array
    {
        if (
            !isset($source[$key]) ||
            !is_array($source[$key])
        ) {
            Response::error([
                ucfirst($key) . ' payload is required.'
            ]);
        }

        return $source[$key];
    }

    /**
     * Ensures required fields exist.
     *
     * @param array $payload
     * @param array $required
     *
     * @return array
     */
    public static function required(
        array $payload,
        array $required
    ): array
    {
        $errors = [];

        foreach ($required as $field) {
            if (
                !isset($payload[$field]) ||
                trim((string)$payload[$field]) === ''
            ) {
                $errors[] = "$field is required.";
            }
        }

        if (!empty($errors)) {
            Response::error($errors);
        }

        return $payload;
    }

    /**
     * Optional string.
     */
    public static function nullableString(
        array  $payload,
        string $field
    ): ?string
    {
        if (
            !isset($payload[$field]) ||
            trim($payload[$field]) === ''
        ) {
            return null;
        }

        return trim($payload[$field]);
    }

    /**
     * Validate integer fields.
     *
     * @param array $payload
     * @param array $fields
     *
     * @return void
     */
    public static function integer(
        array $payload,
        array $fields
    ): void
    {
        $errors = [];

        foreach ($fields as $field) {
            if (
                isset($payload[$field]) &&
                filter_var($payload[$field], FILTER_VALIDATE_INT) === false
            ) {
                $errors[] = "$field must be an integer.";
            }
        }

        if (!empty($errors)) {
            Response::error($errors);
        }
    }

    /**
     * Validate string fields.
     */
    public static function string(
        array $payload,
        array $fields
    ): void
    {
        $errors = [];

        foreach ($fields as $field) {
            if (
                isset($payload[$field]) &&
                !is_string($payload[$field])
            ) {
                $errors[] = "$field must be a string.";
            }
        }

        if (!empty($errors)) {
            Response::error($errors);
        }
    }

    /**
     * Validate numeric range.
     */
    public static function between(
        array $payload,
        string $field,
        int $min,
        int $max
    ): void
    {
        if (!isset($payload[$field])) {
            return;
        }

        $value = (int)$payload[$field];

        if (
            $value < $min ||
            $value > $max
        ) {
            Response::error([
                "$field must be between $min and $max."
            ]);
        }
    }

    public static function exists(
        array $payload,
        string $field
    ): void
    {
        if (!isset($payload[$field])) {

            Response::error([
                "$field is required."
            ]);

        }
    }

    public static function positive(
        array $payload,
        array $fields
    ): void
    {
        $errors = [];

        foreach ($fields as $field) {
            if (
                isset($payload[$field]) &&
                (int)$payload[$field] <= 0
            ) {
                $errors[] =
                    "$field must be positive.";
            }
        }

        if (!empty($errors)) {
            Response::error($errors);
        }
    }

    /**
     * Validate uploaded image.
     *
     * @param array $files Typically $_FILES.
     * @param string $field File input name.
     * @param array $extensions Allowed extensions.
     * @param int $maxSize Maximum file size in bytes.
     *
     * @return array Uploaded file information.
     */
    public static function image(
        array $files,
        string $field,
        array $extensions = ['jpg', 'jpeg', 'png', 'webp'],
        int $maxSize = 10 * 1024 * 1024
    ): array
    {
        if (
            !isset($files[$field]) ||
            $files[$field]['error'] === UPLOAD_ERR_NO_FILE
        ) {
            Response::error([
                "$field image is required."
            ]);
        }

        $file = $files[$field];

        if ($file['error'] !== UPLOAD_ERR_OK) {
            Response::error([
                "$field upload failed."
            ]);
        }

        if ($file['size'] > $maxSize) {
            Response::error([
                "$field exceeds the maximum size of "
                . ($maxSize / 1024 / 1024)
                . " MB."
            ]);
        }

        $extension = strtolower(
            pathinfo(
                $file['name'],
                PATHINFO_EXTENSION
            )
        );

        if (!in_array($extension, $extensions, true)) {
            Response::error([
                "$field must be one of: "
                . implode(', ', $extensions)
            ]);
        }

        return $file;
    }
}