<?php

if (basename($_SERVER['PHP_SELF']) === basename(__FILE__)) {
    header("Location: .");
    exit();
}

date_default_timezone_set('Asia/Jakarta');

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit();
}

const DB_HOST = "127.0.0.1";
const DB_DATABASE = "komiku";
const DB_USERNAME = "root";
const DB_PASSWORD = "";
const JWT_SECRET = "1234567890";