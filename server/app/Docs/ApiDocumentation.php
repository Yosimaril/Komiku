<?php

namespace App\Docs;

use App\Controllers\CategoryController;
use App\Controllers\ChapterController;
use App\Controllers\ChapterPageController;
use App\Controllers\ComicController;
use App\Controllers\CommentController;
use App\Controllers\OptionController;
use App\Controllers\RatingController;
use App\Controllers\ReplyController;
use App\Controllers\UserController;
use App\Enums\Action;

class ApiDocumentation
{
    public const API = [
        ...self::USER_API,
        ...self::CATEGORY_API,
        ...self::COMIC_API,
        ...self::COMIC_CHAPTER_API,
        ...self::COMIC_CHAPTER_PAGE_API,
        ...self::COMMENT_API,
        ...self::REPLY_API,
        ...self::RATING_API,
    ];

    private const USER_API = [
        Action::LOGIN->value => [
            "title" => "Login",
            "description" => "Authenticate user.",
            "method" => "POST",
            "auth" => false,

            "request" => [
                "action" => Action::LOGIN->value,
                "user" => [
                    "username" => "Admin",
                    "password" => "1234567890"
                ]
            ],

            "response" => [
                "STATUS" => "SUCCESS",
                "DATA" => [
                    "user" => [
                        "id" => 1,
                        "username" => "Admin",
                        "created_at" => "...",
                        "updated_at" => "..."
                    ],
                    "token" => "..."
                ],
                "ERROR_MESSAGE" => []
            ]
        ],

        Action::REGISTER->value => [
            "title" => "Register",
            "description" => "Create a new user account.",
            "method" => "POST",
            "auth" => false,

            "request" => [
                "action" => Action::REGISTER->value,
                "user" => [
                    "username" => "Admin",
                    "password" => "1234567890"
                ]
            ],

            "response" => [
                "STATUS" => "SUCCESS",
                "DATA" => [
                    "user" => [
                        "id" => 1,
                        "username" => "Admin"
                    ],
                    "token" => "..."
                ],
                "ERROR_MESSAGE" => []
            ]
        ],

        Action::UPDATE_USER->value => [
            "title" => "Update User",
            "description" => "Create a new user account.",
            "method" => "POST",
            "auth" => true,

            "request" => [
                "action" => Action::UPDATE_USER->value,
                "user" => [
                    "username" => "Admin123",
                    "password" => "1234567890"
                ]
            ],

            "response" => [
                "STATUS" => "SUCCESS",
                "DATA" => [
                    "updated" => true
                ],
                "ERROR_MESSAGE" => []
            ]
        ],

        Action::DELETE_USER->value => [
            "title" => "Delete User",
            "description" => "Create a new user account.",
            "method" => "POST",
            "auth" => true,

            "request" => [
                "action" => Action::DELETE_USER->value,
                "user" => [
                    "password" => "1234567890"
                ]
            ],

            "response" => [
                "STATUS" => "SUCCESS",
                "DATA" => [
                    "deleted" => true
                ],
                "ERROR_MESSAGE" => []
            ]
        ]
    ];

    private const CATEGORY_API = [
        Action::GET_CATEGORIES->value => [
            "title" => "Get Categories",
            "description" => "Retrieve all available comic categories.",
            "method" => "POST",
            "auth" => false,

            "request" => [
                "action" => Action::GET_CATEGORIES->value,
            ],

            "response" => [
                "STATUS" => "SUCCESS",
                "DATA" => [
                    [
                        "id" => 1,
                        "name" => "Action",
                        "description" => "Stories featuring intense battles, combat, and fast-paced adventures.",
                        "created_at" => "...",
                        "updated_at" => "..."
                    ],
                    [
                        "id" => 2,
                        "name" => "Adventure",
                        "description" => "Characters embark on exciting journeys to explore new places or achieve a goal.",
                        "created_at" => "...",
                        "updated_at" => "..."
                    ]
                ],
                "ERROR_MESSAGE" => []
            ]
        ],

        Action::INSERT_CATEGORY->value => [
            "title" => "Insert Category",
            "description" => "Create a new user account.",
            "method" => "POST",
            "auth" => false,

            "request" => [
                "action" => Action::INSERT_CATEGORY->value,
                "category" => [
                    "name" => "Fantasy",
                    "description" => "[optional]"
                ]
            ],

            "response" => [
                "STATUS" => "SUCCESS",
                "DATA" => [
                    "category" => [
                        "id" => 5,
                        "name" => "Fantasy",
                        "description" => "null"
                    ]
                ],
                "ERROR_MESSAGE" => []
            ]
        ],

        Action::UPDATE_CATEGORY->value => [
            "title" => "Update Category",
            "description" => "Create a new user account.",
            "method" => "POST",
            "auth" => false,

            "request" => [
                "action" => Action::UPDATE_CATEGORY->value,
                "category" => [
                    "id" => 5,
                    "name" => "Education",
                    "description" => "[optional]"
                ]
            ],

            "response" => [
                "STATUS" => "SUCCESS",
                "DATA" => [
                    "updated" => true
                ],
                "ERROR_MESSAGE" => []
            ]
        ],

        Action::DELETE_CATEGORY->value => [
            "title" => "Delete Category",
            "description" => "Create a new user account.",
            "method" => "POST",
            "auth" => false,

            "request" => [
                "action" => Action::DELETE_CATEGORY->value,
                "id" => 5
            ],

            "response" => [
                "STATUS" => "SUCCESS",
                "DATA" => [
                    "deleted" => true
                ],
                "ERROR_MESSAGE" => []
            ]
        ],
    ];

    private const COMIC_API = [
        Action::GET_COMICS->value => [
            "title" => "Get Comics",
            "description" => "Retrieve all available comics.",
            "method" => "POST",
            "auth" => false,

            "request" => [
                "action" => Action::GET_COMICS->value,
            ],

            "response" => [
                "STATUS" => "SUCCESS",
                "DATA" => [
                    [
                        "id" => 1,
                        "title" => "Chronicles of Flutter",
                        "poster" => "...",
                        "description" => "...",
                        "creator" => "Adam",
                        "created_at" => "...",
                        "updated_at" => "..."
                    ],
                    [
                        "id" => 2,
                        "title" => "Adventure of Dart",
                        "poster" => "...",
                        "description" => "...",
                        "creator" => "Eve",
                        "created_at" => "...",
                        "updated_at" => "..."
                    ]
                ],
                "ERROR_MESSAGE" => []
            ]
        ],

        Action::GET_COMIC_DETAIL->value => [
            "title" => "Get Categories",
            "description" => "Retrieve all available comic categories.",
            "method" => "POST",
            "auth" => false,

            "request" => [
                "action" => Action::GET_COMIC_DETAIL,
                "id" => 2
            ],

            "response" => [
                "STATUS" => "SUCCESS",
                "DATA" => [
                    "id" => 2,
                    "creator" => [
                        "id" => 2,
                        "username" => "Eve"
                    ],
                    "title" => "Adventure of Dart",
                    "poster" => "...",
                    "description" => "...",
                    "created_at" => "...",
                    "updated_at" => "...",
                    "average_rating" => 4,
                    "rating_count" => 5,
                    "comments" => [
                        [
                            "id" => 6,
                            "parent_comment_id" => null,
                            "content" => "This is such a cute story!",
                            "created_at" => "...",
                            "updated_at" => "...",
                            "user_id" => 1,
                            "username" => "Adam"
                        ],
                        [
                            "id" => 7,
                            "parent_comment_id" => null,
                            "content" => "Woah!",
                            "created_at" => "...",
                            "updated_at" => "...",
                            "user_id" => 1,
                            "username" => "Jack"
                        ],
                    ],
                    "chapters" => [
                        [
                            "id" => 3,
                            "comic_id" => 2,
                            "chapter_number" => 1,
                            "title" => "Unexpected Meeting",
                            "created_at" => "...",
                            "updated_at" => "...",
                            "chapter_pages" => [
                                [
                                    "id" => 1,
                                    "page_number" => 1,
                                    "image" => "..."
                                ],
                                [
                                    "id" => 2,
                                    "page_number" => 2,
                                    "image" => "..."
                                ],
                            ]
                        ],
                        [
                            "id" => 4,
                            "comic_id" => 2,
                            "chapter_number" => 2,
                            "title" => "Meeting",
                            "created_at" => "...",
                            "updated_at" => "...",
                            "chapter_pages" => [
                                [
                                    "id" => 5,
                                    "page_number" => 1,
                                    "image" => "..."
                                ],
                                [
                                    "id" => 6,
                                    "page_number" => 2,
                                    "image" => "..."
                                ],
                            ]
                        ]
                    ]
                ],
                "ERROR_MESSAGE" => []
            ]
        ],

        Action::INSERT_COMIC->value => [
            "title" => "Insert Category",
            "description" => "Create a new user account.",
            "method" => "POST",
            "auth" => true,

            "request" => [
                "action" => Action::INSERT_COMIC->value,
                "comic" => [
                    "title" => "I was reincarnated as a Flutter developer so I whatever...",
                    "poster" => "[optional]",
                    "description" => "[optional]"
                ]
            ],

            "response" => [
                "STATUS" => "SUCCESS",
                "DATA" => [
                    "comic" => [
                        "id" => 9,
                        "creator_id" => 13,
                        "title" => "I was reincarnated as a Flutter developer so I whatever...",
                        "poster" => "null",
                        "description" => "null"
                    ]
                ],
                "ERROR_MESSAGE" => []
            ]
        ],

        Action::UPDATE_COMIC->value => [
            "title" => "Update Category",
            "description" => "Create a new user account.",
            "method" => "POST",
            "auth" => true,

            "request" => [
                "action" => Action::UPDATE_COMIC->value,
                "comic" => [
                    "id" => 9,
                    "title" => "I was reincarnated as a Dart language so I whatever...",
                    "poster" => "[optional]",
                    "description" => "[optional]"
                ]
            ],

            "response" => [
                "STATUS" => "SUCCESS",
                "DATA" => [
                    "updated" => true
                ],
                "ERROR_MESSAGE" => []
            ]
        ],

        Action::DELETE_COMIC->value => [
            "title" => "Delete Category",
            "description" => "Create a new user account.",
            "method" => "POST",
            "auth" => true,

            "request" => [
                "action" => Action::DELETE_COMIC->value,
                "id" => 9
            ],

            "response" => [
                "STATUS" => "SUCCESS",
                "DATA" => [
                    "deleted" => true
                ],
                "ERROR_MESSAGE" => []
            ]
        ],
    ];

    private const COMIC_CHAPTER_API = [
        Action::GET_CHAPTERS->value => "",
        Action::INSERT_COMIC_CHAPTERS->value => "",
        Action::UPDATE_COMIC_CHAPTER->value => "",
        Action::DELETE_COMIC_CHAPTER->value => "",
    ];

    private const COMIC_CHAPTER_PAGE_API = [
        Action::GET_CHAPTER_PAGES->value => "",
        Action::INSERT_COMIC_CHAPTER_PAGES->value => "",
        Action::UPDATE_COMIC_CHAPTER_PAGE->value => "",
        Action::DELETE_COMIC_CHAPTER_PAGE->value => "",
    ];

    private const COMMENT_API = [
        Action::GET_COMMENTS->value => "",
        Action::INSERT_COMMENT->value => "",
        Action::UPDATE_COMMENT->value => "",
        Action::DELETE_COMMENT->value => "",
    ];

    private const REPLY_API = [
        Action::GET_REPLIES->value => "",
        Action::INSERT_REPLY->value => "",
        Action::UPDATE_REPLY->value => "",
        Action::DELETE_REPLY->value => "",
    ];

    private const RATING_API = [
        Action::INSERT_RATING->value => "",
        Action::UPDATE_RATING->value => "",
        Action::DELETE_RATING->value => "",
    ];

    public static function link(string $id, string $title): string
    {
        return "
            <a href='#$id' class='btn btn-outline-secondary'>$title</a>
        ";
    }

    public static function section(string $id, string $title): string
    {
        return "
            <div id='$id' class='d-flex justify-content-between align-items-center mt-5 mb-3'>
                <h2>$title</h2>
                <a href='#top'>
                    Back to Top
                </a>
            </div>
        ";
    }

    public static function card(string $action): string
    {
        $api = self::API[$action];
        $request = $api['request'] ?? [];
        $response = $api['response'] ?? [];

        return "
            <div class='card shadow-sm mb-4'>
                <div class='card-header'>
                    <strong>{$api['title']}</strong>
                </div>
                <div class='card-body'>
                    <p>{$api['description']}</p>
                    <table class='table table-bordered mb-4'>
                        <tr>
                            <th style='width: 200px'>Method</th>
                            <td>{$api['method']}</td>
                        </tr>
                        <tr>
                            <th>Action</th>
                            <td>$action</td>
                        </tr>
                        <tr>
                            <th>Authentication</th>
                            <td>" . ($api['auth'] ? "Required" : "-") . "</td>
                        </tr>
                    </table>
                    <h6>Payload</h6>
                    <pre class='bg-light border p-3'>" . json_encode($request, JSON_PRETTY_PRINT) . "</pre>
                    <h6>Success Response</h6>
                    <pre class='bg-light border p-3'>" . json_encode($response, JSON_PRETTY_PRINT) . "</pre>
                </div>
            </div>
        ";
    }
}