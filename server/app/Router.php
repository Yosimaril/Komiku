<?php

namespace App;

use App\Controllers\ComicController;
use App\Controllers\OptionController;
use App\Controllers\UserController;
use App\Enums\Action;
use App\Controllers\CategoryController;

class Router
{
    private const ROUTES = [
        Action::OPTIONS->value => [OptionController::class, 'info'],

        Action::LOGIN->value => [UserController::class, 'login'],
        Action::REGISTER->value => [UserController::class, 'register'],

        Action::GET_CATEGORIES->value => [CategoryController::class, 'get'],
        Action::INSERT_CATEGORY->value => [CategoryController::class, 'insert'],
        Action::UPDATE_CATEGORY->value => [CategoryController::class, 'update'],
        Action::DELETE_CATEGORY->value => [CategoryController::class, 'delete'],

        Action::GET_COMICS->value => [ComicController::class, 'get'],
        Action::GET_COMIC_DETAIL->value => [ComicController::class, 'getDetail'],
        Action::INSERT_COMIC->value => [ComicController::class, 'insert'],
        Action::UPDATE_COMIC->value => [ComicController::class, 'update'],
        Action::DELETE_COMIC->value => [ComicController::class, 'delete'],

        Action::INSERT_RATING->value => [RatingController::class, 'insert'],
        Action::UPDATE_RATING->value => [RatingController::class, 'update'],
        Action::DELETE_RATING->value => [RatingController::class, 'delete'],

        Action::INSERT_COMMENT->value => [CommentController::class, 'insert'],
        Action::UPDATE_COMMENT->value => [CommentController::class, 'update'],
        Action::DELETE_COMMENT->value => [CommentController::class, 'delete'],

        Action::INSERT_REPLY->value => [ReplyController::class, 'insert'],
        Action::UPDATE_REPLY->value => [ReplyController::class, 'update'],
        Action::DELETE_REPLY->value => [ReplyController::class, 'delete'],
    ];

    public static function dispatch(Action $action): void
    {
        $handler = self::ROUTES[$action->value] ?? null;

        if ($handler === null) {
            Response::error([
                'Action not implemented.',
            ]);
        }

        $handler();
    }
}