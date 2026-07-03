<?php

namespace App\Controllers;

use App\Database\Database;
use App\Middleware\AuthMiddleware;
use App\Response;
use App\Validator;
use Exception;

class RatingController
{
    /**
     * Insert a rating.
     *
     * Payload:
     * rating[
     *      comic_id,
     *      rating
     * ]
     *
     * @return void
     */
    public static function insert(): void
    {
        try {
            $rating = Validator::payload(
                $_POST,
                "rating"
            );

            Validator::required($rating, ["comic_id", "rating"]);
            Validator::integer($rating, ["comic_id", "rating"]);
            Validator::positive($rating, ["comic_id"]);
            Validator::between($rating, "rating", 1, 5);

            $userId = AuthMiddleware::getUser()["sub"];

            $statement = Database::prepare("
                INSERT INTO comic_rated_by_user
                (
                    comic_id,
                    user_id,
                    rating
                )
                VALUES (?, ?, ?)
            ");

            $statement->bind_param(
                "iii",
                $rating["comic_id"],
                $userId,
                $rating["rating"]
            );

            Database::execute($statement);

            Response::success([
                "comic_id" => $rating["comic_id"],
                "user_id" => $userId,
                "rating" => $rating["rating"]
            ], 201);

        } catch (Exception $e) {
            Response::error([
                $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update a rating.
     *
     * Payload:
     * rating[
     *      comic_id,
     *      rating
     * ]
     *
     * @return void
     */
    public static function update(): void
    {
        try {
            $rating = Validator::payload(
                $_POST,
                "rating"
            );

            Validator::required($rating, ["comic_id", "rating"]);
            Validator::integer($rating, ["comic_id", "rating"]);
            Validator::positive($rating, ["comic_id"]);
            Validator::between($rating, "rating", 1, 5);

            $userId = AuthMiddleware::getUser()["sub"];

            $statement = Database::prepare("
                UPDATE comic_rated_by_user
                SET
                    rating = ?
                WHERE
                    comic_id = ?
                    AND user_id = ?
            ");

            $statement->bind_param(
                "iii",
                $rating["rating"],
                $rating["comic_id"],
                $userId
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
     * Delete a rating.
     *
     * Payload:
     * - comic_id
     *
     * @return void
     */
    public static function delete(): void
    {
        try {
            Validator::required($_POST, ["comic_id"]);
            Validator::integer($_POST, ["comic_id"]);
            Validator::positive($_POST, ["comic_id"]);

            $userId = AuthMiddleware::getUser()["sub"];

            $statement = Database::prepare("
                DELETE FROM comic_rated_by_user
                WHERE
                    comic_id = ?
                    AND user_id = ?
            ");

            $statement->bind_param(
                "ii",
                $_POST["comic_id"],
                $userId
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