<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;

/*
|--------------------------------------------------------------------------
| Database Health Check Routes
|--------------------------------------------------------------------------
*/

// Simple health check without database
Route::get('/ping', function () {
    return response()->json([
        'status' => 'OK',
        'timestamp' => now(),
        'message' => 'API is running'
    ]);
});

// Database-specific health check
Route::get('/db-health', function () {
    try {
        DB::connection()->getPdo();
        return response()->json([
            'status' => 'OK',
            'database' => 'connected',
            'timestamp' => now()
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'ERROR',
            'database' => 'disconnected',
            'error' => $e->getMessage(),
            'timestamp' => now()
        ], 503);
    }
});
