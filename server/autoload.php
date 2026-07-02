<?php
spl_autoload_register(function ($class) {
    if (!str_starts_with($class, 'App\\')) {
        return;
    }

    $class = substr($class, 4);

    $path = __DIR__
        . "/app/"
        . str_replace("\\", "/", $class)
        . ".php";

    if (file_exists($path)) {
        require_once $path;
    }
});