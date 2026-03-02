<?php

use App\Http\Controllers\AlumnoController;
use App\Http\Controllers\ApiController;
use App\Http\Controllers\Auth\LoginController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;


/*
Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');*/


//apis
Route::post('login', [ApiController::class, 'login']);
Route::get('alumnos', [ApiController::class, 'buscarAlumnos']);
Route::post('guardarembedding', [ApiController::class, 'guardarEmbedding']);