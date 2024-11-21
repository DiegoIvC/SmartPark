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
        $datosAgrupados = collect($estacion->sensores)->groupBy('tipo');

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

        // Validación de los campos incluyendo la imagen
        $request->validate([
            'nombre' => 'required|string',
            'apellido_paterno' => 'required|string',
            'apellido_materno' => 'required|string',
            'rol' => 'required|string',
            'rfid' => 'required|string|unique:estacion,usuarios.rfid',
            'curp' => 'required|string|unique:estacion,usuarios.curp',
            'departamento' => 'required|string',
            'imagen' => 'nullable|image|mimes:jpeg,png,jpg|max:2048', // Validar la imagen
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

        // Procesar la imagen si se incluye
        $rutaImagen = null;
        if ($request->hasFile('imagen')) {
            $imagen = $request->file('imagen');
            $nombreArchivo = time() . '_' . $imagen->getClientOriginalName();
            $rutaImagen = $imagen->storeAs('public/users/img', $nombreArchivo); // Guardar en storage/app/public/users/img
            $rutaImagen = str_replace('public/', 'storage/', $rutaImagen); // Ajustar la ruta para acceso público
        }

        // Crear el nuevo usuario con la ruta de la imagen
        $nuevoUsuario = $request->only('nombre', 'apellido_paterno', 'apellido_materno', 'rfid', 'curp', 'rol', 'departamento');
        $nuevoUsuario['imagen'] = $rutaImagen; // Agregar la ruta de la imagen

        // Guardar en la colección de usuarios
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
        $datosRF = collect($estacion->sensores)->filter(function ($dato) {
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
                    'imagen' => $usuario['imagen'] ?? 'Sin imagen' // Verificar si existe la imagen
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
        // Encuentra la estación por ID
        $estacion = Estacion::find($id);
        if (!$estacion) {
            return response()->json(['message' => 'Estación no encontrada'], 404);
        }

        // Encuentra al usuario en la estación por su RFID
        $usuario = collect($estacion->usuarios)->firstWhere('rfid', $rfid);
        if (!$usuario) {
            return response()->json(['message' => 'Usuario no encontrado'], 404);
        }

        // Filtra los sensores que sean de tipo RF y coincidan con el RFID del usuario
        $accesos = collect($estacion->sensores)
            ->filter(function ($sensor) use ($rfid) {
                return $sensor['tipo'] === 'RF-01' && $sensor['valor'] === $rfid;
            })
            ->sortByDesc('fecha') // Ordenar por fecha descendente
            ->pluck('fecha'); // Extraer solo las fechas

        // Formatear la respuesta con datos del usuario y accesos
        $respuesta = [
            'usuario' => [
                'nombre' => $usuario['nombre'],
                'apellido_paterno' => $usuario['apellido_paterno'],
                'apellido_materno' => $usuario['apellido_materno'],
                'rfid' => $usuario['rfid'],
                'curp' => $usuario['curp'],
            ],
            'accesos' => $accesos
        ];

        // Devuelve la respuesta en formato JSON
        return response()->json($respuesta);
    }


    // Obtener el dato más reciente de una estación
    public function obtenerDatosNuevos($id)
    {
        $estacion = Estacion::find($id);
        if (!$estacion) {
            return response()->json(['message' => 'Estación no encontrada'], 404);
        }

        $datoMasNuevo = collect($estacion->sensores)->sortByDesc('fecha')->first();

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

    public function obtenerDatosDashboard($id)
    {
        $estacion = Estacion::find($id);
        if (!$estacion) {
            return response()->json(['message' => 'Estación no encontrada'], 404);
        }

        return "hola";
    }

    public function datosFake()
    {
        $data = [
            [
                "tipo" => "LU",
                "horario1" => "2024-11-06 19:10:34",
                "horario2" => "2024-11-07 06:49:28",
                "timepoTotal" => "11 horas, 38 minutos y 54 segundos."
            ],
            [
                "tipo" => "HU",
                "ultima-alarma" => "2024-11-06 19:10:34",
                "duracion" => "0 horas, 4 min y 28 segundos"
            ],
            [
                "tipo" => "RF",
                "ultimo-acceso" => [
                    "nombre" => "Miguel",
                    "apellido_paterno" => "Castro",
                    "apellido_materno" => "Mesta",
                    "rfid" => "9929900",
                    "curp" => "CURP12ss5611",
                    "rol" => "empleado",
                    "departamento" => "Administracion",
                    "imagen" => "ruta/imagen",
                    "fecha" => "2024-11-06 19:10:34"
                ]
            ],
            [
                "tipo" => "IN",
                "espacios" => [
                    "espacio1" => 1,
                    "espacio2" => 2,
                    "espacio3" => 3
                ]
            ]
        ];

        return response()->json($data);
    }
}
