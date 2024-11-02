<?php

namespace App\Http\Controllers;

use App\Models\EspacioEstacionamiento;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class UserController extends Controller
{
    public function store(Request $request)
    {
        // Validar los datos
        $request->validate([
            'nombre' => 'required|string|max:100',
            'apellido_paterno' => 'required|string|max:100',
            'apellido_materno' => 'required|string|max:100',
            'curp' => 'required|string|max:18',
            'rfid'=> 'required|string|max:50|unique:usuarios',
            'rol'=> 'required|in:empleado,administrador,mantenimiento',
            'departamento'=> 'nullable',
            'correo_electronico' => 'required|email|unique:usuarios',
            'contrasena_hash' => 'required|string|max:255',
            'imagen'=>'required|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
        ]);

        $usuario = User::create($request->all());
        $path = $request->file('imagen')->store('public'); // Guarda la imagen en la carpeta pública
        $usuario->imagen = Storage::url($path); // Guarda la URL accesible
        $usuario->save(); // Asegúrate de guardar los cambios

        return response()->json([
            'message' => 'Usuario creado con éxito',
            'usuario' => $usuario
        ], 201);
    }

    public function index()
    {
        // Obtener todos los usuarios
        $usuarios = User::all()->map(function ($usuario) {
            $usuario->imagen = Storage::url($usuario->imagen); // Genera la URL solo aquí
            return $usuario;
        });

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
