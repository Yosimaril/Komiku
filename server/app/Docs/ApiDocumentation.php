<?php

namespace App\Docs;

use App\Enums\Action;

class ApiDocumentation
{
    public static function all(): array
    {
        return [
            Action::OPTIONS->value => [
                'description' => 'Available options.',
                'response' => [
                    'STATUS',
                    'DATA',
                    'ERROR_MESSAGE'
                ]
            ],

            Action::LOGIN->value => [
                'description' => 'Login user.',
                'payload' => [
                    'username' => 'required',
                    'password' => 'required'
                ],
                'response' => [
                    'STATUS',
                    'DATA',
                    'ERROR_MESSAGE'
                ]
            ],

            Action::GET_CATEGORIES->value => [
                'description' => 'Retrieve all categories.',
                'payload' => [
                    'keyword' => 'optional'
                ],
                'response' => [
                    'STATUS',
                    'DATA',
                    'ERROR_MESSAGE'
                ]
            ],

            Action::INSERT_CATEGORY->value => [
                'description' => 'Create a new category.',
                'payload' => [
                    'category' => [
                        'name' => 'required',
                        'description' => 'optional'
                    ]
                ],
                'success_code' => 201,
                'returns' => [
                    'category' => [
                        'id',
                        'name',
                        'description'
                    ]
                ]
            ],

            Action::UPDATE_CATEGORY->value => [
                'description' => 'Update category.',
                'payload' => [
                    'category' => [
                        'id' => 'required',
                        'name' => 'required',
                        'description' => 'optional'
                    ]
                ],
                'returns' => [
                    'updated'
                ]
            ],

            Action::DELETE_CATEGORY->value => [
                'description' => 'Delete category.',
                'payload' => [
                    'id' => 'required'
                ],
                'returns' => [
                    'deleted'
                ]
            ],


        ];
    }
}