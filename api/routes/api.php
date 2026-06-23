<?php

use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\DeputyController;
use App\Http\Controllers\Api\GroupController;
use App\Http\Controllers\Api\SearchController;
use App\Http\Controllers\Api\ScrutinController;
use Illuminate\Support\Facades\Route;

Route::get('/dashboard', [DashboardController::class, 'index']);

Route::prefix('deputies')->group(function (): void {
    Route::get('/', [DeputyController::class, 'index']);
    Route::get('{deputy:slug}', [DeputyController::class, 'show']);
    Route::get('{deputy:slug}/votes', [DeputyController::class, 'votes']);
});

Route::prefix('groups')->group(function (): void {
    Route::get('/', [GroupController::class, 'index']);
    Route::get('{slug}', [GroupController::class, 'show']);
    Route::get('{slug}/deputies', [GroupController::class, 'deputies']);
});

Route::get('/search', [SearchController::class, 'search']);

Route::prefix('scrutins')->group(function (): void {
    Route::get('/', [ScrutinController::class, 'index']);
    Route::get('{scrutin}', [ScrutinController::class, 'show']);
    Route::get('{scrutin}/votes', [ScrutinController::class, 'votes']);
});
