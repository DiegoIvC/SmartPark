<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ProductController;
use \App\Http\Controllers\UserController;
use App\Http\Controllers\AccesoRFIDController;
use \App\Http\Controllers\EspaciosEstacionamientoController;
use App\Http\Controllers\TodoController;
use App\Http\Controllers\EstacionController;

Route::controller(UserController::class)->group(function () {

});

Route::controller(AccesoRFIDController::class)->group(function () {

});

Route::controller(EspaciosEstacionamientoController::class)->group(function () {

});

Route::controller(EstacionController::class)->group(function () {

    //ESTACION
    Route::get('/estacion/{id}','obtenerEstacion');
    Route::get('/estacion/{id}/datos', 'obtenerDatosEstacion');
        //USUARIOS
        Route::post('/estacion/{id}/usuario','agregarUsuario');
        Route::get('/estacion/{id}/usuario/{rfid}', 'obtenerUsuario');
        //ACCESOS
        Route::get('/estacion/{id}/accesos', 'obtenerAccesosTodosUsuarios');
        Route::get('/estacion/{id}/usuario/{rfid}/accesos', 'obtenerAccesosUsuario');
        //DATOS
        Route::get('/datos-fake','datosFake');
        Route::get('/estacion/{id}/datos/nuevos', 'obtenerDatosNuevos');
            //ESTACIONAMIENTO
            Route::get('/estacion/{id}/datos/estacionamiento', 'obtenerDatosEstacionamiento');

});



