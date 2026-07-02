<?php

namespace App\Models;

use mysqli;

class Comic
{
    private mysqli $db;

    public function __construct(mysqli $db)
    {
        $this->db = $db;
    }

    public function all(): array
    {
        $stmt = $this->db->prepare("
            SELECT *
            FROM comics
            ORDER BY created_at DESC
        ");

        $stmt->execute();

        return $stmt
            ->get_result()
            ->fetch_all(MYSQLI_ASSOC);
    }

    public function find(int $id): ?array
    {
        $stmt = $this->db->prepare("
            SELECT *
            FROM comics
            WHERE id = ?
        ");

        $stmt->bind_param("i", $id);

        $stmt->execute();

        $result = $stmt->get_result();

        return $result->fetch_assoc() ?: null;
    }

    public function create(
        string $title,
        string $description,
        string $poster,
        int    $authorId
    ): int
    {
        $stmt = $this->db->prepare("
            INSERT INTO comics
            (
                title,
                description,
                poster,
                author_id
            )
            VALUES
            (?,?,?,?)
        ");

        $stmt->bind_param(
            "sssi",
            $title,
            $description,
            $poster,
            $authorId
        );

        $stmt->execute();

        return $this->db->insert_id;
    }

    public function update(
        int    $id,
        string $title,
        string $description
    ): bool
    {
        $stmt = $this->db->prepare("
            UPDATE comics
            SET
                title=?,
                description=?
            WHERE id=?
        ");

        $stmt->bind_param(
            "ssi",
            $title,
            $description,
            $id
        );

        return $stmt->execute();
    }

    public function delete(int $id): bool
    {
        $stmt = $this->db->prepare("
            DELETE FROM comics
            WHERE id=?
        ");

        $stmt->bind_param("i", $id);

        return $stmt->execute();
    }
}