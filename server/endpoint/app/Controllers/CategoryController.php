<?php

namespace App\Controllers;

use App\Database\Database;
use App\Response;
use App\Validator;

class CategoryController extends BaseController
{
    /**
     * Retrieve all categories.
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
                SELECT *
                FROM categories
            ";

            if ($keyword !== '') {
                $query .= " WHERE name LIKE ?";
            }

            $query .= " ORDER BY name ASC";

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
                Database::all($statement)
            );
        });
    }

    /**
     * Create a new category.
     *
     * Payload:
     * category[
     *      name,
     *      description (optional)
     * ]
     *
     * @return void
     */
    public static function insert(): void
    {
        self::execute(function () {
            $category = Validator::payload(
                $_POST,
                'category'
            );

            Validator::required($category, ['name']);
            Validator::string($category, ['name']);

            $description = Validator::nullableString(
                $category,
                'description'
            );

            $statement = Database::prepare("
                INSERT INTO categories
                (
                    name,
                    description
                )
                VALUES (?, ?)
            ");

            $statement->bind_param(
                "ss",
                $category['name'],
                $description
            );

            Database::execute($statement);

            Response::success([
                'category' => [
                    'id' => Database::getConnection()->insert_id,
                    'name' => $category['name'],
                    'description' => $description
                ]
            ], 201);
        });
    }

    /**
     * Update an existing category.
     *
     * Payload:
     * category[
     *      id,
     *      name,
     *      description (optional)
     * ]
     *
     * @return void
     */
    public static function update(): void
    {
        self::execute(function () {
            $category = Validator::payload(
                $_POST,
                'category'
            );

            Validator::required($category, ['id', 'name']);
            Validator::integer($category, ['id']);
            Validator::positive($category, ['id']);

            $description = Validator::nullableString(
                $category,
                'description'
            );

            $statement = Database::prepare("
                UPDATE categories
                SET
                    name = ?,
                    description = ?
                WHERE id = ?
            ");

            $statement->bind_param(
                "ssi",
                $category['name'],
                $description,
                $category['id']
            );

            Database::execute($statement);

            Response::success([
                'updated' => Database::isRowAffected($statement)
            ]);
        });
    }

    /**
     * Delete a category.
     *
     * Payload:
     * - id
     *
     * @return void
     */
    public static function delete(): void
    {
        self::execute(function () {
            Validator::required($_POST, ['id']);
            Validator::integer($_POST, ['id']);
            Validator::positive($_POST, ['id']);

            $statement = Database::prepare("
                DELETE FROM categories
                WHERE id = ?
            ");

            $statement->bind_param(
                "i",
                $_POST['id']
            );

            Database::execute($statement);

            Response::success([
                'deleted' => Database::isRowAffected($statement)
            ]);
        });
    }
}