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
            'rfid' => 'required|string|unique:estacion,usuarios.rfid',
            'curp' => 'required|string|unique:estacion,usuarios.curp',
        ]);

        $nuevoUsuario = $request->only('nombre', 'apellido_paterno', 'apellido_materno', 'rfid', 'curp');
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
        $estacion = Estacion::find($id);
        if (!$estacion) {
            return response()->json(['message' => 'Estación no encontrada'], 404);
        }

        $usuariosConAcceso = collect($estacion->datos)->map(function ($usuario) {
            $ultimoAcceso = collect($usuario['accesos'])->sortByDesc('fecha')->first();
            return [
                'nombre' => $usuario['nombre'],
                'apellido_paterno' => $usuario['apellido_paterno'],
                'apellido_materno' => $usuario['apellido_materno'],
                'rfid' => $usuario['rfid'],
                'curp' => $usuario['curp'],
                'ultimo_acceso' => $ultimoAcceso ? $ultimoAcceso['fecha'] : null,
            ];
        })->filter(fn($usuario) => $usuario['ultimo_acceso'] !== null)
            ->sortByDesc('ultimo_acceso')
            ->values();

        return response()->json($usuariosConAcceso);
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
