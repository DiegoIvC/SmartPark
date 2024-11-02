<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ProductController;
use \App\Http\Controllers\UserController;
use App\Http\Controllers\AccesoRFIDController;
use \App\Http\Controllers\EspaciosEstacionamientoController;

Route::controller(UserController::class)->group(function () {
    Route::post('/usuarios', [UserController::class, 'store']);
    Route::get('/usuarios', [UserController::class, 'index']);
    Route::get('/usuario/{rfid}', [UserController::class, 'show']);
});

Route::controller(AccesoRFIDController::class)->group(function () {
    Route::get('/accesos_rfid', [AccesoRFIDController::class, 'index']);
    Route::get('/usuarios/{rfid}/accesos', [AccesoRFIDController::class, 'getAccesosPorUsuario']);
    Route::post('/accesos_rfid/in', [AccesoRFIDController::class, 'userIn']);
    Route::put('/accesos_rfid/out/{rfid}', [AccesoRFIDController::class, 'userOut']);
});

Route::controller(EspaciosEstacionamientoController::class)->group(function () {
    Route::post('/espacios', [EspaciosEstacionamientoController::class, 'store']);
    Route::get('/espacios', [EspaciosEstacionamientoController::class, 'index']);
    Route::get('/espacio/{id}', [EspaciosEstacionamientoController::class, 'show']);
    Route::put('/espacio/sensor/', [EspaciosEstacionamientoController::class, 'sensorStatus']);
});




