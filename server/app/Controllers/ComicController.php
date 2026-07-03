<?php

namespace App\Controllers;

use App\Database\Database;
use App\Middleware\AuthMiddleware;
use App\Response;
use App\Validator;
use Exception;

class ComicController
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
        try {
            $keyword = trim($_POST['keyword'] ?? '');

            $query = "
                SELECT
                    c.id,
                    c.title,
                    c.poster,
                    c.description,
                    u.username AS creator,
                    c.created_at,
                    c.updated_at
                FROM comics c
                JOIN users u
                    ON u.id = c.creator_id
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
            Response::success(
                $statement
                    ->get_result()
                    ->fetch_all(MYSQLI_ASSOC)
            );

        } catch (Exception $e) {
            Response::error([
                $e->getMessage()
            ], 500);
        }
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
        try {
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

            $comic = $statement
                ->get_result()
                ->fetch_assoc();

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

            $rating = $statement
                ->get_result()
                ->fetch_assoc();

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

            $comments = $statement
                ->get_result()
                ->fetch_all(MYSQLI_ASSOC);


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

            $chapters = $statement
                ->get_result()
                ->fetch_all(MYSQLI_ASSOC);

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

                $chapter['chapter_pages'] = $statement
                    ->get_result()
                    ->fetch_all(MYSQLI_ASSOC);
            }

            unset($chapter);

            $result = [
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
            ];
            Response::success($result);

        } catch (Exception $e) {

            Response::error([
                $e->getMessage()
            ], 500);

        }
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
        try {
            $comic = Validator::payload(
                $_POST,
                "comic"
            );

            Validator::required($comic, ["title"]);
            Validator::string($comic, ["title"]);

            $creatorId = AuthMiddleware::getUser()["sub"];

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
                "id" => Database::getConnection()->insert_id,
                "creator_id" => $creatorId,
                "title" => $comic["title"],
                "poster" => $poster,
                "description" => $description
            ], 201);

        } catch (Exception $e) {
            Response::error([
                $e->getMessage()
            ], 500);
        }
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
        try {
            $comic = Validator::payload(
                $_POST,
                "comic"
            );

            Validator::required($comic, ["id", "title"]);
            Validator::integer($comic, ["id"]);
            Validator::positive($comic, ["id"]);
            Validator::string($comic, ["title"]);

            $creatorId = AuthMiddleware::getUser()["sub"];

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

            if ($statement->get_result()->num_rows === 0) {
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
                "updated" => $statement->affected_rows > 0
            ]);

        } catch (Exception $e) {
            Response::error([
                $e->getMessage()
            ], 500);
        }
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
        try {
            Validator::required($_POST, ["id"]);
            Validator::integer($_POST, ["id"]);
            Validator::positive($_POST, ["id"]);

            $creatorId = AuthMiddleware::getUser()["sub"];

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

            if ($statement->get_result()->num_rows === 0) {
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
                "deleted" => $statement->affected_rows > 0
            ]);

        } catch (Exception $e) {
            Response::error([
                $e->getMessage()
            ], 500);
        }
    }
}