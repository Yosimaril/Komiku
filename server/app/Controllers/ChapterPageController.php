<?php

namespace App\Controllers;

use App\Database\Database;
use App\Middleware\AuthMiddleware;
use App\Response;
use App\Validator;
use Exception;

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
            Validator::required($_POST, ['chapter_id']);
            Validator::integer($_POST, ['chapter_id']);
            Validator::positive($_POST, ['chapter_id']);

            $chapterId = (int)$_POST['chapter_id'];

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

            Response::success(
                Database::all($statement)
            );
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
            Validator::required($_POST, ["chapter_id", "pages"]);
            Validator::integer($_POST, ["chapter_id"]);
            Validator::positive($_POST, ["chapter_id"]);

            if (
                !is_array($_POST["pages"]) ||
                empty($_POST["pages"])
            ) {
                Response::error([
                    "pages must be a non-empty array."
                ]);
            }

            $chapterId = (int)$_POST["chapter_id"];
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

            $chapter = $statement
                ->get_result()
                ->fetch_assoc();

            if (!$chapter) {
                Response::error([
                    "Chapter not found."
                ], 404);
            }

            if (
                (int)$chapter["creator_id"] !== $creatorId
            ) {
                Response::error([
                    "Permission denied."
                ], 403);
            }

            $pages = $_POST["pages"];

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

                    foreach ($_POST["pages"] as $page) {
                        Validator::required($page, ["page_number", "image"]);
                        Validator::integer($page, ["page_number"]);
                        Validator::positive($page, ["page_number"]);
                        Validator::string($page, ["image"]);

                        $statement->bind_param(
                            "iis",
                            $chapterId,
                            $page["page_number"],
                            $page["image"]
                        );

                        Database::execute($statement);

                        $inserted[] = [
                            "id" => Database::getConnection()->insert_id,
                            "page_number" => $page["page_number"],
                            "image" => $page["image"]
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
            $page = Validator::payload(
                $_POST,
                "page"
            );

            Validator::required($page, ["id", "page_number", "image"]);
            Validator::integer($page, ["id", "page_number"]);
            Validator::positive($page, ["id", "page_number"]);
            Validator::string($page, ["image"]);

            $creatorId = AuthMiddleware::getUserId();

            $statement = Database::prepare("
                SELECT p.id
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

            if ($statement->get_result()->num_rows === 0) {
                Response::error([
                    "Page not found or permission denied."
                ], 403);
            }

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
                $page["image"],
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
            Validator::required($_POST, ["id"]);
            Validator::integer($_POST, ["id"]);
            Validator::positive($_POST, ["id"]);

            $creatorId = AuthMiddleware::getUserId();

            $statement = Database::prepare("
                SELECT p.id
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
                $_POST["id"],
                $creatorId
            );

            Database::execute($statement);

            if ($statement->get_result()->num_rows === 0) {
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
                $_POST["id"]
            );

            Database::execute($statement);

            Response::success([
                "deleted" => Database::isRowAffected($statement)
            ]);
        });
    }
}