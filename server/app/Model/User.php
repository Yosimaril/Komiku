<?php

namespace model;


use app\Database\Database;

class User extends Database
{
    public $user_id;
    public $user_name;
    public $user_password;

    public function __construct()
    {
        parent::__construct();
    }

    public function get($keyword = null)
    {
        $query = "SELECT user_id, user_name FROM master_user";

        if (!empty($keyword)) {
            $query .= " WHERE user_name LIKE ?";
        }

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

    public function register()
    {
        if (!$this->validate()) {
            return false;
        }

        $hashedPassword = password_hash($this->user_password, PASSWORD_DEFAULT);

        $statement = $this->mysqli->prepare("
            INSERT INTO master_user (user_name, user_password)
            VALUES (?, ?)
        ");

        $statement->bind_param(
            "ss",
            $this->user_name,
            $hashedPassword
        );

        $statement->execute();

        if ($statement->affected_rows == 0) {
            return false;
        }

        return $this->login();
    }

    public function login()
    {
        $statement = $this->mysqli->prepare("
            SELECT *
            FROM master_user
            WHERE user_id = ?
            LIMIT 1
        ");

        $statement->bind_param("s", $this->user_id);
        $statement->execute();

        $result = $statement->get_result();

        if ($result->num_rows === 0) {
            $this->error_message[] = "User tidak ada!";
            return false;
        }

        $user = $result->fetch_assoc();

        // if (!password_verify($this->user_password, $user['user_password'])) {
        if ($this->user_password != $user['user_password']) {
            $this->error_message[] = "Password salah!";
            return false;
        }

        $this->user_name = $user['user_name'];

        return [
            "user_id" => $user['user_id'],
            "user_name" => $user['user_name']
        ];
    }

    public function delete()
    {
        $statement = $this->mysqli->prepare("
            DELETE FROM master_user
            WHERE user_name = ?
        ");

        $statement->bind_param("s", $this->user_name);
        $statement->execute();

        return $statement->affected_rows > 0;
    }

    public function checkUsernameExist()
    {
        $statement = $this->mysqli->prepare("
            SELECT user_name
            FROM master_user
            WHERE user_name = ?
            LIMIT 1
        ");

        $statement->bind_param("s", $this->user_name);
        $statement->execute();

        $result = $statement->get_result();

        return $result->num_rows > 0;
    }

    private function validate()
    {
        $noError = true;

        if (empty($this->user_name)) {
            $this->error_message[] = "Username wajib diisi!";
            $noError = false;
        }

        if ($this->checkUsernameExist()) {
            $this->error_message[] = "Username sudah terdaftar!";
            $noError = false;
        }

        if (preg_match('/[0-9]/', $this->user_name)) {
            $this->error_message[] = "Username tidak boleh mengandung angka!";
            $noError = false;
        }

        if (empty($this->user_password)) {
            $this->error_message[] = "Password wajib diisi!";
            $noError = false;
        }

        if (strlen($this->user_password) < 8) {
            $this->error_message[] = "Password minimal 8 karakter!";
            $noError = false;
        }

        return $noError;
    }
}
