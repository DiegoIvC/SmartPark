<?php

namespace App\Http\Controllers;

use App\Models\EspacioEstacionamiento;
use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function store(Request $request)
    {
        // Validar los datos
        $request->validate([
            'nombre_completo' => 'required|string|max:100',
            'correo_electronico' => 'required|email|unique:usuarios',
            'contrasena_hash' => 'required|string|max:255',
            'rfid' => 'required|string|max:50|unique:usuarios',
            'rol' => 'required|in:empleado,administrador,mantenimiento',
        ]);

        // Crear un nuevo usuario
        $usuario = User::create($request->all());

        return response()->json([
            'message' => 'Usuario creado con éxito',
            'usuario' => $usuario
        ], 201);
    }

    public function index()
    {
        // Obtener todos los usuarios
        $usuarios = User::all();
        return response()->json($usuarios);
    }

    public function show($rfid)
    {
        $usuario = User::where('rfid', $rfid)->first();
        if($usuario){
            return response()->json($usuario);
        }
        else{
            return response()->json([
                'message' => 'Usuario no encontrado'
            ]);
        }
    }
}
