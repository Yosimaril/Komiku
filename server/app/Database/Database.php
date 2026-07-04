<?php

namespace App\Database;

use App\Response;
use Exception;
use mysqli;
use mysqli_stmt;

class Database
{
    private static ?mysqli $connection = null;

    /**
     * Get the database connection.
     *
     * @throws Exception
     */
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
                throw new Exception(self::$connection->connect_error);
            }

            self::$connection->set_charset("utf8mb4");
        }

        return self::$connection;
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

    /**
     * Execute database operations inside a transaction.
     *
     * Automatically commits on success and rolls back
     * if an exception occurs.
     *
     * @param callable $callback
     *
     * @throws Exception
     */
    public static function transaction(
        callable $callback
    ): mixed
    {
        $db = self::getConnection();
        $db->begin_transaction();

        try {
            $result = $callback();

            $db->commit();

            return $result;
        } catch (Exception $e) {
            $db->rollback();
            throw $e;
        }
    }

    /**
     * Get the first row from a prepared statement.
     *
     * @param mysqli_stmt $statement
     *
     * @return array|null'
     */
    public static function first(mysqli_stmt $statement): ?array
    {
        return $statement
            ->get_result()
            ->fetch_assoc() ?: null;
    }

    /**
     * Get all rows from a prepared statement.
     *
     * @param mysqli_stmt $statement
     *
     * @return array
     */
    public static function all(mysqli_stmt $statement): array
    {
        return $statement
            ->get_result()
            ->fetch_all(MYSQLI_ASSOC);
    }

    /**
     * Check if a prepared statement affected any rows.
     *
     * @param mysqli_stmt $statement
     *
     * @return bool
     */
    public static function isRowAffected(mysqli_stmt $statement): bool
    {
        return $statement->affected_rows > 0;
    }
}