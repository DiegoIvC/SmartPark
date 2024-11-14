<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Estacion;

class TodoController extends Controller
{
    public function registrarEstacion(Request $request)
    {
        $request->validate([
            'nombre' => 'required|string',
            'datos' => 'required|array',
            'datos.datos1' => 'array',
            'datos.datos2' => 'array',
            'usuarios' => 'required|array',
            'usuarios.*.nombre' => 'required|string',
            'usuarios.*.apellido_paterno' => 'required|string',
            'usuarios.*.apellido_materno' => 'required|string',
            'usuarios.*.rfid' => 'required|string',
            'usuarios.*.curp' => 'required|string',
            'usuarios.*.accesos' => 'array',
            'usuarios.*.accesos.*.fechaEntrada' => 'date',
        ]);

        // Crear la estación con datos y usuarios
        $estacion = Estacion::create([
            'nombre' => $request->input('nombre'),
            'datos' => $request->input('datos'),
            'usuarios' => $request->input('usuarios'),
        ]);

        return response()->json($estacion, 201); // Código 201 para creación exitosa
    }
}
