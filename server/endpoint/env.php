<?php

define("APP_NAME", getenv("APP_NAME") ?: "Komiku");
define("BASE_URL", getenv("BASE_URL") ?: ".");
define("DB_HOST", getenv("DB_HOST") ?: "mysql");
define("DB_DATABASE", getenv("DB_DATABASE") ?: "komiku");
define("DB_USERNAME", getenv("DB_USERNAME") ?: "komiku");
define("DB_PASSWORD", getenv("DB_PASSWORD") ?: "password");
define("JWT_SECRET", getenv("JWT_SECRET") ?: "1234567890");
define("DISPLAY_ERRORS", getenv("DISPLAY_ERRORS") ?: false);
define("LOG_ERRORS", getenv("LOG_ERRORS") ?: true);

const IMAGE_FOLDER = BASE_URL . "app/Storage/";

if (basename($_SERVER['PHP_SELF']) === basename(__FILE__)) {
    header("Location: .");
    exit();
}

date_default_timezone_set('Asia/Jakarta');

// header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");

ini_set('display_errors', DISPLAY_ERRORS);
ini_set('log_errors', LOG_ERRORS);

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit();
}