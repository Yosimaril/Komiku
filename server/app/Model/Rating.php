<?php

namespace model;


use app\Database\Database;

class MovieGenre extends Database
{
    public $genre_id;
    public $genre_name;

    public function __construct()
    {
        parent::__construct();
    }

    public function get($keyword = null)
    {
        $query = "SELECT * FROM genre";

        if (!empty($keyword))
            $query .= " WHERE genre_name LIKE ?";

        $statement = $this->mysqli->prepare($query);

        if (!empty($keyword)) {
            $like = "%$keyword%";
            $statement->bind_param("s", $like);
        }

        $statement->execute();
        $result = $statement->get_result();

        $rows = [];
        while ($row = $result->fetch_assoc()) {
            $rows[] = $row;
        }

        return $rows;
    }

    public function insert()
    {
        $statement = $this->mysqli->prepare("
            INSERT INTO genre (genre_name)
            VALUES (?)
        ");

        $statement->bind_param("s", $this->genre_name);
        $statement->execute();

        if ($statement->affected_rows > 0) {
            $this->movie_id = $this->mysqli->insert_id;
            return true;
        }

        return false;
    }

    public function delete()
    {
        $statement = $this->mysqli->prepare("
            DELETE FROM genre
            WHERE genre_id = ?
        ");

        if (!$statement) {
            $this->error_message = $this->mysqli->error;
            return false;
        }

        $statement->bind_param("i", $this->genre_id);

        if (!$statement->execute()) {
            $this->error_message = $statement->error;
            return false;
        }

        if ($statement->affected_rows <= 0) {
            $this->error_message = "No rows deleted (possibly FK constraint or invalid ID)";
            return false;
        }

        return true;
    }


    public function update()
    {
        $statement = $this->mysqli->prepare("
            UPDATE genre
            SET genre_name = ?
            WHERE genre_id = ?
        ");

        if (!$statement) {
            $this->error_message = $this->mysqli->error;
            return false;
        }

        $statement->bind_param(
            "ss",
            $this->genre_name,
            $this->genre_id
        );

        if (!$statement->execute()) {
            $this->error_message = $statement->error;
            return false;
        }
        return true;
    }

    public function updateMovieGenres($movie_id, $genre_ids)
    {
        // Delete old genres
        $stmt = $this->mysqli->prepare("
            DELETE FROM movie_genres WHERE movie_id = ?
        ");

        if (!$stmt) {
            $this->error_message = $this->mysqli->error;
            return false;
        }

        $stmt->bind_param("i", $movie_id);

        if (!$stmt->execute()) {
            $this->error_message = $stmt->error;
            return false;
        }

        // Replace with new genres
        if (!empty($genre_ids)) {
            foreach ($genre_ids as $genre_id) {

                $stmt2 = $this->mysqli->prepare("
                    INSERT INTO movie_genres (movie_id, genre_id)
                    VALUES (?, ?)
                ");

                if (!$stmt2) {
                    $this->error_message = $this->mysqli->error;
                    return false;
                }

                $stmt2->bind_param("ii", $movie_id, $genre_id);

                if (!$stmt2->execute()) {
                    $this->error_message = $stmt2->error;
                    return false;
                }
            }
        }

        return true;
    }
}