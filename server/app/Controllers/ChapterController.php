<?php

namespace App\Controllers;

use App\Database\Database;
use App\Middleware\AuthMiddleware;
use App\Response;
use App\Validator;
use Exception;

class ChapterController extends BaseController
{
    /**
     * Retrieve all chapters of a comic.
     *
     * Payload:
     * - comic_id
     * - keyword (optional)
     *
     * @return void
     */
    public static function get(): void
    {
        self::execute(function () {
            Validator::required($_POST, ['comic_id']);
            Validator::integer($_POST, ['comic_id']);
            Validator::positive($_POST, ['comic_id']);

            $comicId = (int)$_POST['comic_id'];
            $keyword = trim($_POST['keyword'] ?? '');

            $query = "
                SELECT
                    ch.id,
                    c.title AS comic_title,
                    ch.chapter_number,
                    ch.title,
                    ch.created_at,
                    ch.updated_at
                FROM chapters ch
                JOIN comics c
                    ON ch.comic_id = c.id
                WHERE ch.comic_id = ?
            ";

            if ($keyword !== '') {
                $query .= " AND ch.title LIKE ?";
            }

            $query .= " ORDER BY ch.chapter_number ASC";

            $statement = Database::prepare($query);

            if ($keyword !== '') {
                $keyword = "%{$keyword}%";
                $statement->bind_param(
                    "is",
                    $comicId,
                    $keyword
                );
            } else {
                $statement->bind_param(
                    "i",
                    $comicId
                );
            }

            Database::execute($statement);

            Response::success(
                Database::all($statement)
            );
        });
    }

    /**
     * Insert new chapter(s) for a comic.
     *
     * Payload:
     * - comic_id
     * - chapters[
     *      [
     *          chapter_number,
     *          title,
     *      ],
     *      ...
     * ]
     *
     * @return void
     */
    public static function insert(): void
    {
        self::execute(function () {
            Validator::required($_POST, ["comic_id", "chapters"]);
            Validator::integer($_POST, ["comic_id"]);
            Validator::positive($_POST, ["comic_id"]);

            if (
                !is_array($_POST["chapters"]) ||
                empty($_POST["chapters"])
            ) {
                Response::error([
                    "chapters must be a non-empty array."
                ]);
            }

            $comicId = (int)$_POST["comic_id"];
            $creatorId = AuthMiddleware::getUserId();

            $statement = Database::prepare("
                SELECT creator_id
                FROM comics
                WHERE id = ?
            ");

            $statement->bind_param(
                "i",
                $comicId
            );

            Database::execute($statement);

            $comic = Database::first($statement);

            if (!$comic) {
                Response::error([
                    "Comic not found."
                ], 404);
            }

            if (
                (int)$comic["creator_id"] !== $creatorId
            ) {
                Response::error([
                    "Permission denied."
                ], 403);
            }

            $chapters = $_POST["chapters"];

            $inserted = Database::transaction(
                function () use ($chapters, $comicId){
                    $statement = Database::prepare("
                        INSERT INTO chapters
                        (
                            comic_id,
                            chapter_number,
                            title
                        )
                        VALUES (?, ?, ?)
                    ");

                    $inserted = [];

                    foreach ($chapters as $chapter) {
                        Validator::required($chapter, ["chapter_number", "title"]);
                        Validator::integer($chapter, ["chapter_number"]);
                        Validator::positive($chapter, ["chapter_number"]);
                        Validator::string($chapter, ["title"]);

                        $statement->bind_param(
                            "iis",
                            $comicId,
                            $chapter["chapter_number"],
                            $chapter["title"]
                        );

                        Database::execute($statement);

                        $inserted[] = [
                            "id" => Database::getConnection()->insert_id,
                            "chapter_number" => $chapter["chapter_number"],
                            "title" => $chapter["title"]
                        ];
                    }

                    return $inserted;
                }
            );

            Response::success([
                "comic_id" => $comicId,
                "chapters" => $inserted
            ], 201);
        });
    }

    /**
     * Update an existing chapter.
     *
     * Payload:
     * chapter[
     *      id,
     *      chapter_number,
     *      title
     * ]
     *
     * @return void
     */
    public static function update(): void
    {
        self::execute(function () {
            $chapter = Validator::payload(
                $_POST,
                "chapter"
            );

            Validator::required($chapter, ["id", "chapter_number", "title"]);
            Validator::integer($chapter, ["id", "chapter_number"]);
            Validator::positive($chapter, ["id", "chapter_number"]);
            Validator::string($chapter, ["title"]);

            $creatorId = AuthMiddleware::getUserId();

            $statement = Database::prepare("
                SELECT ch.id
                FROM chapters ch
                JOIN comics c
                    ON c.id = ch.comic_id
                WHERE
                    ch.id = ?
                    AND c.creator_id = ?
            ");

            $statement->bind_param(
                "ii",
                $chapter["id"],
                $creatorId
            );

            Database::execute($statement);

            if ($statement->get_result()->num_rows === 0) {
                Response::error([
                    "Chapter not found or permission denied."
                ], 403);
            }

            $statement = Database::prepare("
                UPDATE chapters
                SET
                    chapter_number = ?,
                    title = ?
                WHERE id = ?
            ");

            $statement->bind_param(
                "isi",
                $chapter["chapter_number"],
                $chapter["title"],
                $chapter["id"]
            );

            Database::execute($statement);

            Response::success([
                "updated" => Database::isRowAffected($statement)
            ]);
        });
    }

    /**
     * Delete a chapter.
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
                SELECT ch.id
                FROM chapters ch
                JOIN comics c
                    ON c.id = ch.comic_id
                WHERE
                    ch.id = ?
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
                    "Chapter not found or permission denied."
                ], 403);
            }

            $statement = Database::prepare("
                DELETE FROM chapters
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