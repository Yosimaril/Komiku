<?php

namespace App\Controllers;

use App\Database\Database;
use App\Middleware\AuthMiddleware;
use App\Response;
use App\Validator;
use Exception;

class CommentController extends BaseController
{
    /**
     * Retrieve all comments of a comic.
     *
     * Payload:
     * - comic_id
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

            $statement = Database::prepare("
                SELECT
                    c.id,
                    c.content,
                    c.created_at,
                    c.updated_at,
                    u.id AS user_id,
                    u.username
                FROM comments c
                LEFT JOIN users u
                    ON u.id = c.user_id
                WHERE
                    c.comic_id = ?
                    AND c.parent_comment_id IS NULL
                ORDER BY c.created_at DESC
            ");

            $statement->bind_param(
                "i",
                $comicId
            );

            Database::execute($statement);

            Response::success(
                Database::all($statement)
            );
        });
    }

    /**
     * Insert a new comment.
     *
     * Payload:
     * comment[
     *      comic_id,
     *      content
     * ]
     *
     * @return void
     */
    public static function insert(): void
    {
        self::execute(function () {
            $comment = Validator::payload(
                $_POST,
                "comment"
            );

            Validator::required($comment, ["comic_id", "content"]);
            Validator::integer($comment, ["comic_id"]);
            Validator::positive($comment, ["comic_id"]);
            Validator::string($comment, ["content"]);

            $userId = AuthMiddleware::getUserId();

            $statement = Database::prepare("
                INSERT INTO comments
                (
                    comic_id,
                    user_id,
                    content
                )
                VALUES (?, ?, ?)
            ");

            $statement->bind_param(
                "iis",
                $comment["comic_id"],
                $userId,
                $comment["content"]
            );

            Database::execute($statement);

            Response::success([
                "comment" => [
                    "id" => Database::getConnection()->insert_id,
                    "comic_id" => $comment["comic_id"],
                    "user_id" => $userId,
                    "content" => $comment["content"]
                ]
            ], 201);
        });
    }

    /**
     * Update a comment.
     *
     * Payload:
     * comment[
     *      id,
     *      content
     * ]
     *
     * @return void
     */
    public static function update(): void
    {
        self::execute(function () {
            $comment = Validator::payload(
                $_POST,
                "comment"
            );

            Validator::required($comment, ["id", "content"]);
            Validator::integer($comment, ["id"]);
            Validator::positive($comment, ["id"]);
            Validator::string($comment, ["content"]);

            $userId = AuthMiddleware::getUserId();

            $statement = Database::prepare("
                SELECT id
                FROM comments
                WHERE
                    id = ?
                    AND user_id = ?
                    AND parent_comment_id IS NULL
            ");

            $statement->bind_param(
                "ii",
                $comment["id"],
                $userId
            );

            Database::execute($statement);

            if ($statement->get_result()->num_rows === 0) {
                Response::error([
                    "Comment not found or permission denied."
                ], 403);
            }

            $statement = Database::prepare("
                UPDATE comments
                SET
                    content = ?
                WHERE id = ?
            ");

            $statement->bind_param(
                "si",
                $comment["content"],
                $comment["id"]
            );

            Database::execute($statement);

            Response::success([
                "updated" => Database::isRowAffected($statement)
            ]);
        });
    }

    /**
     * Delete a comment.
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

            $userId = AuthMiddleware::getUserId();

            $statement = Database::prepare("
                SELECT id
                FROM comments
                WHERE
                    id = ?
                    AND user_id = ?
                    AND parent_comment_id IS NULL
            ");

            $statement->bind_param(
                "ii",
                $_POST["id"],
                $userId
            );

            Database::execute($statement);

            if ($statement->get_result()->num_rows === 0) {
                Response::error([
                    "Comment not found or permission denied."
                ], 403);
            }

            $statement = Database::prepare("
                DELETE FROM comments
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