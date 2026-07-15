<?php

namespace App\Service;

class UploadService
{
    private static function save(
        array  $file,
        string $directory
    ): string
    {
        $extension = strtolower(
            pathinfo(
                $file["name"],
                PATHINFO_EXTENSION
            )
        );

        $filename =
            bin2hex(random_bytes(16))
            . "."
            . $extension;

        $relativePath =
            "Storage/$directory/"
            . $filename;

        $absolutePath =
            __DIR__
            . "/../"
            . $relativePath;

        move_uploaded_file(
            $file["tmp_name"],
            $absolutePath
        );

        return $relativePath;
    }

    public static function saveComicPoster(array $file): string
    {
        return self::save($file, "comics");
    }

    public static function saveChapterPage(array $file): string
    {
        return self::save($file, "chapter_pages");
    }

    public static function delete(?string $path): void
    {
        if ($path === null) {
            return;
        }

        $absolutePath =
            __DIR__
            . "/../"
            . $path;

        if (file_exists($absolutePath)) {
            unlink($absolutePath);
        }
    }
}