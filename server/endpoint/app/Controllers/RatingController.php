<?php

namespace App\Controllers;

use App\Database\Database;
use App\Middleware\AuthMiddleware;
use App\Response;
use App\Validator;

class RatingController extends BaseController
{
    /**
     * Insert or update a rating.
     *
     * If the user has never rated the comic,
     * a new rating will be inserted.
     *
     * Otherwise, the existing rating
     * will be updated.
     *
     * Payload:
     * rating[
     *      comic_id,
     *      rating
     * ]
     *
     * @return void
     */
    public static function save(): void
    {
        self::execute(function () {
            $payload = static::getRequestPayload();
            $rating = Validator::payload(
                $payload,
                "rating"
            );

            Validator::required($rating, ["comic_id", "rating"]);
            Validator::integer($rating, ["comic_id", "rating"]);
            Validator::positive($rating, ["comic_id"]);
            Validator::between($rating, "rating", 1, 5);

            $userId = AuthMiddleware::getUserId();

            $statement = Database::prepare("
                INSERT INTO comic_rated_by_user
                (
                    comic_id,
                    user_id,
                    rating
                )
                VALUES (?, ?, ?)
                ON DUPLICATE KEY UPDATE
                    rating = VALUES(rating)
            ");

            $statement->bind_param(
                "iii",
                $rating["comic_id"],
                $userId,
                $rating["rating"]
            );

            Database::execute($statement);

            Response::success([
                "rating" => [
                    "comic_id" => $rating["comic_id"],
                    "user_id" => $userId,
                    "rating" => $rating["rating"]
                ]
            ], 201);
        });
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
        self::execute(function () {
            $payload = static::getRequestPayload();
            Validator::required($payload, ["comic_id"]);
            Validator::integer($payload, ["comic_id"]);
            Validator::positive($payload, ["comic_id"]);

            $userId = AuthMiddleware::getUserId();

            $statement = Database::prepare("
                DELETE FROM comic_rated_by_user
                WHERE
                    comic_id = ?
                    AND user_id = ?
            ");

            $statement->bind_param(
                "ii",
                $payload["comic_id"],
                $userId
            );

            Database::execute($statement);

            Response::success([
                "deleted" => Database::isRowAffected($statement)
            ]);
        });
    }
}