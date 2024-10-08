<?php

namespace App\Http\Controllers;

use App\Models\AccesoRFID;
use App\Models\EspacioEstacionamiento;
use App\Models\User;
use Illuminate\Http\Request;

class EspaciosEstacionamientoController extends Controller
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

    public function show($id)
    {
        $espacio = EspacioEstacionamiento::find($id);
        if(!$espacio){
            return response()->json([
                'message' => 'Epacio no encontrado'
            ]);
        }
        else{
            return response()->json($espacio);
        }
    }

    public function sensorStatus(Request $request, $id){
        $request->validate([
            'distancia' => 'required|numeric'
        ]);
        //Recibir el id del sensor y buscar el espacio de estacionamiento en el que está localizado el sensor
        $id = (int) $id;
        $espacio = EspacioEstacionamiento::where('id_sensor', $id)->first();
//        dd($espacio);
        if($espacio){
            //NOTA, EL SENSOR ULTRASONICO RETORNA LA DISTANCIA EN CM
            //POR LO QUE SE RECIBE LA DISTANCIA Y SE COMPARA
            $distancia = $request->input('distancia');
            if ($distancia >= 0 && $distancia <= 5) {
                $estatus = 1; // Ocupado
            } elseif ($distancia >= 6 && $distancia <= 10) {
                $estatus = 2; // En espera
            } else {
                $estatus = 0; // Libre
            }
            $espacio->estatus = $estatus;
            $espacio->save();
            return response()->json([
                'message' => 'Estatus actualizado correctamente',
                'espacio' => $espacio
            ], 200);
        }
        else{
            return response()->json([
                'message' => 'El sensor no existe o no tiene un espacio asignado'
            ]);
        }
    }

}
