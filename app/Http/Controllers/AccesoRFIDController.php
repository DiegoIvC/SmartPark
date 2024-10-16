<?php

namespace App\Http\Controllers;

use App\Models\AccesoRfid;
use App\Models\User;
use Illuminate\Http\Request;

class AccesoRFIDController extends Controller
{
    public function userIn(Request $request)
    {
        $request->validate([
            'rfid_usuario' => 'required|string|max:250'
        ]);
        $rfid = $request->rfid_usuario;

        // Verificar si el usuario con ese RFID existe
        $userExist = User::where('rfid', $rfid)->first();

        if ($userExist) {
            // Registrar el acceso RFID con la referencia al usuario
            $acceso = AccesoRfid::create([
                'rfid_usuario' => $request->rfid_usuario,
                'id_espacio' => $request->id_espacio,
                'usuario_id' => $userExist->_id,  // Guardar el ObjectID del usuario
                'fecha_acceso' => now(),
            ]);
            return response()->json([
                'message' => 'El usuario ' . $userExist->nombre_completo . ' ha entrado al estacionamiento.',
                'acceso' => $acceso
            ], 201);
        } else {
            return response()->json([
                'message' => 'Usuario no encontrado. RFID inválido'
            ]);
        }
    }

    public function userOut($rfid){
        $userExist = User::where('rfid', $rfid)->first();
        if ($userExist) {
            //encontrar el ultimo acceso
            $usuario_id = $userExist->_id;
            $ultimoAcceso = AccesoRFID::where('usuario_id', $usuario_id)
                ->orderBy('fecha_acceso', 'desc')
                ->first(); // Obtener el último acceso
            if ($ultimoAcceso) {
                $ultimoAcceso->update([
                    'fecha_salida' => now(),
                ]);
                return response()->json([
                    'message' => 'El usuario ' . $userExist->nombre_completo . ' ha salido del estacionamiento.',
                    'acceso' => $ultimoAcceso
                ], 201);
            }
            else{
                return response()->json([
                    'message'=> "El usuario ". $userExist->nombre_completo ." no tiene accesos en el sistema. Solicite la apertura de la pluma en caseta"
                ]);
            }
        }
        else{
            return response()->json([
                'message'=> "Usuario no encontrado."
            ]);
        }
    }

    public function index()
    {
        $accesos = AccesoRfid::all();
        return response()->json($accesos);
    }

    public function show($id)
    {
        $acceso = AccesoRfid::with('user')->find($id);

        return response()->json($acceso);
    }

    public function getAccesosPorUsuario($rfid)
    {
        $userExist = User::where('rfid', $rfid)->first();

        if ($userExist) {
            $id = $userExist->_id;
            $accesos = AccesoRfid::where('usuario_id', $id)
                ->orderBy('fecha_acceso', 'desc')
                ->get();

            return response()->json([
                'usuario' => $userExist,
                'accesos' => $accesos
            ], 200);
        }
        else{
            return response()->json([
                'message' => 'Usuario no encontrado'
            ], 404);
        }


    }
}
