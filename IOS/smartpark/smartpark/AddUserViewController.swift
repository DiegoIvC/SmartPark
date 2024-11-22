import UIKit

class AddUserViewController: UIViewController {
    
    @IBOutlet weak var rfid: UITextField!
    @IBOutlet weak var nombre: UITextField!
    @IBOutlet weak var rol: UISegmentedControl!
    @IBOutlet weak var apellido_paterno: UITextField!
    @IBOutlet weak var departamento: UITextField!
    @IBOutlet weak var curp: UITextField!
    @IBOutlet weak var apellido_materno: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func enviarDatos(_ sender: Any) {
        guard let nombreValue = nombre.text, !nombreValue.isEmpty,
              let apellidoPaternoValue = apellido_paterno.text, !apellidoPaternoValue.isEmpty,
              let apellidoMaternoValue = apellido_materno.text, !apellidoMaternoValue.isEmpty,
              let curpValue = curp.text, !curpValue.isEmpty,
              let rfidValue = rfid.text, !rfidValue.isEmpty,
              let departamentoValue = departamento.text, !departamentoValue.isEmpty else {
            mostrarAlerta(titulo: "Error", mensaje: "Por favor, complete todos los campos.")
            return
        }
        
        let rolSeleccionado: String
        switch rol.selectedSegmentIndex {
        case 0:
            rolSeleccionado = "administrador"
        case 1:
            rolSeleccionado = "empleado"
        case 2:
            rolSeleccionado = "soporte"
        default:
            rolSeleccionado = "No seleccionado"
        }

        let data: [String: Any] = [
            "nombre": nombreValue,
            "apellido_paterno": apellidoPaternoValue,
            "apellido_materno": apellidoMaternoValue,
            "rol": rolSeleccionado,
            "rfid": rfidValue,
            "curp": curpValue,
            "departamento": departamentoValue
        ]

        enviarSolicitud(data: data)
    }
    
    func enviarSolicitud(data: [String: Any]) {
        guard let url = URL(string: "http://127.0.0.1:8000/api/estacion/673a970b8548904611656030/usuario") else {
            mostrarAlerta(titulo: "Error", mensaje: "URL no válida.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            request.httpBody = jsonData
        } catch {
            mostrarAlerta(titulo: "Error", mensaje: "Error al convertir los datos a JSON: \(error.localizedDescription)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.mostrarAlerta(titulo: "Error", mensaje: "Error en la solicitud: \(error.localizedDescription)")
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.mostrarAlerta(titulo: "Error", mensaje: "No se recibió una respuesta del servidor.")
                }
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // Imprimir la respuesta completa para ver qué está devolviendo el servidor
                    print("Respuesta del servidor: \(jsonResponse)")

                    // Verificamos si existe el campo "message" en la respuesta
                    if let message = jsonResponse["message"] as? String {
                        // Si el mensaje es "El RFID ya está registrado."
                        if message == "El RFID ya está registrado." {
                            DispatchQueue.main.async {
                                self.mostrarAlerta(titulo: "Error", mensaje: message)
                            }
                        }
                        // Si el mensaje es "El CURP ya está registrado."
                        else if message == "El CURP ya está registrado." {
                            DispatchQueue.main.async {
                                self.mostrarAlerta(titulo: "Error", mensaje: message)
                            }
                        }
                    } else {
                        // Si no hay mensaje de error, mostramos éxito
                        if let nombre = jsonResponse["nombre"] as? String,
                           let apellidoPaterno = jsonResponse["apellido_paterno"] as? String {
                            DispatchQueue.main.async {
                                self.mostrarAlerta(titulo: "Éxito", mensaje: "Usuario agregado correctamente.")
                                self.limpiarCampos()
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.mostrarAlerta(titulo: "Error", mensaje: "Datos incompletos en la respuesta.")
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.mostrarAlerta(titulo: "Error", mensaje: "Respuesta no válida del servidor.")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.mostrarAlerta(titulo: "Error", mensaje: "Error al procesar la respuesta del servidor: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }



    func mostrarAlerta(titulo: String, mensaje: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
        present(alerta, animated: true, completion: nil)
    }

    func limpiarCampos() {
        rfid.text = ""
        nombre.text = ""
        apellido_paterno.text = ""
        apellido_materno.text = ""
        curp.text = ""
        departamento.text = ""
        rol.selectedSegmentIndex = UISegmentedControl.noSegment
    }
}

