<?php

namespace App\Service;

class UploadService
{
    private static function save(
        array  $file,
        string $directory
    ): string
    {
        if (!is_dir(STORAGE_PATH . $directory)) {
            mkdir(STORAGE_PATH . $directory, 0755, true);
        }

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
            STORAGE_PATH
            . $directory
            . "/"
            . $filename;

        $absolutePath =
            __DIR__
            . "/../../"
            . $relativePath;

        move_uploaded_file(
            $file["tmp_name"],
            $absolutePath
        );

        return IMAGE_URL
        . $directory
        . "/"
        . $filename;
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
            . "/../../"
            . $path;

        if (file_exists($absolutePath)) {
            unlink($absolutePath);
        }
    }
}