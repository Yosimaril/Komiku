<?php

namespace App\Controllers;

use App\Database\Database;
use App\Middleware\AuthMiddleware;
use App\Response;
use App\Service\UploadService;
use App\Validator;

class ChapterPageController extends BaseController
{
    /**
     * Retrieve all pages of a chapter.
     *
     * Payload:
     * - chapter_id
     *
     * @return void
     */
    public static function get(): void
    {
        self::execute(function () {
            $payload = static::getRequestPayload();
            Validator::required($payload, ['chapter_id']);
            Validator::integer($payload, ['chapter_id']);
            Validator::positive($payload, ['chapter_id']);

            $chapterId = (int)$payload['chapter_id'];

            $statement = Database::prepare("
                SELECT
                    p.id,
                    ch.title AS chapter_title,
                    p.page_number,
                    p.image,
                    p.created_at,
                    p.updated_at
                FROM chapter_pages p
                JOIN chapters ch
                    ON ch.id = p.chapter_id
                WHERE p.chapter_id = ?
                ORDER BY p.page_number ASC
            ");

            $statement->bind_param(
                "i",
                $chapterId
            );

            Database::execute($statement);

            $pages = Database::all($statement);

            $result = [];

            foreach ($pages as $page) {
                $result[] = [
                    "id" => (int)$page["id"],
                    "chapter_title" => $page["chapter_title"],
                    "page_number" => (int)$page["page_number"],
                    "image" => "https://ubaya.cloud/flutter/160423120/app/" . $page["image"],
                    "created_at" => $page["created_at"],
                    "updated_at" => $page["updated_at"],
                ];
            }

            Response::success($result);
        });
    }

    /**
     * Insert new page(s) for a chapter.
     *
     * Payload:
     * - chapter_id
     * - pages[
     *      [
     *          page_number,
     *          image
     *      ],
     *      ...
     * ]
     *
     * @return void
     */
    public static function insert(): void
    {
        self::execute(function () {
            $payload = static::getRequestPayload();

            Validator::required($payload, ["chapter_id", "pages"]);
            Validator::integer($payload, ["chapter_id"]);
            Validator::positive($payload, ["chapter_id"]);

            if (
                !is_array($payload["pages"]) ||
                empty($payload["pages"])
            ) {
                Response::error([
                    "pages must be a non-empty array."
                ]);
            }

            $chapterId = (int)$payload["chapter_id"];
            $creatorId = AuthMiddleware::getUserId();

            $statement = Database::prepare("
                SELECT c.creator_id
                FROM chapters ch
                JOIN comics c
                    ON c.id = ch.comic_id
                WHERE ch.id = ?
            ");

            $statement->bind_param(
                "i",
                $chapterId
            );

            Database::execute($statement);

            $chapter = Database::first($statement);

            if (!$chapter) {
                Response::error([
                    "Chapter not found."
                ], 404);
            }

            if ((int)$chapter["creator_id"] !== $creatorId) {
                Response::error([
                    "Permission denied."
                ], 403);
            }

            $pages = $payload["pages"];

            $inserted = Database::transaction(
                function () use ($pages, $chapterId) {

                    $statement = Database::prepare("
                        INSERT INTO chapter_pages
                        (
                            chapter_id,
                            page_number,
                            image
                        )
                        VALUES (?, ?, ?)
                    ");

                    $inserted = [];

                    foreach ($pages as $index => $page) {

                        Validator::required(
                            $page,
                            ["page_number"]
                        );

                        Validator::integer(
                            $page,
                            ["page_number"]
                        );

                        Validator::positive(
                            $page,
                            ["page_number"]
                        );

                        $fileKey = "image_$index";

                        $image = UploadService::saveChapterPage(
                            Validator::image(
                                $_FILES,
                                $fileKey
                            )
                        );

                        $statement->bind_param(
                            "iis",
                            $chapterId,
                            $page["page_number"],
                            $image
                        );

                        Database::execute($statement);

                        $inserted[] = [
                            "id" => Database::getConnection()->insert_id,
                            "page_number" => $page["page_number"],
                            "image" => "https://ubaya.cloud/flutter/160423120/app/" . $image
                        ];
                    }

                    return $inserted;
                }
            );

            Response::success([
                "chapter_id" => $chapterId,
                "pages" => $inserted
            ], 201);
        });
    }

    /**
     * Update an existing page.
     *
     * Payload:
     * page[
     *      id,
     *      page_number,
     *      image
     * ]
     *
     * @return void
     */
    public static function update(): void
    {
        self::execute(function () {
            $payload = static::getRequestPayload();

            $page = Validator::payload(
                $payload,
                "page"
            );

            Validator::required($page, [
                "id",
                "page_number"
            ]);

            Validator::integer($page, [
                "id",
                "page_number"
            ]);

            Validator::positive($page, [
                "id",
                "page_number"
            ]);

            $creatorId = AuthMiddleware::getUserId();

            $statement = Database::prepare("
                SELECT
                    p.id,
                    p.image
                FROM comics c
                JOIN chapters ch
                    ON ch.comic_id = c.id
                JOIN chapter_pages p
                    ON p.chapter_id = ch.id
                WHERE
                    p.id = ?
                    AND c.creator_id = ?
            ");

            $statement->bind_param(
                "ii",
                $page["id"],
                $creatorId
            );

            Database::execute($statement);

            $oldPage = Database::first($statement);

            if (!$oldPage) {
                Response::error([
                    "Page not found or permission denied."
                ], 403);
            }

            $image = UploadService::saveChapterPage(
                Validator::image($_FILES, "image")
            );

            UploadService::delete($oldPage["image"]);

            $statement = Database::prepare("
                UPDATE chapter_pages
                SET
                    page_number = ?,
                    image = ?
                WHERE id = ?
            ");

            $statement->bind_param(
                "isi",
                $page["page_number"],
                $image,
                $page["id"]
            );

            Database::execute($statement);

            Response::success([
                "updated" => Database::isRowAffected($statement)
            ]);
        });
    }

    /**
     * Delete a page.
     *
     * Payload:
     * - id
     *
     * @return void
     */
    public static function delete(): void
    {
        self::execute(function () {
            $payload = static::getRequestPayload();

            Validator::required($payload, ["id"]);
            Validator::integer($payload, ["id"]);
            Validator::positive($payload, ["id"]);

            $creatorId = AuthMiddleware::getUserId();

            $statement = Database::prepare("
                SELECT
                    p.id,
                    p.image
                FROM chapter_pages p
                JOIN chapters ch
                    ON ch.id = p.chapter_id
                JOIN comics c
                    ON c.id = ch.comic_id
                WHERE
                    p.id = ?
                    AND c.creator_id = ?
            ");

            $statement->bind_param(
                "ii",
                $payload["id"],
                $creatorId
            );

            Database::execute($statement);

            $page = Database::first($statement);

            if (!$page) {
                Response::error([
                    "Page not found or permission denied."
                ], 403);
            }

            $statement = Database::prepare("
                DELETE FROM chapter_pages
                WHERE id = ?
            ");

            $statement->bind_param(
                "i",
                $payload["id"]
            );

            Database::execute($statement);

            $deleted = Database::isRowAffected($statement);

            if ($deleted) {
                UploadService::delete($page["image"]);
            }

            Response::success([
                "deleted" => $deleted
            ]);
        });
    }
}