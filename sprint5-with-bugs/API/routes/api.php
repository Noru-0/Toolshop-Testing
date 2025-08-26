<?php

use App\Http\Controllers\BrandController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\ContactController;
use App\Http\Controllers\FavoriteController;
use App\Http\Controllers\ImageController;
use App\Http\Controllers\InvoiceController;
use App\Http\Controllers\PaymentController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\ReportController;
use App\Http\Controllers\UserController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
*/

// Root API endpoint
Route::get('/', function () {
    return response()->json([
        'message' => 'ToolShop API is running!',
        'timestamp' => now(),
        'version' => '1.0.0',
        'health_check' => url('/api/health'),
        'status_check' => url('/api/status'),
        'ping' => url('/api/ping'),
        'documentation' => url('/api/documentation'),
        'app' => config('app.name'),
        'env' => config('app.env')
    ]);
});

// Health check endpoint
Route::get('/health', function () {
    try {
        // Test database connection
        DB::connection()->getPdo();
        $dbStatus = 'connected';
    } catch (\Exception $e) {
        $dbStatus = 'disconnected: ' . $e->getMessage();
    }
    
    return response()->json([
        'status' => 'OK',
        'timestamp' => now(),
        'database' => $dbStatus,
        'app' => config('app.name'),
        'env' => config('app.env'),
        'port' => env('PORT', '8000'),
        'url' => env('APP_URL', 'localhost')
    ]);
});

// Simple ping endpoint (no database required)
Route::get('/ping', function () {
    return response()->json([
        'status' => 'OK',
        'timestamp' => now(),
        'message' => 'API is running',
        'app' => config('app.name'),
        'env' => config('app.env')
    ]);
});

// Status endpoint (simpler version)
Route::get('/status', function () {
    return response()->json([
        'version' => config('app.version'), 
        'environment' => env('APP_ENV'), 
        'app_name' => env('APP_NAME'),
        'timestamp' => now()
    ], 200, ['Content-Type' => 'application/json;charset=UTF-8', 'Charset' => 'utf-8'], JSON_UNESCAPED_UNICODE);
});

Route::get('/logs/laravel.log', function () {
    $logPath = storage_path('logs/laravel.log');

    if (File::exists($logPath)) {
        $logContents = File::get($logPath);
    } else {
        $logContents = 'Log file not found.';
    }

    return nl2br(e($logContents));
});

Route::controller(BrandController::class)->prefix('brands')->group(function () {
    Route::get('', 'index');
    Route::get('/search', 'search');
    Route::get('/{id}', 'show');
    Route::post('', 'store');
    Route::put('/{id}', 'update');
    Route::delete('/{id}', 'destroy');
});

Route::controller(CategoryController::class)->prefix('categories')->group(function () {
    Route::get('/tree', 'indexTree');
    Route::get('', 'index');
    Route::get('/search', 'search');
    Route::get('/{id}', 'show');
    Route::post('', 'store');
    Route::put('/{id}', 'update');
    Route::delete('/{id}', 'destroy');
});

Route::controller(ContactController::class)->prefix('messages')->group(function () {
    Route::post('', 'send');
    Route::post('/{id}/attach-file', 'attachFile');
    Route::get('', 'index');
    Route::get('/{id}', 'show');
    Route::post('/{id}/reply', 'storeReply');
    Route::put('/{id}/status', 'updateStatus');
});

Route::controller(FavoriteController::class)->prefix('favorites')->group(function () {
    Route::get('', 'index');
    Route::post('', 'store');
    Route::get('/{id}', 'show');
    Route::delete('/{id}', 'destroy');
});

Route::controller(ImageController::class)->prefix('images')->group(function () {
    Route::get('', 'index');
});

Route::controller(InvoiceController::class)->prefix('invoices')->group(function () {
    Route::get('', 'index');
    Route::get('/search', 'search');
    Route::get('/{id}', 'show');
    Route::put('/{id}/status', 'updateStatus');
    Route::post('', 'store');
    Route::put('/{id}', 'update');
});

Route::controller(PaymentController::class)->prefix('payment')->group(function () {
    Route::post('/check', 'check');
});

Route::controller(ProductController::class)->prefix('products')->group(function () {
    Route::get('', 'index');
    Route::get('/search', 'search');
    Route::get('/{id}', 'show');
    Route::get('/{id}/related', 'showRelated');
    Route::post('', 'store');
    Route::put('/{id}', 'update');
    Route::delete('/{id}', 'destroy');
});

Route::controller(ReportController::class)->prefix('reports')->group(function () {
    Route::get('/total-sales-of-years', 'totalSalesOfYears');
    Route::get('/total-sales-per-country', 'totalSalesPerCountry');
    Route::get('/top10-purchased-products', 'top10PurchasedProducts');
    Route::get('/top10-best-selling-categories', 'top10BestSellingCategories');
    Route::get('/customers-by-country', 'customersByCountry');
    Route::get('/average-sales-per-month', 'averageSalesPerMonth');
    Route::get('/average-sales-per-week', 'averageSalesPerWeek');
});

Route::controller(UserController::class)->prefix('users')->group(function () {
    Route::post('/login', 'login');
    Route::post('/change-password', 'changePassword');
    Route::post('/forgot-password', 'forgotPassword');
    Route::post('/register', 'store');
    Route::get('/logout', 'logout');
    Route::get('/search', 'search');
    Route::get('/refresh', 'refresh');
    Route::get('/me', 'me');
    Route::put('{id}', 'update');
    Route::get('/', 'index');
    Route::get('/{id}', 'show');
    Route::delete('/{id}', 'destroy');
});

