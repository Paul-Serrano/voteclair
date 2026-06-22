<?php

use App\Http\Controllers\Api\DeputyController;
use App\Http\Controllers\Api\GroupController;
use App\Http\Controllers\Api\ScrutinController;
use Illuminate\Support\Facades\Route;

Route::prefix('deputies')->group(function (): void {
    Route::get('/', [DeputyController::class, 'index']);
    Route::get('{deputy:slug}', [DeputyController::class, 'show']);
    Route::get('{deputy:slug}/votes', [DeputyController::class, 'votes']);
});

Route::get('/groups', [GroupController::class, 'index']);

Route::prefix('scrutins')->group(function (): void {
    Route::get('/', [ScrutinController::class, 'index']);
    Route::get('{scrutin}', [ScrutinController::class, 'show']);
    Route::get('{scrutin}/votes', [ScrutinController::class, 'votes']);
});
