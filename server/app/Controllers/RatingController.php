<?php

namespace App\Controllers;

use App\Database\Database;
use App\Response;
use App\Validator;
use Exception;

class RatingController
{
    /**
     * Create a new rating.
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
            $db = Database::getConnection();

            $rating = Validator::payload(
                $_POST,
                'rating'
            );

            Validator::required($rating, ['comic_id', 'rating']);
            Validator::integer($rating, ['comic_id', 'rating']);
            Validator::positive($rating, ['comic_id', 'rating']);
            Validator::between($rating, 'rating', 1, 5);

            $statement = $db->prepare("
                INSERT INTO comic_rated_by_user
                (
                    comic_id,
                    
                    rating
                )
                VALUES (?, ?)
            ");

            $statement->bind_param(
                "ss",
                $category['name'],
                $description
            );

            $statement->execute();
            Response::success([
                'category' => [
                    'id' => $db->insert_id,
                    'name' => $category['name'],
                    'description' => $description
                ]
            ], 201);

        } catch (Exception $e) {
            Response::error([
                $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update an existing rating.
     *
     * Payload:
     * rating[
     *      id,
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
                'rating'
            );

            Validator::required($rating, ['id', 'comic_id', 'rating']);
            Validator::integer($rating, ['id', 'comic_id', 'rating']);
            Validator::positive($rating, ['id', 'comic_id', 'rating']);
            Validator::between($rating, 'rating', 1, 5);

            $statement = Database::prepare("
                UPDATE comic_rated_by_user
                SET
                    comic_id = ?,
                    rating = ?
                WHERE id = ?
            ");

            $statement->bind_param(
                "iii",
                $rating['comic_id'],
                $rating['rating'],
                $rating['id']
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
     * Delete a rating.
     *
     * Required payload:
     * - comic_id
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
                DELETE FROM comic_rated_by_user
                WHERE comic_id = ?
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