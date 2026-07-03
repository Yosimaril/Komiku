<?php

namespace App\Controllers;

use App\Database\Database;
use App\Response;
use App\Validator;
use Exception;

class UserController
{
    /**
     * Login.
     *
     * Payload:
     * - username
     * - password
     *
     * @return void
     */
    public static function login(): void
    {
        try {
            Validator::required($_POST, ['username', 'password']);

            $statement = Database::prepare("
                SELECT
                    id,
                    username,
                    password,
                    created_at,
                    updated_at
                FROM users
                WHERE username = ?
                LIMIT 1
            ");

            $statement->bind_param(
                "s",
                $_POST['username']
            );

            Database::execute($statement);

            $user = $statement
                ->get_result()
                ->fetch_assoc();

            if (
                !$user ||
                !password_verify(
                    $_POST['password'],
                    $user['password']
                )
            ) {
                Response::error([
                    "Invalid username or password."
                ], 401);
            }

            unset($user['password']);

            Response::success($user);

        } catch (Exception $e) {
            Response::error([
                $e->getMessage()
            ], 500);
        }
    }

    /**
     * Register.
     *
     * Payload:
     * - username
     * - password (unhashed)
     *
     * @return void
     */
    public static function register(): void
    {
        try {
            Validator::required($_POST, ['username', 'password']);

            $statement = Database::prepare("
                SELECT id
                FROM users
                WHERE username = ?
            ");

            $statement->bind_param(
                "s",
                $_POST['username']
            );

            Database::execute($statement);

            if ($statement->get_result()->num_rows > 0) {
                Response::error([
                    "Username already exists."
                ], 409);
            }

            $password = password_hash(
                $_POST['password'],
                PASSWORD_DEFAULT
            );

            $statement = Database::prepare("
                INSERT INTO users
                (
                    username,
                    password
                )
                VALUES (?, ?)
            ");

            $statement->bind_param(
                "ss",
                $_POST['username'],
                $password
            );

            Database::execute($statement);
            Response::success([
                "id" => Database::getConnection()->insert_id,
                "username" => $_POST['username']
            ], 201);

        } catch (Exception $e) {
            Response::error([
                $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update user.
     *
     * Payload:
     * user[
     *      id,
     *      username,
     *      password
     * ]
     *
     * @return void
     */
    public static function update(): void
    {
        try {
            $user = Validator::payload(
                $_POST,
                "user"
            );

            Validator::required($user, ["id", "username", "password"]);
            Validator::integer($user, ["id"]);
            Validator::positive($user, ["id"]);

            $statement = Database::prepare("
                SELECT password
                FROM users
                WHERE id = ?
            ");

            $statement->bind_param(
                "i",
                $user["id"]
            );

            Database::execute($statement);

            $databaseUser = $statement
                ->get_result()
                ->fetch_assoc();

            if (
                !$databaseUser ||
                !password_verify(
                    $user["password"],
                    $databaseUser["password"]
                )
            ) {
                Response::error([
                    "Invalid password."
                ], 401);
            }

            $statement = Database::prepare("
                UPDATE users
                SET
                    username = ?
                WHERE id = ?
            ");

            $statement->bind_param(
                "si",
                $user["username"],
                $user["id"]
            );

            Database::execute($statement);
            Response::success([
                "updated" =>
                    $statement->affected_rows > 0
            ]);

        } catch (Exception $e) {
            Response::error([
                $e->getMessage()
            ], 500);
        }
    }

    /**
     * Delete user.
     *
     * Payload:
     * - id
     * - password (unhashed)
     *
     * @return void
     */
    public static function delete(): void
    {
        try {
            Validator::required($_POST, ["id", "password"]);
            Validator::integer($_POST, ["id"]);
            Validator::positive($_POST, ["id"]);

            $statement = Database::prepare("
                SELECT password
                FROM users
                WHERE id = ?
            ");

            $statement->bind_param(
                "i",
                $_POST["id"]
            );

            Database::execute($statement);

            $user = $statement
                ->get_result()
                ->fetch_assoc();

            if (
                !$user ||
                !password_verify(
                    $_POST["password"],
                    $user["password"]
                )
            ) {
                Response::error([
                    "Invalid password."
                ], 401);
            }

            $statement = Database::prepare("
                DELETE FROM users
                WHERE id = ?
            ");

            $statement->bind_param(
                "i",
                $_POST["id"]
            );

            Database::execute($statement);
            Response::success([
                "deleted" =>
                    $statement->affected_rows > 0
            ]);

        } catch (Exception $e) {
            Response::error([
                $e->getMessage()
            ], 500);
        }
    }
}