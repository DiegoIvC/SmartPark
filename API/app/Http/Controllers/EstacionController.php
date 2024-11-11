<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Estacion;

class EstacionController extends Controller
{
    // 1. Registrar una nueva estación
    public function registrarEstacion(Request $request)
    {
        $request->validate([
            'nombre' => 'required|string',
            'datos' => 'array',
            'usuarios' => 'array',
        ]);

        $estacion = Estacion::create([
            'nombre' => $request->input('nombre'),
            'datos' => $request->input('datos', []),
            'usuarios' => $request->input('usuarios', []),
        ]);

        return response()->json($estacion, 201);
    }

    // 2. Obtener los datos de un usuario específico por RFID
    public function obtenerUsuario($estacionId, $usuarioRfid)
    {
        $estacion = Estacion::find($estacionId);
        if (!$estacion) {
            return response()->json(['message' => 'Estación no encontrada'], 404);
        }

        $usuario = collect($estacion->usuarios)->firstWhere('rfid', $usuarioRfid);

        return $usuario
            ? response()->json($usuario)
            : response()->json(['message' => 'Usuario no encontrado'], 404);
    }

    public function obtenerAccesosTodosUsuarios($id)
    {
        // Buscar la estación por ID
        $estacion = Estacion::find($id);
        if (!$estacion) {
            return response()->json(['message' => 'Estación no encontrada'], 404);
        }

        // Filtrar y procesar los datos de los usuarios
        $usuariosConUltimoAcceso = collect($estacion->usuarios)->map(function ($usuario) {
            // Ordenar los accesos por fecha de entrada de más reciente a más antiguo
            $ultimoAcceso = collect($usuario['accesos'])->sortByDesc('fechaEntrada')->first();

            return [
                'nombre' => $usuario['nombre'],
                'apellido_paterno' => $usuario['apellido_paterno'],
                'apellido_materno' => $usuario['apellido_materno'],
                'rfid' => $usuario['rfid'],
                'curp' => $usuario['curp'],
                'fecha_entrada' => $ultimoAcceso ? $ultimoAcceso['fechaEntrada'] : null,
            ];
        })
            ->filter(fn($usuario) => $usuario['fecha_entrada'] !== null) // Filtrar usuarios sin fecha de entrada
            ->sortByDesc('fecha_entrada') // Ordena usuarios por fecha de acceso más reciente
            ->values(); // Reindexa la colección

        return response()->json($usuariosConUltimoAcceso);
    }

    // 4. Obtener los accesos de un usuario específico por RFID
    public function obtenerAccesosUsuario($estacionId, $usuarioRfid)
    {
        // Buscar la estación por ID
        $estacion = Estacion::find($estacionId);
        if (!$estacion) {
            return response()->json(['message' => 'Estación no encontrada'], 404);
        }

        // Buscar el usuario por RFID
        $usuario = collect($estacion->usuarios)->firstWhere('rfid', $usuarioRfid);
        if (!$usuario) {
            return response()->json(['message' => 'Usuario no encontrado'], 404);
        }

        // Ordenar los accesos del usuario por fecha de entrada, de más reciente a más antigua
        $accesosOrdenados = collect($usuario['accesos'])->sortByDesc('fechaEntrada')->values();

        return response()->json($accesosOrdenados);
    }


    // 5. Obtener los datos de la estación
    public function obtenerDatosEstacion($id)
    {
        $estacion = Estacion::find($id);
        if (!$estacion) {
            return response()->json(['message' => 'Estación no encontrada'], 404);
        }

        // Ordenar los datos de la estación del más nuevo al más viejo
        $datosOrdenados = collect($estacion->datos)->sortByDesc('fecha')->values();

        return response()->json($datosOrdenados);
    }

    public function obtenerDatosNuevos($id){
        $estacion = Estacion::find($id);
        if (!$estacion) {
            return response()->json(['message' => 'Estación no encontrada'], 404);
        }

        // Ordenar los datos de la estación por fecha descendente (más nuevo primero) y obtener solo el más reciente
        $datoMasNuevo = collect($estacion->datos)->sortByDesc('fecha')->first();

        return response()->json($datoMasNuevo);
    }

    public function obtenerDatosEstacionamiento($id)
    {
        // Buscar la estación por ID usando Jenssegers MongoDB
        $estacion = Estacion::find($id);
        if (!$estacion) {
            return response()->json(['message' => 'Estación no encontrada'], 404);
        }

        // Ordenar los datos por fecha descendente y obtener solo el dato más reciente
        $datoMasNuevo = collect($estacion->datos)->sortByDesc('fecha')->first();

        // Filtrar solo los campos que comienzan con "IN" y determinar su estado
        $estadoIN = [];
        foreach ($datoMasNuevo as $key => $valor) {
            if (strpos($key, 'IN') === 0) {
                $estado = $valor == 1 ? 1 : 0; // Estado: 1 = ocupado, 0 = libre
                $estadoIN[$key] = [
                    'valor' => $valor,
                    'estado' => $estado
                ];
            }
        }

        // Retornar el JSON con cada dato "IN" y su estado
        return response()->json($estadoIN);
    }
}
