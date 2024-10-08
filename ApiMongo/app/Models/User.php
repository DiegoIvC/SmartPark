<?php

namespace App\Models;

use Jenssegers\Mongodb\Eloquent\Model as Eloquent;

class User extends Eloquent
{
    protected $collection = 'usuarios';
    protected $connection = 'mongodb';

    protected $fillable = [
        'nombre_completo',
        'correo_electronico',
        'contrasena_hash',
        'rfid',
        'rol',
    ];

    protected $casts = [
        'rol' => 'string',
    ];
}
