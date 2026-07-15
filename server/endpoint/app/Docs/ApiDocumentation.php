<?php

namespace App\Docs;

use App\Enums\Action;

class ApiDocumentation
{
    public const VERSION = "1.0.0";
    public const AUTHENTICATION = "JWT";
    public const METHOD = "POST";
    public const API = [
        Action::OPTIONS->value => [
            "title" => "Options",
            "description" => "Available options.",
            "method" => "GET",
            "auth" => false,

            "request" => [
                "action" => Action::OPTIONS->value,
            ],

            "response" => [
                "status" => "SUCCESS",
                "data" => "DATA",
                "error_message" => "ERROR_MESSAGE"
            ]
        ],
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
                "status" => "SUCCESS",
                "data" => [
                    "user" => [
                        "id" => 1,
                        "username" => "Admin",
                        "created_at" => "...",
                        "updated_at" => "..."
                    ],
                    "token" => "..."
                ],
                "error_message" => []
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
                "status" => "SUCCESS",
                "data" => [
                    "user" => [
                        "id" => 1,
                        "username" => "Admin"
                    ],
                    "token" => "..."
                ],
                "error_message" => []
            ]
        ],

        Action::UPDATE_USER->value => [
            "title" => "Update User",
            "description" => "Update user account details.",
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
                "status" => "SUCCESS",
                "data" => [
                    "updated" => true
                ],
                "error_message" => []
            ]
        ],

        Action::DELETE_USER->value => [
            "title" => "Delete User",
            "description" => "Delete user account.",
            "method" => "POST",
            "auth" => true,

            "request" => [
                "action" => Action::DELETE_USER->value,
                "user" => [
                    "password" => "1234567890"
                ]
            ],

            "response" => [
                "status" => "SUCCESS",
                "data" => [
                    "deleted" => true
                ],
                "error_message" => []
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
                "keyword" => "[optional]"
            ],

            "response" => [
                "status" => "SUCCESS",
                "data" => [
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
                "error_message" => []
            ]
        ],

        Action::INSERT_CATEGORY->value => [
            "title" => "Insert Category",
            "description" => "Create a new category.",
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
                "status" => "SUCCESS",
                "data" => [
                    "category" => [
                        "id" => 5,
                        "name" => "Fantasy",
                        "description" => "null"
                    ]
                ],
                "error_message" => []
            ]
        ],

        Action::UPDATE_CATEGORY->value => [
            "title" => "Update Category",
            "description" => "Update an existing category.",
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
                "status" => "SUCCESS",
                "data" => [
                    "updated" => true
                ],
                "error_message" => []
            ]
        ],

        Action::DELETE_CATEGORY->value => [
            "title" => "Delete Category",
            "description" => "Delete a category.",
            "method" => "POST",
            "auth" => false,

            "request" => [
                "action" => Action::DELETE_CATEGORY->value,
                "id" => 5
            ],

            "response" => [
                "status" => "SUCCESS",
                "data" => [
                    "deleted" => true
                ],
                "error_message" => []
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
                "keyword" => "[optional]"
            ],

            "response" => [
                "status" => "SUCCESS",
                "data" => [
                    [
                        "id" => 1,
                        "title" => "Chronicles of Flutter",
                        "poster" => "...",
                        "description" => "...",
                        "average_rating" => 4.67,
                        "rating_count" => 10,
                        "categories" => [
                            [
                              "id"=> 1,
                              "name" => "Action"
                            ],
                            [
                              "id"=> 2,
                              "name" => "Adventure"
                            ]
                        ],
                        "creator_name" => "Adam",
                        "created_at" => "...",
                        "updated_at" => "..."
                    ],
                    [
                        "id" => 2,
                        "title" => "Adventure of Dart",
                        "poster" => "...",
                        "description" => "...",
                        "average_rating" => 4,
                        "rating_count" => 5,
                        "categories" => [
                            [
                              "id"=> 1,
                              "name" => "Action"
                            ],
                            [
                              "id"=> 2,
                              "name" => "Adventure"
                            ]
                        ],
                        "creator_name" => "Eve",
                        "created_at" => "...",
                        "updated_at" => "..."
                    ]
                ],
                "error_message" => []
            ]
        ],

        Action::GET_COMIC_DETAIL->value => [
            "title" => "Get Comic Detail",
            "description" => "Retrieve details for a specific comic.",
            "method" => "POST",
            "auth" => false,

            "request" => [
                "action" => Action::GET_COMIC_DETAIL->value,
                "id" => 2
            ],

            "response" => [
                "status" => "SUCCESS",
                "data" => [
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
                "error_message" => []
            ]
        ],

        Action::INSERT_COMIC->value => [
            "title" => "Insert Comic",
            "description" => "Create a new comic.",
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
                "status" => "SUCCESS",
                "data" => [
                    "comic" => [
                        "id" => 9,
                        "creator_id" => 13,
                        "title" => "I was reincarnated as a Flutter developer so I whatever...",
                        "poster" => "null",
                        "description" => "null"
                    ]
                ],
                "error_message" => []
            ]
        ],

        Action::UPDATE_COMIC->value => [
            "title" => "Update Comic",
            "description" => "Update an existing comic.",
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
                "status" => "SUCCESS",
                "data" => [
                    "updated" => true
                ],
                "error_message" => []
            ]
        ],

        Action::DELETE_COMIC->value => [
            "title" => "Delete Comic",
            "description" => "Delete a comic.",
            "method" => "POST",
            "auth" => true,

            "request" => [
                "action" => Action::DELETE_COMIC->value,
                "id" => 9
            ],

            "response" => [
                "status" => "SUCCESS",
                "data" => [
                    "deleted" => true
                ],
                "error_message" => []
            ]
        ],
    ];

    private const COMIC_CHAPTER_API = [
        Action::GET_COMIC_CHAPTERS->value => [
            "title" => "Get Chapters",
            "description" => "Retrieve all chapters of a comic.",
            "method" => "POST",
            "auth" => false,

            "request" => [
                "action" => Action::GET_COMIC_CHAPTERS->value,
                "comic_id" => 2,
                "keyword" => "[optional]"
            ],

            "response" => [
                "status" => "SUCCESS",
                "data" => [
                    [
                        "id" => 1,
                        "comic_title" => "The hero of Flutter",
                        "chapter_number" => 1,
                        "title" => "Troublesome IDE",
                        "created_at" => "...",
                        "updated_at" => "..."
                    ],
                    [
                        "id" => 2,
                        "comic_title" => "The hero of Flutter",
                        "chapter_number" => 2,
                        "title" => "A paid subscription",
                        "created_at" => "...",
                        "updated_at" => "..."
                    ]
                ],
                "error_message" => []
            ]
        ],

        Action::INSERT_COMIC_CHAPTERS->value => [
            "title" => "Insert Comic Chapters",
            "description" => "Insert new chapter(s) for a comic.",
            "method" => "POST",
            "auth" => true,

            "request" => [
                "action" => Action::INSERT_COMIC_CHAPTERS->value,
                "comic_id" => 10,
                "chapters" => [
                    [
                        "chapter_number" => 1,
                        "title" => "Ini the beninging",
                    ],
                    [
                        "chapter_number" => 2,
                        "title" => "Ini the second aftermath",
                    ]
                ]
            ],

            "response" => [
                "status" => "SUCCESS",
                "data" => [
                    "comic_id" => 10,
                    "chapters" => [
                        [
                            "id" => 11,
                            "chapter_number" => 1,
                            "title" => "Ini the beninging",
                        ],
                        [
                            "id" => 12,
                            "chapter_number" => 2,
                            "title" => "Ini the second aftermath",
                        ]
                    ]
                ],
                "error_message" => []
            ]
        ],

        Action::UPDATE_COMIC_CHAPTER->value => [
            "title" => "Update Comic Chapter",
            "description" => "Update an existing chapter.",
            "method" => "POST",
            "auth" => true,

            "request" => [
                "action" => Action::UPDATE_COMIC_CHAPTER->value,
                "chapter" => [
                    "id" => 11,
                    "chapter_number" => 3,
                    "title" => "In the beginning",
                ]
            ],

            "response" => [
                "status" => "SUCCESS",
                "data" => [
                    "updated" => true
                ],
                "error_message" => []
            ]
        ],

        Action::DELETE_COMIC_CHAPTER->value => [
            "title" => "Delete Comic Chapter",
            "description" => "Delete a chapter.",
            "method" => "POST",
            "auth" => true,

            "request" => [
                "action" => Action::DELETE_COMIC_CHAPTER->value,
                "id" => 11
            ],

            "response" => [
                "status" => "SUCCESS",
                "data" => [
                    "deleted" => true
                ],
                "error_message" => []
            ]
        ],
    ];

    private const COMIC_CHAPTER_PAGE_API = [
        Action::GET_COMIC_CHAPTER_PAGES->value => [
            "title" => "Get Chapter Pages",
            "description" => "Retrieve all pages of a chapter.",
            "method" => "POST",
            "auth" => false,

            "request" => [
                "action" => Action::GET_COMIC_CHAPTER_PAGES->value,
                "chapter_id" => 1,
            ],

            "response" => [
                "status" => "SUCCESS",
                "data" => [
                    [
                        "id" => 1,
                        "chapter_title" => "The Broken Village",
                        "page_number" => 1,
                        "image" => "...",
                        "created_at" => "...",
                        "updated_at" => "..."
                    ],
                    [
                        "id" => 2,
                        "chapter_title" => "The Broken Village",
                        "page_number" => 2,
                        "image" => "...",
                        "created_at" => "...",
                        "updated_at" => "..."
                    ]
                ],
                "error_message" => []
            ]
        ],

        Action::INSERT_COMIC_CHAPTER_PAGES->value => [
            "title" => "Insert Comic Chapter Pages",
            "description" => "Insert new page(s) for a chapter.",
            "method" => "POST",
            "auth" => true,

            "request" => [
                "action" => Action::INSERT_COMIC_CHAPTER_PAGES->value,
                "chapter_id" => 12,
                "pages" => [
                    [
                        "page_number" => 1,
                        "image" => "...",
                    ],
                    [
                        "page_number" => 2,
                        "image" => "...",
                    ]
                ]
            ],

            "response" => [
                "status" => "SUCCESS",
                "data" => [
                    "chapter_id" => 12,
                    "pages" => [
                        [
                            "id" => 59,
                            "page_number" => 1,
                            "image" => "...",
                        ],
                        [
                            "id" => 60,
                            "page_number" => 2,
                            "image" => "...",
                        ]
                    ]
                ],
                "error_message" => []
            ]
        ],

        Action::UPDATE_COMIC_CHAPTER_PAGE->value => [
            "title" => "Update Comic Chapter Page",
            "description" => "Update an existing page.",
            "method" => "POST",
            "auth" => true,

            "request" => [
                "action" => Action::UPDATE_COMIC_CHAPTER_PAGE->value,
                "page" => [
                    "id" => 59,
                    "page_number" => 3,
                    "image" => "...",
                ]
            ],

            "response" => [
                "status" => "SUCCESS",
                "data" => [
                    "updated" => true
                ],
                "error_message" => []
            ]
        ],

        Action::DELETE_COMIC_CHAPTER_PAGE->value => [
            "title" => "Delete Comic Chapter Page",
            "description" => "Delete a page.",
            "method" => "POST",
            "auth" => true,

            "request" => [
                "action" => Action::DELETE_COMIC_CHAPTER_PAGE->value,
                "id" => 59
            ],

            "response" => [
                "status" => "SUCCESS",
                "data" => [
                    "deleted" => true
                ],
                "error_message" => []
            ]
        ],
    ];

    private const COMMENT_API = [
        Action::GET_COMMENTS->value => [
            "title" => "Get Comments",
            "description" => "Retrieve all comments of a comic.",
            "method" => "POST",
            "auth" => false,

            "request" => [
                "action" => Action::GET_COMMENTS->value,
                "comic_id" => 1,
            ],

            "response" => [
                "status" => "SUCCESS",
                "data" => [
                    [
                        "id" => 1,
                        "content" => "This comic is insane, the fight scenes are so clean!",
                        "created_at" => "...",
                        "updated_at" => "...",
                        "user_id" => 1,
                        "username" => "Jack"
                    ],
                    [
                        "id" => 2,
                        "content" => "I love this comic!",
                        "created_at" => "...",
                        "updated_at" => "...",
                        "user_id" => 2,
                        "username" => "Jane"
                    ]
                ],
                "error_message" => []
            ]
        ],

        Action::INSERT_COMMENT->value => [
            "title" => "Insert Comment",
            "description" => "Insert a new comment.",
            "method" => "POST",
            "auth" => true,

            "request" => [
                "action" => Action::INSERT_COMMENT->value,
                "comment" => [
                    "comic_id" => 10,
                    "content" => "Hello"
                ]
            ],

            "response" => [
                "status" => "SUCCESS",
                "data" => [
                    "comment" => [
                        "id" => 27,
                        "comic_id" => 10,
                        "user_id" => 13,
                        "content" => "Hello"
                    ]
                ],
                "error_message" => []
            ]
        ],

        Action::UPDATE_COMMENT->value => [
            "title" => "Update Comment",
            "description" => "Update a comment.",
            "method" => "POST",
            "auth" => true,

            "request" => [
                "action" => Action::UPDATE_COMMENT->value,
                "comment" => [
                    "id" => 27,
                    "content" => "Hello"
                ]
            ],

            "response" => [
                "status" => "SUCCESS",
                "data" => [
                    "updated" => true
                ],
                "error_message" => []
            ]
        ],

        Action::DELETE_COMMENT->value => [
            "title" => "Delete Comment",
            "description" => "Delete a comment.",
            "method" => "POST",
            "auth" => true,

            "request" => [
                "action" => Action::DELETE_COMMENT->value,
                "id" => 27
            ],

            "response" => [
                "status" => "SUCCESS",
                "data" => [
                    "deleted" => true
                ],
                "error_message" => []
            ]
        ],
    ];

    private const REPLY_API = [
        Action::GET_REPLIES->value => [
            "title" => "Get Replies",
            "description" => "Retrieve all replies of a comment.",
            "method" => "POST",
            "auth" => false,

            "request" => [
                "action" => Action::GET_REPLIES->value,
                "parent_comment_id" => 26,
            ],

            "response" => [
                "status" => "SUCCESS",
                "data" => [
                    [
                        "id" => 28,
                        "content" => "asdfghjkl",
                        "created_at" => "...",
                        "updated_at" => "...",
                        "user_id" => 16,
                        "username" => "Spongebob"
                    ],
                    [
                        "id" => 28,
                        "content" => "ok",
                        "created_at" => "...",
                        "updated_at" => "...",
                        "user_id" => 17,
                        "username" => "Squidward"
                    ]
                ],
                "error_message" => []
            ]
        ],

        Action::INSERT_REPLY->value => [
            "title" => "Insert Reply",
            "description" => "Insert a reply to a comment.",
            "method" => "POST",
            "auth" => true,

            "request" => [
                "action" => Action::INSERT_REPLY->value,
                "reply" => [
                    "parent_comment_id" => 26,
                    "content" => "Hello, what's your name?"
                ]
            ],

            "response" => [
                "status" => "SUCCESS",
                "data" => [
                    "reply" => [
                        "id" => 30,
                        "comic_id" => 10,
                        "parent_comment_id" => 26,
                        "user_id" => 13,
                        "content" => "Hello, what's your name?"
                    ]
                ],
                "error_message" => []
            ]
        ],

        Action::UPDATE_REPLY->value => [
            "title" => "Update Reply",
            "description" => "Update an existing reply.",
            "method" => "POST",
            "auth" => true,

            "request" => [
                "action" => Action::UPDATE_REPLY->value,
                "reply" => [
                    "id" => 30,
                    "content" => "Hello"
                ]
            ],

            "response" => [
                "status" => "SUCCESS",
                "data" => [
                    "updated" => true
                ],
                "error_message" => []
            ]
        ],

        Action::DELETE_REPLY->value => [
            "title" => "Delete Reply",
            "description" => "Delete a reply.",
            "method" => "POST",
            "auth" => true,

            "request" => [
                "action" => Action::DELETE_REPLY->value,
                "id" => 30
            ],

            "response" => [
                "status" => "SUCCESS",
                "data" => [
                    "deleted" => true
                ],
                "error_message" => []
            ]
        ],
    ];

    private const RATING_API = [
        Action::GET_RATING->value => [
            "title" => "Get Rating",
            "description" => "Retrieve the authenticated user's rating for a comic.",
            "method" => "POST",
            "auth" => true,

            "request" => [
                "action" => Action::GET_RATING->value,
                "comic_id" => 10
            ],

            "response" => [
                "status" => "SUCCESS",
                "data" => [
                    "rating" => [
                        "comic_id" => 10,
                        "user_id" => 13,
                        "rating" => 5
                    ]
                ],
                "error_message" => []
            ]
        ],

        Action::SAVE_RATING->value => [
            "title" => "Insert or Update Rating",
            "description" => "Insert or update a rating for a comic.",
            "method" => "POST",
            "auth" => true,

            "request" => [
                "action" => Action::SAVE_RATING->value,
                "rating" => [
                    "comic_id" => 10,
                    "rating" => 5
                ]
            ],

            "response" => [
                "status" => "SUCCESS",
                "data" => [
                    "rating" => [
                        "comic_id" => 10,
                        "user_id" => 13,
                        "rating" => 5
                    ]
                ],
                "error_message" => []
            ]
        ],

        Action::DELETE_RATING->value => [
            "title" => "Delete Rating",
            "description" => "Delete a rating for a comic.",
            "method" => "POST",
            "auth" => true,

            "request" => [
                "action" => Action::DELETE_RATING->value,
                "comic_id" => 30
            ],

            "response" => [
                "status" => "SUCCESS",
                "data" => [
                    "deleted" => true
                ],
                "error_message" => []
            ]
        ],
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
            <div id='$id' class='d-flex justify-content-between align-items-center mt-5 mb-3 px-2'>
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
                    <table class='table table-responsive table-bordered mb-4'>
                        <tr>
                            <th style='width: 200px'>Method</th>
                            <td>
                                <span class='badge text-bg-secondary'>{$api['method']}</span>
                            </td>
                        </tr>
                        <tr>
                            <th>Action</th>
                            <td>$action</td>
                        </tr>
                        <tr>
                            <th>Authentication</th>
                            <td>" . ($api['auth'] ? "<span class='badge text-bg-success'>JWT Authentication</span>" : "-") . "</td>
                        </tr>
                    </table>
                    <h6>Payload</h6>
                    <pre class='bg-light border p-3 overflow-auto'>" . json_encode($request, JSON_PRETTY_PRINT) . "</pre>
                    <h6>Success Response</h6>
                    <pre class='bg-light border p-3 overflow-auto'>" . json_encode($response, JSON_PRETTY_PRINT) . "</pre>
                </div>
            </div>
        ";
    }

    public static function totalEndpoints(): int
    {
        return count(self::API);
    }
}
