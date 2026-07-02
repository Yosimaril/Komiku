<?php

namespace App\Services;

use App\Database\Database;
use App\Models\Comic;

class ComicService
{
    private Comic $comic;

    public function __construct()
    {
        $this->comic = new Comic(
            Database::getConnection()
        );
    }

    public function get(?string $keyword): array
    {
        return $this->comic->get($keyword);
    }

    public function getDetail(int $id): ?array
    {
        return $this->comic->getDetail($id);
    }

    public function create(array $data): int
    {
        return $this->comic->create(
            $data['title'],
            $data['description'],
            $data['poster'],
            (int)$data['author_id']
        );
    }

    public function update(int $id, array $data): bool
    {
        return $this->comic->update(
            $id,
            $data['title'],
            $data['description']
        );
    }

    public function delete(int $id): bool
    {
        return $this->comic->delete($id);
    }
}