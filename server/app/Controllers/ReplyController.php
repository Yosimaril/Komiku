<?php

namespace App\Controllers;

use App\Database\Database;
use App\Middleware\AuthMiddleware;
use App\Response;
use App\Validator;
use Exception;

class ReplyController extends BaseController
{
    /**
     * Retrieve all replies of a comment.
     *
     * Payload:
     * - parent_comment_id
     *
     * @return void
     */
    public static function get(): void
    {
        self::execute(function () {
            Validator::required($_POST, ["parent_comment_id"]);
            Validator::integer($_POST, ["parent_comment_id"]);
            Validator::positive($_POST, ["parent_comment_id"]);

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
                    c.parent_comment_id = ?
                ORDER BY c.created_at ASC
            ");

            $statement->bind_param(
                "i",
                $_POST["parent_comment_id"]
            );

            Database::execute($statement);

            Response::success(
                Database::all($statement)
            );
        });
    }

    /**
     * Insert a reply.
     *
     * Payload:
     * reply[
     *      parent_comment_id,
     *      content
     * ]
     *
     * @return void
     */
    public static function insert(): void
    {
        self::execute(function () {
            $reply = Validator::payload(
                $_POST,
                "reply"
            );

            Validator::required($reply, ["parent_comment_id", "content"]);
            Validator::integer($reply, ["parent_comment_id"]);
            Validator::positive($reply, ["parent_comment_id"]);
            Validator::string($reply, ["content"]);

            $userId = AuthMiddleware::getUserId();

            $statement = Database::prepare("
                SELECT comic_id
                FROM comments
                WHERE id = ?
                AND parent_comment_id IS NULL
            ");

            $statement->bind_param(
                "i",
                $reply["parent_comment_id"]
            );

            Database::execute($statement);

            $comment = Database::first($statement);

            if (!$comment) {
                Response::error([
                    "Parent comment not found."
                ], 404);
            }

            $statement = Database::prepare("
                INSERT INTO comments
                (
                    comic_id,
                    user_id,
                    parent_comment_id,
                    content
                )
                VALUES (?, ?, ?, ?)
            ");

            $statement->bind_param(
                "iiis",
                $comment["comic_id"],
                $userId,
                $reply["parent_comment_id"],
                $reply["content"]
            );

            Database::execute($statement);

            Response::success([
                "reply" => [
                    "id" => Database::getConnection()->insert_id,
                    "comic_id" => $comment["comic_id"],
                    "parent_comment_id" => $reply["parent_comment_id"],
                    "user_id" => $userId,
                    "content" => $reply["content"]
                ]
            ], 201);
        });
    }

    /**
     * Update a reply.
     *
     * Payload:
     * reply[
     *      id,
     *      content
     * ]
     *
     * @return void
     */
    public static function update(): void
    {
        self::execute(function () {
            $reply = Validator::payload(
                $_POST,
                "reply"
            );

            Validator::required($reply, ["id", "content"]);
            Validator::integer($reply, ["id"]);
            Validator::positive($reply, ["id"]);
            Validator::string($reply, ["content"]);

            $userId = AuthMiddleware::getUserId();

            $statement = Database::prepare("
                SELECT id
                FROM comments
                WHERE
                    id = ?
                    AND user_id = ?
                    AND parent_comment_id IS NOT NULL
            ");

            $statement->bind_param(
                "ii",
                $reply["id"],
                $userId
            );

            Database::execute($statement);

            if (!Database::first($statement)) {
                Response::error([
                    "Reply not found or permission denied."
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
                $reply["content"],
                $reply["id"]
            );

            Database::execute($statement);

            Response::success([
                "updated" => Database::isRowAffected($statement)
            ]);
        });
    }

    /**
     * Delete a reply.
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
                    AND parent_comment_id IS NOT NULL
            ");

            $statement->bind_param(
                "ii",
                $_POST["id"],
                $userId
            );

            Database::execute($statement);

            if (!Database::first($statement)) {
                Response::error([
                    "Reply not found or permission denied."
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