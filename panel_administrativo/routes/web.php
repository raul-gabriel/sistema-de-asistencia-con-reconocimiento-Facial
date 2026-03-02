<?php

use App\Http\Controllers\AlumnoController;
use App\Http\Controllers\Auth\LoginController;
use App\Livewire\Alumnos\Alumno;
use App\Livewire\Asistencias\Asistencia;
use App\Livewire\Counter;
use App\Livewire\Embeddings\Embedding;
use App\Livewire\Horarios\Horario;
use App\Livewire\Inicio;
use App\Livewire\Usuarios\Usuario;
use Illuminate\Support\Facades\Route;

Route::get('/', [LoginController::class, 'index'])->name('login');

Route::get('/login', [LoginController::class, 'index'])->name('login');
Route::post('/login', [LoginController::class, 'login']);
Route::post('/logout', [LoginController::class, 'logout'])->name('logout');



Route::middleware(['auth'])->group(function () {
    Route::get('/inicio', Inicio::class)->name('inicio');

    Route::get('/counter', Counter::class);
    Route::get('/usuarios', Usuario::class);
    Route::get('/horarios', Horario::class);
    Route::get('/alumnos', Alumno::class);
    Route::get('/embedding', Embedding::class);
    Route::get('/asistencias', Asistencia::class);
});


