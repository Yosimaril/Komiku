<?php
require_once "env.php";
require_once "autoload.php";

use App\Docs\ApiDocumentation;
use App\Enums\Action;
use App\Middleware\RequestMiddleware;
use App\Router;

$action = RequestMiddleware::getAction();
Router::dispatch($action);
?>

<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?= APP_NAME ?></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet"
          integrity="sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB" crossorigin="anonymous">
</head>
<body>
<div id="top" class="bg-dark text-white py-5">
    <div class="container">
        <h1 class="display-4 fw-bold"><?= APP_NAME ?> API</h1>
        <p class="lead">REST API documentation for the <?= APP_NAME ?> Mobile Application.</p>
    </div>
</div>
<div class="container">
    <div class="my-4">
        <div class="d-flex flex-wrap gap-2">
            <?= ApiDocumentation::link("option", "Option"); ?>
            <?= ApiDocumentation::link("user", "User"); ?>
            <?= ApiDocumentation::link("category", "Category"); ?>
            <?= ApiDocumentation::link("comic", "Comic"); ?>
            <?= ApiDocumentation::link("chapter", "Chapter"); ?>
            <?= ApiDocumentation::link("page", "Chapter Page"); ?>
            <?= ApiDocumentation::link("comment", "Comment"); ?>
            <?= ApiDocumentation::link("reply", "Reply"); ?>
            <?= ApiDocumentation::link("rating", "Rating"); ?>
        </div>
    </div>

    <?= ApiDocumentation::section("user", "User"); ?>
    <?= ApiDocumentation::card(Action::LOGIN->value); ?>
    <?= ApiDocumentation::card(Action::REGISTER->value); ?>
    <?= ApiDocumentation::card(Action::UPDATE_USER->value); ?>
    <?= ApiDocumentation::card(Action::DELETE_USER->value); ?>

    <?= ApiDocumentation::section("category", "Category"); ?>
    <?= ApiDocumentation::card(Action::GET_CATEGORIES->value); ?>
    <?= ApiDocumentation::card(Action::INSERT_CATEGORY->value); ?>
    <?= ApiDocumentation::card(Action::UPDATE_CATEGORY->value); ?>
    <?= ApiDocumentation::card(Action::DELETE_CATEGORY->value); ?>

    <?= ApiDocumentation::section("comic", "Comic"); ?>
    <?= ApiDocumentation::card(Action::GET_COMICS->value); ?>
    <?= ApiDocumentation::card(Action::GET_COMIC_DETAIL->value); ?>
    <?= ApiDocumentation::card(Action::INSERT_COMIC->value); ?>
    <?= ApiDocumentation::card(Action::UPDATE_COMIC->value); ?>
    <?= ApiDocumentation::card(Action::DELETE_COMIC->value); ?>

    <?= ApiDocumentation::section("chapter", "Chapter"); ?>
    <?= ApiDocumentation::card(Action::GET_COMIC_CHAPTERS->value); ?>
    <?= ApiDocumentation::card(Action::INSERT_COMIC_CHAPTERS->value); ?>
    <?= ApiDocumentation::card(Action::UPDATE_COMIC_CHAPTER->value); ?>
    <?= ApiDocumentation::card(Action::DELETE_COMIC_CHAPTER->value) ?>

    <?= ApiDocumentation::section("page", "Chapter Page"); ?>
    <?= ApiDocumentation::card(Action::GET_COMIC_CHAPTER_PAGES->value); ?>
    <?= ApiDocumentation::card(Action::INSERT_COMIC_CHAPTER_PAGES->value); ?>
    <?= ApiDocumentation::card(Action::UPDATE_COMIC_CHAPTER_PAGE->value); ?>
    <?= ApiDocumentation::card(Action::DELETE_COMIC_CHAPTER_PAGE->value); ?>

    <?= ApiDocumentation::section("comment", "Comment"); ?>
    <?= ApiDocumentation::card(Action::GET_COMMENTS->value); ?>
    <?= ApiDocumentation::card(Action::INSERT_COMMENT->value); ?>
    <?= ApiDocumentation::card(Action::UPDATE_COMMENT->value); ?>
    <?= ApiDocumentation::card(Action::DELETE_COMMENT->value); ?>

    <?= ApiDocumentation::section("reply", "Reply"); ?>
    <?= ApiDocumentation::card(Action::GET_REPLIES->value); ?>
    <?= ApiDocumentation::card(Action::INSERT_REPLY->value); ?>
    <?= ApiDocumentation::card(Action::UPDATE_REPLY->value); ?>
    <?= ApiDocumentation::card(Action::DELETE_REPLY->value); ?>

    <?= ApiDocumentation::section("rating", "Rating"); ?>
    <?= ApiDocumentation::card(Action::SAVE_RATING->value); ?>
    <?= ApiDocumentation::card(Action::DELETE_RATING->value); ?>
</div>
</body>
</html>