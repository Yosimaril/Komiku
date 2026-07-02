<?php

namespace App\Database;

use mysqli;
use Exception;

class Database
{
    private static ?mysqli $connection = null;

    public static function getConnection(): mysqli
    {
        if (self::$connection === null) {

            self::$connection = new mysqli(
                DB_HOST,
                DB_USERNAME,
                DB_PASSWORD,
                DB_DATABASE
            );

            if (self::$connection->connect_errno) {
                throw new Exception(
                    "Database connection failed : "
                    . self::$connection->connect_error
                );
            }

            self::$connection->set_charset("utf8mb4");
        }

        return self::$connection;
    }
}