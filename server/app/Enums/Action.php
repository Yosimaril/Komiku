<?php

namespace App\Enums;

enum Action: string
{
    case OPTIONS = 'OPTIONS';

    // User
    case LOGIN = 'LOGIN';
    case REGISTER = 'REGISTER';

    // Comic
    case GET_COMICS = 'GET_COMICS';
    case GET_COMIC_DETAIL = 'GET_COMIC_DETAIL';
    case INSERT_COMIC = 'INSERT_COMIC';
    case UPDATE_COMIC = 'UPDATE_COMIC';
    case DELETE_COMIC = 'DELETE_COMIC';

    // Comic chapter
    case GET_COMIC_CHAPTERS = 'GET_COMIC_CHAPTERS';
    case INSERT_COMIC_CHAPTER = 'INSERT_COMIC_CHAPTER';
    case UPDATE_COMIC_CHAPTER = 'UPDATE_COMIC_CHAPTER';
    case DELETE_COMIC_CHAPTER = 'DELETE_COMIC_CHAPTER';

    // Category
    case GET_CATEGORIES = 'GET_CATEGORIES';

    // Other things
    case INSERT_RATING = 'INSERT_RATING';
    case INSERT_COMMENT = 'INSERT_COMMENT';
    case INSERT_REPLY = 'INSERT_REPLY';
}