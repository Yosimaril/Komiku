<?php

namespace App\Controllers;

use App\Database\Database;
use App\Middleware\AuthMiddleware;
use App\Response;
use App\Service\JwtService;
use App\Validator;

class UserController extends BaseController
{
    /**
     * Login.
     *
     * Payload:
     * user[
     *      username,
     *      password
     * ]
     *
     * @return void
     */
    public static function login(): void
    {
        self::execute(function () {
            $payload = static::getRequestPayload();
            $user = Validator::payload($payload, 'user');

            Validator::required($user, ['username', 'password']);
            Validator::string($user, ['username', 'password']);

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
                $user['username']
            );

            Database::execute($statement);

            $databaseUser = Database::first($statement);

            if (
                !$databaseUser ||
                !password_verify(
                    $user['password'],
                    $databaseUser['password']
                )
            ) {
                Response::error([
                    "Invalid username or password."
                ], 401);
            }

            unset($databaseUser['password']);

            $token = JwtService::generate(
                $databaseUser['id'],
            );

            Response::success([
                "user" => $databaseUser,
                "token" => $token
            ]);
        });
    }

    /**
     * Register.
     *
     * Payload:
     * user[
     * *      username,
     * *      password
     * * ]
     * *
     * @return void
     */
    public static function register(): void
    {
        self::execute(function () {
            $payload = static::getRequestPayload();
            $user = Validator::payload($payload, 'user');

            Validator::required($user, ['username', 'password']);
            Validator::string($user, ['username', 'password']);

            $statement = Database::prepare("
                SELECT id
                FROM users
                WHERE username = ?
            ");

            $statement->bind_param(
                "s",
                $user['username']
            );

            Database::execute($statement);

            if (Database::first($statement)) {
                Response::error([
                    "Username already exists."
                ], 409);
            }

            $password = password_hash(
                $user['password'],
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
                $user['username'],
                $password
            );

            Database::execute($statement);

            $id = Database::getConnection()->insert_id;

            $token = JwtService::generate(
                $id,
            );

            Response::success([
                "user" => [
                    "id" => $id,
                    "username" => $user['username']
                ],
                "token" => $token
            ], 201);
        });
    }

    /**
     * Update user.
     *
     * Payload:
     * user[
     *      username,
     *      password
     * ]
     *
     * @return void
     */
    public static function update(): void
    {
        self::execute(function () {
            $payload = static::getRequestPayload();
            $user = Validator::payload($payload, "user");

            Validator::required($user, ["username", "password"]);
            Validator::string($user, ["username", "password"]);

            $id = AuthMiddleware::getUserId();

            $statement = Database::prepare("
                SELECT password
                FROM users
                WHERE id = ?
            ");

            $statement->bind_param(
                "i",
                $id
            );

            Database::execute($statement);

            $databaseUser = Database::first($statement);

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
                $id
            );

            Database::execute($statement);

            Response::success([
                "updated" => Database::isRowAffected($statement)
            ]);
        });
    }

    /**
     * Delete user.
     *
     * Payload:
     * user[
     *      password
     * ]
     * @return void
     */
    public static function delete(): void
    {
        self::execute(function () {
            $payload = static::getRequestPayload();
            $user = Validator::payload($payload, "user");

            Validator::required($user, ["password"]);
            Validator::string($user, ["password"]);

            $id = AuthMiddleware::getUserId();

            $statement = Database::prepare("
                SELECT password
                FROM users
                WHERE id = ?
            ");

            $statement->bind_param(
                "i",
                $id
            );

            Database::execute($statement);

            $databaseUser = Database::first($statement);

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
                DELETE FROM users
                WHERE id = ?
            ");

            $statement->bind_param(
                "i",
                $id
            );

            Database::execute($statement);

            Response::success([
                "deleted" => Database::isRowAffected($statement)
            ]);
        });
    }
}