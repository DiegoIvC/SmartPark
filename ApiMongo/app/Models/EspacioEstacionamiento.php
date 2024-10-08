<?php

namespace App\Models;

use Jenssegers\Mongodb\Eloquent\Model as Eloquent;

class EspacioEstacionamiento extends Eloquent
{
    protected $collection = 'espacios_estacionamiento'; // Nombre de la colección
    protected $connection = 'mongodb';

    protected $fillable = [
        'numero_espacio',
        'estatus',
        'id_sensor',
    ];

}
