<?php

namespace App\Models;

use Jenssegers\Mongodb\Eloquent\Model as Eloquent;


class AccesoRFID extends Eloquent
{
    protected $collection = 'accesos_rfid'; // Nombre de la colección
    protected $connection = 'mongodb';

    protected $fillable = [
        'rfid_usuario',
        'fecha_acceso',
        'fecha_salida',
        'usuario_id',
    ];

    protected $dates = ['fecha_acceso','fecha_salida'];

    public function user()
    {
        return $this->belongsTo(User::class, 'usuario_id', '_id');
    }
}
