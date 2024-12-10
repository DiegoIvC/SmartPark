//
//  IniciarSesion.swift
//  smartpark
//
//  Created by Luis Fernando Robles Ibarra on 06/12/24.
//

import UIKit

class IniciarSesion: NSObject {
    var username: String
    var password: String
    var autenticado: Bool
    var rol: String
    var rolesPermitidos: [String]
    
    static var iniciarSesionStatic: IniciarSesion!
    
    override init() {
        username = ""
        password = ""
        autenticado = false
        rol = ""
        rolesPermitidos = ["administrador", "soporte"]
    }
    
    static func iniciarSesionShared() -> IniciarSesion {
        if iniciarSesionStatic == nil {
            iniciarSesionStatic = IniciarSesion()
        }
        return iniciarSesionStatic
    }
    
    func login(_ txtNombre: UITextField, _ txtContraseña: UITextField) -> Bool {
        let iniciarSesion = IniciarSesion.iniciarSesionShared()
        let urlSession = URLSession.shared
        guard let url = URL(string: "http://3.147.187.80/api/estacion/673a970b8548904611656030/login/usuario") else { return false }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer zfDzOl3vzfDzOl3vzfDzOl3vzfDzOl3vz", forHTTPHeaderField: "Authorization")
        
        let json = ["username": txtNombre.text!, "password": txtContraseña.text!] as [String : Any]
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        
        request.httpBody = jsonData
        let semaphore = DispatchSemaphore(value: 0)
            
        var result = false
        
        // Realizamos la petición asíncrona
        urlSession.dataTask(with: request) { data, response, error in
            defer {
                // Liberamos el semáforo al terminar
                semaphore.signal()
            }
            
            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("data: \(json)")
                    iniciarSesion.rol = json["rol"] as? String ?? "Sin rol"
                }
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    iniciarSesion.autenticado = true
                    result = true
                } else {
                    iniciarSesion.autenticado = false
                    result = false
                }
            }
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                iniciarSesion.autenticado = false
                result = false
            }
            
        }.resume()
        
        // Esperamos hasta que el semáforo se libere, bloqueando el hilo actual
        _ = semaphore.wait(timeout: .distantFuture)
        
        // Para este punto, la respuesta HTTP ya se ha procesado y result contiene el valor final
        return result
    }
    
    func abrirArchivo() {
        let iniciarSesion = IniciarSesion.iniciarSesionShared()
        let ruta = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/Login.plist"
        let urlArchivo = URL(fileURLWithPath: ruta)
        print("Ruta abrir archivo: \(urlArchivo)")
        
        do {
            let archivo = try Data.init(contentsOf: urlArchivo)
            let diccionario = try PropertyListSerialization.propertyList(from: archivo, options: [], format: nil) as! [String:Any]
            
            iniciarSesion.username = diccionario["username"] as! String
            iniciarSesion.password = diccionario["password"] as! String
            iniciarSesion.autenticado = diccionario["autenticado"] as! Bool
            iniciarSesion.rol = diccionario["rol"] as! String
            print(diccionario)
            
        } catch {
            guardarArchivo()
            abrirArchivo()
        }
    }
    
    func guardarArchivo() {
        let iniciarSesion = IniciarSesion.iniciarSesionShared()
        let ruta = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/Login.plist"
        let urlArchivo = URL(fileURLWithPath: ruta)
        print("Ruta guardar archivo \(urlArchivo)")
        do {
            let diccionario: [String:Any] =
            [
                "username": iniciarSesion.username,
                "password": iniciarSesion.password,
                "autenticado": iniciarSesion.autenticado,
                "rol": iniciarSesion.rol
            ]
            
            let archivo = try PropertyListSerialization.data(fromPropertyList: diccionario, format: .xml, options: NSPropertyListWriteStreamError)
            try archivo.write(to: urlArchivo)
            print("Archivo guardado con éxito")
        } catch {
            print("algo salió mal")
        }
    }
}
