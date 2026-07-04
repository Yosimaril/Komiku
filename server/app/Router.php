<?php

namespace App;

use App\Controllers\ChapterController;
use App\Controllers\ChapterPageController;
use App\Controllers\ComicController;
use App\Controllers\CommentController;
use App\Controllers\OptionController;
use App\Controllers\RatingController;
use App\Controllers\ReplyController;
use App\Controllers\UserController;
use App\Enums\Action;
use App\Controllers\CategoryController;
use App\Middleware\AuthMiddleware;

class Router
{
    private const AUTHENTICATED_ROUTES = [
        Action::UPDATE_USER,
        Action::DELETE_USER,

        Action::INSERT_COMIC,
        Action::UPDATE_COMIC,
        Action::DELETE_COMIC,

        Action::INSERT_COMIC_CHAPTERS,
        Action::UPDATE_COMIC_CHAPTER,
        Action::DELETE_COMIC_CHAPTER,

        Action::INSERT_COMIC_CHAPTER_PAGES,
        Action::UPDATE_COMIC_CHAPTER_PAGE,
        Action::DELETE_COMIC_CHAPTER_PAGE,

        Action::INSERT_COMMENT,
        Action::UPDATE_COMMENT,
        Action::DELETE_COMMENT,

        Action::INSERT_REPLY,
        Action::UPDATE_REPLY,
        Action::DELETE_REPLY,

        Action::INSERT_RATING,
        Action::UPDATE_RATING,
        Action::DELETE_RATING,
    ];

    private const ROUTES = [
        Action::OPTIONS->value => [OptionController::class, 'info'],

        Action::LOGIN->value => [UserController::class, 'login'],
        Action::REGISTER->value => [UserController::class, 'register'],
        Action::UPDATE_USER->value => [UserController::class, 'update'],
        Action::DELETE_USER->value => [UserController::class, 'delete'],

        Action::GET_CATEGORIES->value => [CategoryController::class, 'get'],
        Action::INSERT_CATEGORY->value => [CategoryController::class, 'insert'],
        Action::UPDATE_CATEGORY->value => [CategoryController::class, 'update'],
        Action::DELETE_CATEGORY->value => [CategoryController::class, 'delete'],

        Action::GET_COMICS->value => [ComicController::class, 'get'],
        Action::GET_COMIC_DETAIL->value => [ComicController::class, 'getDetail'],
        Action::INSERT_COMIC->value => [ComicController::class, 'insert'],
        Action::UPDATE_COMIC->value => [ComicController::class, 'update'],
        Action::DELETE_COMIC->value => [ComicController::class, 'delete'],

        Action::GET_COMIC_CHAPTERS->value => [ChapterController::class, 'get'],
        Action::INSERT_COMIC_CHAPTERS->value => [ChapterController::class, 'insert'],
        Action::UPDATE_COMIC_CHAPTER->value => [ChapterController::class, 'update'],
        Action::DELETE_COMIC_CHAPTER->value => [ChapterController::class, 'delete'],

        Action::GET_COMIC_CHAPTER_PAGES->value => [ChapterPageController::class, 'get'],
        Action::INSERT_COMIC_CHAPTER_PAGES->value => [ChapterPageController::class, 'insert'],
        Action::UPDATE_COMIC_CHAPTER_PAGE->value => [ChapterPageController::class, 'update'],
        Action::DELETE_COMIC_CHAPTER_PAGE->value => [ChapterPageController::class, 'delete'],

        Action::GET_COMMENTS->value => [CommentController::class, 'get'],
        Action::INSERT_COMMENT->value => [CommentController::class, 'insert'],
        Action::UPDATE_COMMENT->value => [CommentController::class, 'update'],
        Action::DELETE_COMMENT->value => [CommentController::class, 'delete'],

        Action::GET_REPLIES->value => [ReplyController::class, 'get'],
        Action::INSERT_REPLY->value => [ReplyController::class, 'insert'],
        Action::UPDATE_REPLY->value => [ReplyController::class, 'update'],
        Action::DELETE_REPLY->value => [ReplyController::class, 'delete'],

        Action::INSERT_RATING->value => [RatingController::class, 'insert'],
        Action::UPDATE_RATING->value => [RatingController::class, 'update'],
        Action::DELETE_RATING->value => [RatingController::class, 'delete'],
    ];

    public static function dispatch(Action $action): void
    {
        if (
            in_array(
                $action,
                self::AUTHENTICATED_ROUTES,
                true
            )
        ) {
            AuthMiddleware::authenticate();
        }

        $handler = self::ROUTES[$action->value] ?? null;

        if ($handler === null) {
            Response::error([
                'Action not implemented.',
            ]);
        }

        call_user_func($handler);
    }
}