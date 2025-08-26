<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

// Root health check (no /api prefix)
Route::get('/health', function () {
    $response = [
        'status' => 'OK',
        'timestamp' => now(),
        'app' => config('app.name'),
        'env' => config('app.env'),
        'port' => env('PORT', '8000'),
        'url' => env('APP_URL', 'localhost'),
        'route' => 'web'
    ];
    
    // Try database connection but don't fail if unavailable
    try {
        DB::connection()->getPdo();
        $response['database'] = 'connected';
    } catch (\Exception $e) {
        $response['database'] = 'unavailable';
        $response['database_error'] = $e->getMessage();
    }
    
    return response()->json($response);
});

// Simple status endpoint
Route::get('/status', function () {
    return response()->json([
        'status' => 'OK', 
        'timestamp' => now(),
        'route' => 'web'
    ]);
});

// Root endpoint
Route::get('/', function () {
    return response()->json([
        'message' => 'ToolShop API is running!',
        'timestamp' => now(),
        'health_check' => url('/health'),
        'api_health_check' => url('/api/health'),
        'status' => 'OK'
    ]);
});
