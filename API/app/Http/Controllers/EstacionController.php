<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Estacion;

class EstacionController extends Controller
{
  /*  // Obtener una estación por ID
    public function obtenerEstacion($id)
    {
        $estacion = Estacion::find($id);
        if (!$estacion) {
            return response()->json(['message' => 'Estación no encontrada'], 404);
        }

        return response()->json($estacion);
    }*/

    // Obtener los datos de una estación
    public function obtenerDatosEstacion($id)
    {
        $estacion = Estacion::find($id);
        if (!$estacion) {
            return response()->json(['message' => 'Estación no encontrada'], 404);
        }

        // Agrupa los datos por tipo de sensor
        $datosAgrupados = collect($estacion->datos)->groupBy('tipo');

        // Obtiene el último dato para cada tipo de sensor
        $ultimosDatos = $datosAgrupados->map(function ($items) {
            return $items->sortByDesc('fecha')->first();
        });

        // Retorna los datos como un array simple para trabajar con json_decode
        return response()->json($ultimosDatos);
    }


    // Agregar un nuevo usuario a una estación
    public function agregarUsuario(Request $request, $id)
    {
        $estacion = Estacion::find($id);
        if (!$estacion) {
            return response()->json(['message' => 'Estación no encontrada'], 404);
        }

        $request->validate([
            'nombre' => 'required|string',
            'apellido_paterno' => 'required|string',
            'apellido_materno' => 'required|string',
            'rol'=>'required|string',
            'rfid' => 'required|string|unique:estacion,usuarios.rfid',
            'curp' => 'required|string|unique:estacion,usuarios.curp',
            'departamento' => 'required|string',
        ]);

        // Validar unicidad de RFID y CURP dentro del array de usuarios
        $usuarios = collect($estacion->usuarios);

        $existeRfid = $usuarios->contains('rfid', $request->rfid);
        $existeCurp = $usuarios->contains('curp', $request->curp);

        if ($existeRfid) {
            return response()->json(['message' => 'El RFID ya está registrado.'], 422);
        }

        if ($existeCurp) {
            return response()->json(['message' => 'El CURP ya está registrado.'], 422);
        }

        $nuevoUsuario = $request->only('nombre', 'apellido_paterno', 'apellido_materno', 'rfid', 'curp','rol','departamento');
        $estacion->push('usuarios', $nuevoUsuario);

        return response()->json($nuevoUsuario, 201);
    }

    // Obtener un usuario específico por RFID en una estación
    public function obtenerUsuario($id, $rfid)
    {
        $estacion = Estacion::find($id);
        if (!$estacion) {
            return response()->json(['message' => 'Estación no encontrada'], 404);
        }

        $usuario = collect($estacion->usuarios)->firstWhere('rfid', $rfid);

        return $usuario
            ? response()->json($usuario)
            : response()->json(['message' => 'Usuario no encontrado'], 404);
    }
    // Obtener accesos de todos los usuarios en una estación
    public function obtenerAccesosTodosUsuarios($id)
    {
        // Buscar la estación por ID
        $estacion = Estacion::find($id);
        if (!$estacion) {
            return response()->json(['message' => 'Estación no encontrada'], 404);
        }

        // Filtrar los datos de tipo "RF" de la estación
        $datosRF = collect($estacion->datos)->filter(function ($dato) {
            return strpos($dato['tipo'], 'RF') === 0; // Filtra todos los tipos que comienzan con "RF"
        });

        // Obtener los usuarios correspondientes a los RFIDs encontrados
        $usuariosRF = $datosRF->map(function ($dato) use ($estacion) {
            $rfid = $dato['valor'];

            // Buscar el usuario con ese RFID
            $usuario = collect($estacion->usuarios)->firstWhere('rfid', $rfid);

            // Si se encuentra un usuario, devolver su información completa junto con la fecha y departamento
            if ($usuario) {
                return [
                    'nombre' => $usuario['nombre'],
                    'apellido_paterno' => $usuario['apellido_paterno'],
                    'apellido_materno' => $usuario['apellido_materno'],
                    'rfid' => $usuario['rfid'],
                    'curp' => $usuario['curp'],
                    'fecha' => $dato['fecha'], // Agregar la fecha del dato
                    'departamento' => $usuario['departamento'] ?? 'Sin departamento', // Verificar si existe el departamento
                ];
            }
        })->filter()->values(); // Filtrar usuarios nulos y reindexar la colección

        // Ordenar los resultados por fecha descendente
        $usuariosRFOrdenados = $usuariosRF->sortByDesc('fecha')->values();

        return response()->json($usuariosRFOrdenados);
    }


    // Obtener accesos de un usuario específico por RFID en una estación
    public function obtenerAccesosUsuario($id, $rfid)
    {
        $estacion = Estacion::find($id);
        if (!$estacion) {
            return response()->json(['message' => 'Estación no encontrada'], 404);
        }

        $usuario = collect($estacion->usuarios)->firstWhere('rfid', $rfid);
        if (!$usuario) {
            return response()->json(['message' => 'Usuario no encontrado'], 404);
        }

        $accesosOrdenados = collect($usuario['accesos'])->sortByDesc('fecha')->values();

        return response()->json($accesosOrdenados);
    }

    // Obtener el dato más reciente de una estación
    public function obtenerDatosNuevos($id)
    {
        $estacion = Estacion::find($id);
        if (!$estacion) {
            return response()->json(['message' => 'Estación no encontrada'], 404);
        }

        $datoMasNuevo = collect($estacion->datos)->sortByDesc('fecha')->first();

        return response()->json($datoMasNuevo);
    }

    // Obtener datos del estacionamiento (solo los registros "IN" y su estado)
    public function obtenerDatosEstacionamiento($id)
    {
        // Obtenemos los datos de la estación
        $datos = json_decode($this->obtenerDatosEstacion($id)->getContent(), true);

        // Filtra los datos para obtener solo los que comienzan con "IN"
        $datosIN = collect($datos)->filter(function ($item) {
            return isset($item['tipo']) && strpos($item['tipo'], 'IN') === 0;
        });

        // Retorna los datos filtrados
        return response()->json($datosIN->values());
    }
}
