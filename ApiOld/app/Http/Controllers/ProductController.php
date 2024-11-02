<?php

namespace App\Http\Controllers;

use App\Models\Products;
use http\Env\Response;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function index()
    {
        $products = Products::all();
        return response()->json([
            "result" => $products,
            \Illuminate\Http\Response::HTTP_OK
        ]);
    }


    public function create()
    {

    }


    public function store(Request $request)
    {
        $product = new Products();

        $product->name = $request->name;
        $product->price = $request->price;

//       dd($product,$request);
        $product->save();
        return response()->json([
            'result' => $product,
            \Illuminate\Http\Response::HTTP_CREATED
        ]);
    }


    public function show($id)
    {
        //
    }


    public function edit($id)
    {
        //
    }

    public function update(Request $request, $id)
    {
        $product = Products::findOrFail($request->id);

        $product->name = $request->name;
        $product->price = $request->price;

//       dd($product,$request);
        $product->save();
        return response()->json([
            'result' => $product,
            \Illuminate\Http\Response::HTTP_CREATED
        ]);
    }


    public function destroy($id)
    {
        $product = Products::findOrFail($id);
        $product->delete();
        return response()->json([
            'message' => "Deleted Successfully",
            \Illuminate\Http\Response::HTTP_OK
        ]);
    }
}
