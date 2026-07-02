<?php

namespace App\Controllers;

use App\Response;
use App\Services\ComicService;
use App\Validator;

class ComicController
{
    public static function index(): void
    {
        $service = new ComicService();

        Response::success(
            $service->getAll()
        );
    }

    public static function show(): void
    {
        $errors = Validator::required(
            $_POST,
            ['id']
        );

        if (!empty($errors)) {
            Response::error($errors);
        }

        $service = new ComicService();

        $comic = $service->getById(
            (int)$_POST['id']
        );

        if (!$comic) {
            Response::error([
                'Comic not found.'
            ]);
        }

        Response::success($comic);
    }

    public static function store(): void
    {
        $errors = Validator::required(
            $_POST,
            [
                'title',
                'description',
                'poster',
                'author_id'
            ]
        );

        if (!empty($errors)) {
            Response::error($errors);
        }

        $service = new ComicService();

        $id = $service->create($_POST);

        Response::success([
            'comic_id' => $id
        ], 201);
    }

    public static function update(): void
    {
        $errors = Validator::required(
            $_POST,
            [
                'id',
                'title',
                'description'
            ]
        );

        if (!empty($errors)) {
            Response::error($errors);
        }

        $service = new ComicService();

        $service->update(
            (int)$_POST['id'],
            $_POST
        );

        Response::success();
    }

    public static function delete(): void
    {
        $errors = Validator::required(
            $_POST,
            ['id']
        );

        if (!empty($errors)) {
            Response::error($errors);
        }

        $service = new ComicService();

        $service->delete(
            (int)$_POST['id']
        );

        Response::success();
    }
}