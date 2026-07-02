<?php

namespace model;

use app\Database\Database;

class Category extends Database
{
    public $id;
    public $name;
    public $slug;
    public $error_message;

    public function __construct()
    {
        parent::__construct();
    }

    public function get($keyword = null)
    {
        $query = "SELECT * FROM categories";

        if (!empty($keyword))
            $query .= " WHERE name LIKE ?";

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

        return array_values($rows);
    }

//    public function insert()
//    {
//        if (!$this->validate())
//            return false;
//
//        if (!$this->generateSlug())
//            return false;
//
//        $statement = $this->mysqli->prepare("
//            INSERT INTO categories (name, slug)
//            VALUES (?, ?)
//        ");
//        $statement->bind_param("ss", $this->name, $this->slug);
//        $statement->execute();
//
//        return $statement->affected_rows > 0;
//    }
//
//    public function update()
//    {
//        if (!$this->validate())
//            return false;
//
//        $statement = $this->mysqli->prepare("
//            UPDATE categories
//            SET name = ?, slug = ?
//            WHERE id = ?
//        ");
//        $statement->bind_param("ssi", $this->name, $this->slug, $this->id);
//
//        return $statement->execute();;
//    }
//
//    public function delete()
//    {
//        $statement = $this->mysqli->prepare("
//            DELETE FROM categories
//            WHERE id = ?
//        ");
//        $statement->bind_param("i", $this->id);
//        $statement->execute();
//
//        return $statement->affected_rows > 0;
//    }
//
//    public function checkCategoryExist()
//    {
//        $statement = $this->mysqli->prepare("
//            SELECT 1
//            FROM categories
//            WHERE name = ?
//            LIMIT 1
//        ");
//        $statement->bind_param("s", $this->name);
//        $statement->execute();
//
//        $result = $statement->get_result();
//
//        return $result->num_rows > 0;
//    }
//
//    private function generateSlug()
//    {
//        $name = $this->name;
//
//        $slug = preg_replace('/[^a-z0-9]+/i', '-', $name);
//        $slug = trim($slug, '-');
//        $slug = strtolower($slug);
//
//        $statement = $this->mysqli->prepare("
//            SELECT 1
//            FROM categories
//            WHERE slug = ?
//            LIMIT 1
//        ");
//        $statement->bind_param("s", $slug);
//        $statement->execute();
//
//        $result = $statement->get_result();
//
//        if ($result->num_rows > 0) {
//            $this->error_message[] = "Judul kategori akan menghasilkan slug yang sama dengan kategori lain!";
//            return false;
//        }
//
//        $this->slug = $slug;
//        return true;
//    }
//
//    private function validate()
//    {
//        $noError = true;
//
//        if (empty($this->name)) {
//            $this->error_message[] = "Nama kategori wajib diisi!";
//            $noError = false;
//        }
//
//        if ($this->checkCategoryExist()) {
//            $this->error_message[] = "Kategori sudah terdaftar!";
//            $noError = false;
//        }
//
//        return $noError;
//    }
}