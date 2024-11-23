<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Estacion;
use Illuminate\Support\Carbon;
use Illuminate\Tests\Database\EloquentRelationshipsTest\Car;

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

    public function obtenerDatosLuxometro($id)
    {
        // Encuentra la estación por ID
        $estacion = Estacion::find($id);

        if (!$estacion) {
            return [
                'error' => 'Estación no encontrada'
            ];
        }

        // Verifica que sensores sea un arreglo o colección
        if (!is_array($estacion->sensores) && !($estacion->sensores instanceof \Illuminate\Support\Collection)) {
            return [
                'error' => 'Los sensores no tienen un formato válido'
            ];
        }

        // Filtra los sensores que sean de tipo LU-01
        $sensoresLU = collect($estacion->sensores)->filter(function ($sensor) {
            return isset($sensor['tipo']) && $sensor['tipo'] === 'LU-1';
        });

        if ($sensoresLU->isEmpty()) {
            return [
                'error' => 'No se encontraron sensores de tipo LU-1'
            ];
        }

        // Encuentra el dato más nuevo con valor "1"
        $dato1 = $sensoresLU->where('valor', '1')->sortByDesc('fecha')->first();
        // Encuentra el dato más nuevo con valor "0"
        $dato0 = $sensoresLU->where('valor', '0')->sortByDesc('fecha')->first();

        if (!$dato1 || !$dato0) {
            return [
                'error' => 'No se encontraron datos de tipo LU-1 con valores 1 y 0'
            ];
        }

        // Convierte las fechas a objetos Carbon
        try {
            $fecha1 = Carbon::parse($dato1['fecha']);
            $fecha0 = Carbon::parse($dato0['fecha']);
        } catch (\Exception $e) {
            return [
                'error' => 'Las fechas no tienen un formato válido'
            ];
        }

        // Verifica si la fecha del valor 0 es anterior a la del valor 1
        if ($fecha0->lessThan($fecha1)) {
            return [
                'error' => 'Horario de luz en curso'
            ];
        }

        // Calcula la diferencia entre las fechas
        $diferencia = $fecha1->diff($fecha0);

        // Formatea el tiempo transcurrido
        $tiempoTotal = $diferencia->format('%h horas, %i minutos y %s segundos');

        // Retorna las propiedades directamente
        return [
            'tipo' => 'LU',
            'horariodelValor1' => $fecha1->toDateTimeString(),
            'horariodelValor0' => $fecha0->toDateTimeString(),
            'tiempoTotal' => $tiempoTotal,
        ];
    }

    public function obtenerDatosAlarma($id)
    {
        $estacion = Estacion::find($id);

        if (!$estacion) {
            return [
                'error' => 'Estación no encontrada'
            ];
        }

// Verifica que actuadores sea un arreglo o colección
        if (!is_array($estacion->actuadores) && !($estacion->actuadores instanceof \Illuminate\Support\Collection)) {
            return [
                'error' => 'Los actuadores no tienen un formato válido'
            ];
        }

// Filtra todos los actuadores cuyo tipo comience con 'AL'
        $actuadoresAL = collect($estacion->actuadores)->filter(function ($actuador) {
            return isset($actuador['tipo']) && str_starts_with($actuador['tipo'], 'AL');
        });

// Si no se encuentran actuadores de tipo 'AL', retorna un mensaje
        if ($actuadoresAL->isEmpty()) {
            return [
                'message' => 'No se encontraron actuadores de tipo AL'
            ];
        }

// Encuentra la alarma con la fecha más reciente
        $alarmaReciente = $actuadoresAL->sortByDesc('fecha')->first();

// Verifica si existe una fecha en la alarma
        if (!isset($alarmaReciente['fecha'])) {
            return [
                'message' => 'No se encontró una fecha válida para la última alarma'
            ];
        }

// Retorna el tipo y la fecha de la última alarma
        return [
            'tipo' => 'HU',
            'ultima-alarma' => $alarmaReciente['fecha']
        ];
    }

    public function apagarAlarma(Request $request, $id)
    {
        // Encuentra la estación por ID
        $estacion = Estacion::find($id);

        if (!$estacion) {
            return response()->json([
                'error' => 'Estación no encontrada'
            ], 404);
        }

        // Verifica que actuadores sea un arreglo o colección
        if (!is_array($estacion->actuadores) && !($estacion->actuadores instanceof \Illuminate\Support\Collection)) {
            return response()->json([
                'error' => 'Los actuadores no tienen un formato válido'
            ], 400);
        }

        // Validar que se envió la fecha
        $request->validate([
            'fecha' => 'required|date'
        ]);

        $fecha = $request->input('fecha');

        // Hacer una copia del arreglo actuadores
        $actuadores = $estacion->actuadores;

        // Actualizar los datos de los actuadores en la copia
        foreach ($actuadores as &$actuador) {
            if (str_starts_with($actuador['tipo'], 'AL')) {
                $actuador['fecha'] = $fecha;
                $actuador['valor'] = 0;
            }
        }

        // Asignar la copia actualizada de nuevo al modelo
        $estacion->actuadores = $actuadores;
        $estacion->save(); // Guardar cambios en la base de datos

        // Retorna la respuesta con los datos actualizados
        return response()->json([
            'message' => 'Alarmas actualizadas correctamente',
            'fecha' => $fecha,
            'actuadoresActualizados' => collect($actuadores)
                ->filter(fn($actuador) => str_starts_with($actuador['tipo'], 'AL'))
                ->values()
        ]);
    }
    public function obtenerDatosRFID($id)
    {
        // Buscar la estación por ID
        $estacion = Estacion::find($id);
        if (!$estacion) {
            return 'Estación no encontrada'; // Retornar mensaje simple
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
                    'tipo'=> 'RF-1',
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
        })->filter(); // Filtrar usuarios nulos

        // Ordenar los resultados por fecha descendente y obtener el más reciente
        $usuarioMasReciente = $usuariosRF->sortByDesc('fecha')->first();

        // Si no se encuentra ningún usuario, retornar un mensaje simple
        if (!$usuarioMasReciente) {
            return 'No se encontraron usuarios con RFID en la estación';
        }

        // Retornar el registro más reciente como propiedades
        return $usuarioMasReciente;
    }

    public function obtenerDatosParking($id)
    {
        $estacion = Estacion::find($id);
        if (!$estacion) {
            return 'Estación no encontrada'; // Retornar mensaje simple
        }

        // Filtra los datos para obtener solo los que comienzan con "IN"
        $datosIN = collect($estacion)->filter(function ($item) {
            return isset($item['tipo']) && strpos($item['tipo'], 'IN') === 0;
        });

        // Crear la estructura solicitada
        $espacios = [];

        // Recorremos los datos filtrados
        $datosIN->each(function ($item, $index) use (&$espacios) {
            // Aseguramos que el valor de cada espacio sea un número entero
            $valor = isset($item['valor']) ? (int) $item['valor'] : 0;

            // Construimos la clave dinámica y asignamos el valor correspondiente
            $espacios['IN-' . ($index + 1)] = [
                'valor' => $valor
            ];
        });

        // Si faltan espacios (en caso de que no haya suficientes datos 'IN')
        for ($i = count($espacios); $i < 3; $i++) {
            $espacios['IN-' . ($i + 1)] = ['valor' => 0];  // Asignar 0 si no hay datos disponibles para ese espacio
        }

        // Construir la respuesta final
        $respuesta = [
            'tipo' => 'IN',
            'espacios' => $espacios,
        ];
        return $respuesta;
    }
    public function obtenerDatosDashboard($id)
    {

        $luxometro = $this->obtenerDatosLuxometro($id);
        $alarma = $this->obtenerDatosAlarma($id);
        $ultimo_acceso=$this->obtenerDatosRFID($id);
        $estacionamiento = $this->obtenerDatosParking($id);
        // Si se obtiene el mensaje de error de la estación no encontrada, devuelvelo como respuesta
        if (isset($luxometro['message'])) {
            return response()->json($luxometro, 404); // Devuelve un error 404 con el mensaje de error
        }
        if (isset($alarma['message'])) {
            return response()->json($alarma, 404); // Devuelve un error 404 con el mensaje de error
        }
        if(isset($ultimo_acceso['message'])){
            return response()->json($ultimo_acceso, 404);
        }
        if (isset($estacionamiento['message'])) {
            return response()->json($estacionamiento, 404);
        }

        //return response()->json($luxometro);
        //return response()->json($alarma);
        return response()->json([
            $luxometro,
            $alarma,
            $ultimo_acceso,
            $estacionamiento
        ]);
    }

    public function obtenerRfidLector($id)
    {
        // Encuentra la estación por ID
        $estacion = Estacion::find($id);

        if (!$estacion) {
            return [
                'error' => 'Estación no encontrada'
            ];
        }

        // Verifica que sensores sea un arreglo o colección
        if (!is_array($estacion->sensores) && !($estacion->sensores instanceof \Illuminate\Support\Collection)) {
            return [
                'error' => 'Los sensores no tienen un formato válido'
            ];
        }

        // Filtra los sensores que sean de tipo RF-2
        $lectorRF = collect($estacion->sensores)->first(function ($sensor) {
            return isset($sensor['tipo']) && $sensor['tipo'] === 'RF-2';
        });

        if (!$lectorRF) {
            return [
                'error' => 'No se encontraron sensores de tipo RF-2'
            ];
        }

        // Devuelve el formato deseado
        return [
            'lector' => [
                'valor' => $lectorRF['valor'],
                'fecha' => $lectorRF['fecha'],
            ]
        ];
    }

    public function obtenerDatosCamaras($id)
    {
        // Encuentra la estación por ID
        $estacion = Estacion::find($id);

        if (!$estacion) {
            return [
                'error' => 'Estación no encontrada'
            ];
        }

        // Verifica que actuadores sea un arreglo o colección
        if (!is_array($estacion->actuadores) && !($estacion->actuadores instanceof \Illuminate\Support\Collection)) {
            return [
                'error' => 'Los actuadores no tienen un formato válido'
            ];
        }

        // Filtra los actuadores que sean de tipo CA-1
        $datosCA = collect($estacion->actuadores)->filter(function ($actuador) {
            return isset($actuador['tipo']) && $actuador['tipo'] === 'CA-1';
        });

        if ($datosCA->isEmpty()) {
            return [
                'error' => 'No se encontraron actuadores de tipo CA-1'
            ];
        }

        // Formatear los datos para la respuesta
        $resultado = $datosCA->map(function ($actuador) {
            return [
                'imagen' => $actuador['valor'],
                'velocidad' => $actuador['velocidad'] ?? null,
                'fecha' => $actuador['fecha'],
            ];
        });

        return [
            'CA-1' => $resultado->values()
        ];
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
