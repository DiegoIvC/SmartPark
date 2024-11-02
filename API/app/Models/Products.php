<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Jenssegers\Mongodb\Eloquent\Model;

class Products extends Model
{
    use HasFactory;
    protected $connection = 'mongodb';
    protected $collection = 'products';
    protected $fillable = ['name', 'price'];
}
