<?php

namespace App\Http\Controllers;

use App\Models\AccesoRFID;
use App\Models\EspacioEstacionamiento;
use App\Models\User;
use Illuminate\Http\Request;

class EspaciosEstacionamientoController2 extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'numero_espacio' => 'required|string|max:50',
            'estatus' => 'required|integer',
            'id_sensor' => 'required|integer',
        ]);

        $espacio = EspacioEstacionamiento::create([
            'numero_espacio' => $request->numero_espacio,
            'estatus' => $request->estatus,
            'id_sensor' => $request->id_sensor,
        ]);

        return response()->json([
            'message' => 'Epacio registrado con exito!',
            'espacio estacionamiento' => $espacio
        ], 201);
    }

    public function index()
    {
        $espacios = EspacioEstacionamiento::all();
        return response()->json($espacios);
    }

    public function show($rfid)
    {
        $usuario = User::where('numero_tarjeta_rfid', $rfid)->first();

        return response()->json($espacio);
    }

    public function getEspaciosPorUsuario($rfid_usuario)
    {
        // Buscar el usuario por su rfid
        $usuario = User::where('numero_tarjeta_rfid', $rfid_usuario)->first();

        // Verificar si el usuario existe
        if (!$usuario) {
            return response()->json([
                'message' => 'El usuario no existe'
            ], 404);
        }

        // Buscar todos los espacios de estacionamiento donde el usuario está asignado
        $espacios = EspacioEstacionamiento::where('usuario_id', $usuario->_id)->get();

        // Verificar si se encontraron espacios
        if ($espacios->isEmpty()) {
            return response()->json([
                'message' => 'No se encontraron espacios de estacionamiento para el usuario',
                'usuario' => $usuario
            ], 404);
        }

        // Retornar respuesta exitosa con los espacios encontrados
        return response()->json([
            'usuario' => $usuario,
            'espacio' => $espacios
        ], 200);
    }

    public function userIngress(Request $request, $id)
    {
        // Buscar el usuario por su rfid
        $usuario = User::where('numero_tarjeta_rfid', $request->usuario_id)->first();

        $request->validate([
            'numero_espacio' => 'required|string|max:50',
            'estatus' => 'required|integer',
            'id_sensor' => 'required|integer',
        ]);

        $espacio = EspacioEstacionamiento::find($id);

        if (!$espacio) {
            return response()->json([
                'message' => 'El espacio no existe'
            ], 404);
        }

        $espacio->update([
            'numero_espacio' => $request->numero_espacio,
            'estatus' => $request->estatus,
            'id_sensor' => $request->id_sensor,
            'usuario_id' => $request->usuario_id,
        ]);

        dd($request->all());
//        $rfid_usuario = $request->usuario_id;
//        $usuario = User::where('numero_tarjeta_rfid', $rfid_usuario)->first();
//        return response()->json([
//            'message' => 'El el usuario '.$usuario->nombre_completo  .' ingresó al espacio: '.$espacio->numero_espacio ,
//            'espacio' => $espacio
//        ], 200);
    }
}
