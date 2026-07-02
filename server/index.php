<?php

require_once "env.php";
require_once "autoload.php";

use App\Middleware\RequestMiddleware;
use App\Router;


$action = RequestMiddleware::getAction();
Router::dispatch($action);



//// For debugging purpose
//echo "<pre>";
//print_r(scandir(__DIR__));
//echo "</pre>";
