<?php

namespace App\Controllers;

use App\Database\Database;
use App\Response;
use App\Validator;
use Exception;

class ChapterPageController
{
    /**
     * Retrieve all comments for a particular comic.
     *
     * Payload:
     * - comic_id
     *
     * @return void
     */
    public static function get(): void
    {
        try {
            Validator::required($_POST, ["comic_id"]);
            Validator::integer($_POST, ["comic_id"]);
            Validator::positive($_POST, ["comic_id"]);

            $comic_id = $_POST['comic_id'];

            $statement = Database::prepare("
                SELECT c.*, u.username
                FROM comments c
                JOIN users u
                    ON u.id = c.user_id
                WHERE c.comic_id = ?
                ORDER BY c.created_at
            ");

            $statement->bind_param(
                "i",
                $comic_id
            );

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
     * Create a new comment.
     *
     * Payload:
     * comment[
     *      comic_id,
     *      user_id,
     *      content
     * ]
     *
     * @return void
     */
    public static function insert(): void
    {
        try {
            $db = Database::getConnection();

            $comment = Validator::payload(
                $_POST,
                'comment'
            );

            Validator::required($comment, ['user_id', 'comic_id', 'content']);
            Validator::integer($comment, ['user_id', 'comic_id']);
            Validator::positive($comment, ['user_id', 'comic_id']);
            Validator::string($comment, ['content']);

            $statement = $db->prepare("
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
                $comment['comic_id'],
                $comment['user_id'],
                $comment['content']
            );

            $statement->execute();
            Response::success([
                'comment' => [
                    'id' => $db->insert_id,
                    'comic_id' => $comment['comic_id'],
                    'user_id' => $comment['user_id'],
                    'content' => $comment['content']
                ]
            ], 201);

        } catch (Exception $e) {
            Response::error([
                $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update an existing comment.
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
        try {
            $comment = Validator::payload(
                $_POST,
                '$comment'
            );

            Validator::required($comment, ['id', 'content']);
            Validator::integer($comment, ['id']);
            Validator::positive($comment, ['id']);
            Validator::string($comment, ['content']);

            $statement = Database::prepare("
                UPDATE comments
                SET
                    content = ?
                WHERE id = ?
            ");

            $statement->bind_param(
                "si",
                $comment['content'],
                $comment['id']
            );

            Database::execute($statement);
            Response::success([
                'updated' => $statement->affected_rows > 0
            ]);

        } catch (Exception $e) {
            Response::error([
                $e->getMessage()
            ], 500);
        }
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
        try {
            Validator::required($_POST, ['id']);
            Validator::integer($_POST, ['id']);
            Validator::positive($_POST, ['id']);

            $statement = Database::prepare("
                DELETE FROM comments
                WHERE id = ?
            ");

            $statement->bind_param(
                "i",
                $_POST['id']
            );

            Database::execute($statement);
            Response::success([
                'deleted' => $statement->affected_rows > 0
            ]);

        } catch (Exception $e) {
            Response::error([
                $e->getMessage()
            ], 500);
        }
    }
}