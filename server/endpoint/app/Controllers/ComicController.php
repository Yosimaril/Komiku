<?php

namespace App\Controllers;

use App\Database\Database;
use App\Middleware\AuthMiddleware;
use App\Response;
use App\Service\UploadService;
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
            $payload = static::getRequestPayload();
            $keyword = trim($payload['keyword'] ?? '');

            $query = "
                SELECT
                    c.id,
                    c.title,
                    c.poster,
                    c.description,
                    u.username AS creator_name,
                    c.created_at,
                    c.updated_at,
                    c.views,
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
                        'poster' => IMAGE_FOLDER . $row['poster'],
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
            $payload = static::getRequestPayload();
            Validator::required($payload, ['id']);
            Validator::integer($payload, ['id']);
            Validator::positive($payload, ['id']);

            $id = $payload['id'];

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
                SELECT
                    c.id,
                    c.name
                FROM categories c
                JOIN category_comic cc
                    ON cc.category_id = c.id
                WHERE cc.comic_id = ?
            ");

            $statement->bind_param(
                "i",
                $id
            );

            Database::execute($statement);

            $categories = Database::all($statement);

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
                'poster' => IMAGE_FOLDER . $comic['poster'],
                'description' => $comic['description'],
                'views' => $comic['views'],
                'created_at' => $comic['created_at'],
                'updated_at' => $comic['updated_at'],
                'average_rating' => round(
                    (float)$rating['average_rating'],
                    2
                ),
                'rating_count' => (int)$rating['rating_count'],
                'categories' => $categories,
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
     *      categories (optional),
     *      poster (optional),
     *      description (optional)
     * ]
     *
     * @return void
     */
    public static function insert(): void
    {
        self::execute(function () {
            $payload = static::getRequestPayload();

            $comic = Validator::payload(
                $payload,
                "comic"
            );

            Validator::required($comic, ["title"]);
            Validator::string($comic, ["title"]);

            $creatorId = AuthMiddleware::getUserId();

            $description = Validator::nullableString(
                $comic,
                "description"
            );

            $poster = null;

            if (
                isset($_FILES["poster"]) &&
                $_FILES["poster"]["error"] !== UPLOAD_ERR_NO_FILE
            ) {
                $poster = UploadService::saveComicPoster(
                    Validator::image($_FILES, "poster")
                );
            }

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

            $comicId = Database::getConnection()->insert_id;

            if (
                isset($comic["categories"]) &&
                is_array($comic["categories"])
            ) {
                $statement = Database::prepare("
                    INSERT INTO category_comic
                    (
                        comic_id,
                        category_id
                    )
                    VALUES (?, ?)
                ");

                foreach ($comic["categories"] as $categoryId) {
                    $statement->bind_param(
                        "ii",
                        $comicId,
                        $categoryId
                    );

                    Database::execute($statement);
                }
            }

            Response::success([
                "comic" => [
                    "id" => $comicId,
                    "creator_id" => $creatorId,
                    "title" => $comic["title"],
                    "poster" => IMAGE_FOLDER . $poster,
                    "description" => $description,
                    "categories" => $comic["categories"] ?? []
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
     *      categories (optional),
     *      poster (optional),
     *      description (optional)
     * ]
     *
     * @return void
     */
    public static function update(): void
    {
        self::execute(function () {
            $payload = static::getRequestPayload();

            $comic = Validator::payload(
                $payload,
                "comic"
            );

            Validator::required($comic, ["id", "title"]);
            Validator::integer($comic, ["id"]);
            Validator::positive($comic, ["id"]);
            Validator::string($comic, ["title"]);

            $creatorId = AuthMiddleware::getUserId();

            $statement = Database::prepare("
                SELECT poster
                FROM comics
                WHERE
                    id = ?
                    AND creator_id = ?
            ");

            $statement->bind_param(
                "ii",
                $comic["id"],
                $creatorId
            );

            Database::execute($statement);

            $currentComic = Database::first($statement);

            if (!$currentComic) {
                Response::error([
                    "Comic not found or permission denied."
                ], 403);
            }

            $poster = $currentComic["poster"];

            if (
                isset($_FILES["poster"]) &&
                $_FILES["poster"]["error"] !== UPLOAD_ERR_NO_FILE
            ) {
                $newPoster = UploadService::saveComicPoster(
                    Validator::image($_FILES, "poster")
                );

                UploadService::delete($poster);

                $poster = $newPoster;
            }

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

            if (isset($comic["categories"])) {
                if (!is_array($comic["categories"])) {
                    Response::error([
                        "categories must be an array."
                    ]);
                }

                $statement = Database::prepare("
                    DELETE
                    FROM category_comic
                    WHERE comic_id = ?
                ");

                $statement->bind_param(
                    "i",
                    $comic["id"]
                );

                Database::execute($statement);

                $categories = array_unique($comic["categories"]);

                if (!empty($categories)) {
                    $statement = Database::prepare("
                        INSERT INTO category_comic
                        (
                            comic_id,
                            category_id
                        )
                        VALUES (?, ?)
                    ");

                    foreach ($categories as $categoryId) {
                        $statement->bind_param(
                            "ii",
                            $comic["id"],
                            $categoryId
                        );

                        Database::execute($statement);
                    }
                }
            }

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
            $payload = static::getRequestPayload();

            Validator::required($payload, ["id"]);
            Validator::integer($payload, ["id"]);
            Validator::positive($payload, ["id"]);

            $creatorId = AuthMiddleware::getUserId();

            $statement = Database::prepare("
                SELECT poster
                FROM comics
                WHERE
                    id = ?
                    AND creator_id = ?
            ");

            $statement->bind_param(
                "ii",
                $payload["id"],
                $creatorId
            );

            Database::execute($statement);

            $comic = Database::first($statement);

            if (!$comic) {
                Response::error([
                    "Comic not found or permission denied."
                ], 403);
            }

            $poster = $comic["poster"];

            $statement = Database::prepare("
                DELETE
                FROM comics
                WHERE id = ?
            ");

            $statement->bind_param(
                "i",
                $payload["id"]
            );

            Database::execute($statement);

            $deleted = Database::isRowAffected($statement);

            if ($deleted) {
                UploadService::delete($poster);
            }

            Response::success([
                "deleted" => $deleted
            ]);
        });
    }

    public static function addView(): void
    {
        self::execute(function () {

            $payload = static::getRequestPayload();
            Validator::required($payload, ["id"]);
            Validator::integer($payload, ["id"]);

            $statement = Database::prepare("
                UPDATE comics
                SET views = views + 1
                WHERE id = ?
            ");

            $statement->bind_param(
                "i",
                $payload["id"]
            );

            Database::execute($statement);

            Response::success([
                "updated" => true
            ]);
        });
    }
}