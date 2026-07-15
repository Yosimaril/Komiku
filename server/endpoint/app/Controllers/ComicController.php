<?php

namespace App\Controllers;

use App\Database\Database;
use App\Middleware\AuthMiddleware;
use App\Response;
use App\Validator;

class ComicController extends BaseController
{
    /**
     * Retrieve all comics.
     *
     * Payload:
     * - keyword (optional)
     *
     * @return void
     */
    public static function get(): void
    {
        self::execute(function () {
            $keyword = trim($_POST['keyword'] ?? '');

            $query = "
                SELECT
                    c.id,
                    c.title,
                    c.poster,
                    c.description,
                    u.username AS creator_name,
                    c.created_at,
                    c.updated_at,
                    cat.id AS category_id,
                    cat.name AS category_name,
                    COALESCE(r.average_rating, 0) AS average_rating,
                    COALESCE(r.rating_count, 0) AS rating_count
                FROM comics c
                JOIN users u
                    ON u.id = c.creator_id
                LEFT JOIN category_comic cc
                    ON cc.comic_id = c.id
                LEFT JOIN categories cat
                    ON cat.id = cc.category_id
                LEFT JOIN (
                    SELECT
                        comic_id,
                        AVG(rating) AS average_rating,
                        COUNT(*) AS rating_count
                    FROM comic_rated_by_user
                    GROUP BY comic_id
                ) r
                    ON r.comic_id = c.id
            ";

            if ($keyword !== '') {
                $query .= " WHERE c.title LIKE ?";
            }

            $query .= " ORDER BY c.title";

            $statement = Database::prepare($query);

            if ($keyword !== '') {
                $keyword = "%{$keyword}%";
                $statement->bind_param(
                    "s",
                    $keyword
                );
            }

            Database::execute($statement);

            $rows = Database::all($statement);

            $comics = [];

            foreach ($rows as $row) {
                $id = $row['id'];

                if (!isset($comics[$id])) {
                    $comics[$id] = [
                        'id' => (int)$row['id'],
                        'title' => $row['title'],
                        'poster' => $row['poster'],
                        'description' => $row['description'],
                        'average_rating' => round((float)$row['average_rating'], 2),
                        'rating_count' => (int)$row['rating_count'],
                        'categories' => [],
                        'creator_name' => $row['creator_name'],
                        'created_at' => $row['created_at'],
                        'updated_at' => $row['updated_at'],
                    ];
                }

                if ($row['category_id'] !== null) {
                    $comics[$id]['categories'][] = [
                        'id' => (int)$row['category_id'],
                        'name' => $row['category_name'],
                    ];
                }
            }

            Response::success(
                array_values($comics)
            );
        });
    }

    /**
     * Retrieve comic detail.
     *
     * Payload:
     * - id
     *
     * @return void
     */
    public static function getDetail(): void
    {
        self::execute(function () {
            Validator::required($_POST, ['id']);
            Validator::integer($_POST, ['id']);
            Validator::positive($_POST, ['id']);

            $id = $_POST['id'];

            $statement = Database::prepare("
                SELECT
                    c.*,
                    u.id AS creator_id,
                    u.username
                FROM comics c
                JOIN users u
                    ON u.id = c.creator_id
                WHERE c.id = ?
            ");

            $statement->bind_param(
                "i",
                $id
            );

            Database::execute($statement);

            $comic = Database::first($statement);

            if (!$comic) {
                Response::error([
                    "Comic not found."
                ], 404);
            }

            $statement = Database::prepare("
                SELECT
                    AVG(rating) AS average_rating,
                    COUNT(*) AS rating_count
                FROM comic_rated_by_user
                WHERE comic_id = ?
            ");

            $statement->bind_param(
                "i",
                $id
            );

            Database::execute($statement);

            $rating = Database::first($statement);

            $statement = Database::prepare("
                SELECT
                    c.id,
                    c.parent_comment_id,
                    c.content,
                    c.created_at,
                    c.updated_at,
                    u.id AS user_id,
                    u.username
                FROM comments c
                LEFT JOIN users u
                    ON u.id = c.user_id
                WHERE comic_id = ?
                ORDER BY c.created_at
            ");

            $statement->bind_param(
                "i",
                $id
            );

            Database::execute($statement);

            $comments = Database::all($statement);

            $statement = Database::prepare("
                SELECT *
                FROM chapters
                WHERE comic_id = ?
                ORDER BY chapter_number
            ");

            $statement->bind_param(
                "i",
                $id
            );

            Database::execute($statement);

            $chapters = Database::all($statement);

            foreach ($chapters as &$chapter) {
                $statement = Database::prepare("
                    SELECT
                        id,
                        page_number,
                        image
                    FROM chapter_pages
                    WHERE chapter_id = ?
                    ORDER BY page_number
                ");

                $statement->bind_param(
                    "i",
                    $chapter['id']
                );

                Database::execute($statement);

                $chapter['chapter_pages'] = Database::all($statement);
            }

            unset($chapter);

            Response::success([
                'id' => $comic['id'],
                'creator' => [
                    'id' => $comic['creator_id'],
                    'username' => $comic['username']
                ],
                'title' => $comic['title'],
                'poster' => $comic['poster'],
                'description' => $comic['description'],
                'created_at' => $comic['created_at'],
                'updated_at' => $comic['updated_at'],
                'average_rating' => round(
                    (float)$rating['average_rating'],
                    2
                ),
                'rating_count' => (int)$rating['rating_count'],
                'comments' => $comments,
                'chapters' => $chapters
            ]);
        });
    }

    /**
     * Insert a new comic.
     *
     * Payload:
     * comic[
     *      title,
     *      poster (optional),
     *      description (optional)
     * ]
     *
     * @return void
     */
    public static function insert(): void
    {
        self::execute(function () {
            $comic = Validator::payload(
                $_POST,
                "comic"
            );

            Validator::required($comic, ["title"]);
            Validator::string($comic, ["title"]);

            $creatorId = AuthMiddleware::getUserId();

            $poster = Validator::nullableString(
                $comic,
                "poster"
            );

            $description = Validator::nullableString(
                $comic,
                "description"
            );

            $statement = Database::prepare("
                INSERT INTO comics
                (
                    creator_id,
                    title,
                    poster,
                    description
                )
                VALUES (?, ?, ?, ?)
            ");

            $statement->bind_param(
                "isss",
                $creatorId,
                $comic["title"],
                $poster,
                $description
            );

            Database::execute($statement);

            Response::success([
                "comic" => [
                    "id" => Database::getConnection()->insert_id,
                    "creator_id" => $creatorId,
                    "title" => $comic["title"],
                    "poster" => $poster,
                    "description" => $description
                ]
            ], 201);
        });
    }

    /**
     * Update an existing comic.
     *
     * Payload:
     * comic[
     *      id,
     *      title,
     *      poster (optional),
     *      description (optional)
     * ]
     *
     * @return void
     */
    public static function update(): void
    {
        self::execute(function () {
            $comic = Validator::payload(
                $_POST,
                "comic"
            );

            Validator::required($comic, ["id", "title"]);
            Validator::integer($comic, ["id"]);
            Validator::positive($comic, ["id"]);
            Validator::string($comic, ["title"]);

            $creatorId = AuthMiddleware::getUserId();

            $statement = Database::prepare("
                SELECT id
                FROM comics
                WHERE id = ?
                    AND creator_id = ?
            ");

            $statement->bind_param(
                "ii",
                $comic["id"],
                $creatorId
            );

            Database::execute($statement);

            if (!Database::first($statement)) {
                Response::error([
                    "Comic not found or permission denied."
                ], 403);
            }

            $poster = Validator::nullableString(
                $comic,
                "poster"
            );

            $description = Validator::nullableString(
                $comic,
                "description"
            );

            $statement = Database::prepare("
                UPDATE comics
                SET
                    title = ?,
                    poster = ?,
                    description = ?
                WHERE id = ?
            ");

            $statement->bind_param(
                "sssi",
                $comic["title"],
                $poster,
                $description,
                $comic["id"]
            );

            Database::execute($statement);

            Response::success([
                "updated" => Database::isRowAffected($statement)
            ]);
        });
    }

    /**
     * Delete a comic.
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
                SELECT id
                FROM comics
                WHERE id = ?
                    AND creator_id = ?
            ");

            $statement->bind_param(
                "ii",
                $_POST["id"],
                $creatorId
            );

            Database::execute($statement);

            if (!Database::first($statement)) {
                Response::error([
                    "Comic not found or permission denied."
                ], 403);
            }

            $statement = Database::prepare("
                DELETE FROM comics
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