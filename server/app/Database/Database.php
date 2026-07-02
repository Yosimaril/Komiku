<?php

namespace App\Database;

use App\Response;
use Exception;
use mysqli;
use mysqli_stmt;

class Database
{
    private static ?mysqli $connection = null;

    public static function getConnection(): mysqli
    {
        try {
            if (self::$connection === null) {
                self::$connection = new mysqli(
                    DB_HOST,
                    DB_USERNAME,
                    DB_PASSWORD,
                    DB_DATABASE
                );

                if (self::$connection->connect_errno) {
                    throw new Exception(self::$connection->connect_error);
                }

                self::$connection->set_charset("utf8mb4");
            }

            return self::$connection;

        } catch (Exception $e) {
            Response::error([
                $e->getMessage()
            ], 500);
        }
    }

    /**
     * Prepare a SQL statement.
     *
     * @throws Exception
     */
    public static function prepare(string $query): mysqli_stmt
    {
        $statement = self::getConnection()->prepare($query);

        if (!$statement) {
            throw new Exception(self::getConnection()->error);
        }

        return $statement;
    }

    /**
     * Execute a prepared statement.
     *
     * @throws Exception
     */
    public static function execute(mysqli_stmt $statement): void
    {
        if (!$statement->execute()) {
            throw new Exception($statement->error);
        }
    }
}