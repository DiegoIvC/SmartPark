import UIKit

class AddUserViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var rfid: UITextField!
    @IBOutlet weak var nombre: UITextField!
    @IBOutlet weak var rol: UISegmentedControl!
    @IBOutlet weak var apellido_paterno: UITextField!
    @IBOutlet weak var curp: UITextField!
    @IBOutlet weak var departamento: UITextField!
    @IBOutlet weak var apellido_materno: UITextField!
    @IBOutlet weak var generaterfid: UIButton!
    @IBOutlet weak var departamentolabel: UILabel!
    
    @IBOutlet weak var curplabel: UILabel!
    var passwordField: UITextField!
    var userName: UITextField!

    var profileImageView: UIImageView!
    var selectedImage: UIImage?
    var deleteImageButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        rfid.isEnabled = false
        rol.selectedSegmentIndex = UISegmentedControl.noSegment
        
        configurarPasswordField()
        configurarusername()
        agregarProfileImageView()
        configurarBotonEliminarImagen()
        rol.addTarget(self, action: #selector(cambiarRol(_:)), for: .valueChanged)
    }

    func configurarPasswordField() {
        passwordField = UITextField()
        passwordField.placeholder = "Ingrese su contraseña"
        passwordField.isSecureTextEntry = true
        passwordField.borderStyle = .roundedRect
        passwordField.font = UIFont.systemFont(ofSize: 14)

        passwordField.textAlignment = .center // Alinear texto al centro
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(passwordField)
        NSLayoutConstraint.activate([
            passwordField.topAnchor.constraint(equalTo: departamento.bottomAnchor, constant: 20),
            passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordField.heightAnchor.constraint(equalToConstant: 40)
        ])
        passwordField.isHidden = true
    }
    
    func configurarusername() {
        userName = UITextField()
        userName.placeholder = "Escriba un nombre de usuario"
        userName.isSecureTextEntry = false
        userName.borderStyle = .roundedRect
        userName.font = UIFont.systemFont(ofSize: 14) // Ajustar tamaño de letra
        userName.translatesAutoresizingMaskIntoConstraints = false
        userName.textAlignment = .center
        view.addSubview(userName)
        NSLayoutConstraint.activate([
            userName.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 20),
            userName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            userName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            userName.heightAnchor.constraint(equalToConstant: 40)
        ])
        passwordField.isHidden = false
    }

    func agregarProfileImageView() {
        profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 57
        profileImageView.layer.masksToBounds = true  // Asegurarse de que la imagen se recorte dentro del círculo

        // Asignar un símbolo predeterminado de SF Symbols
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .light, scale: .large)
        profileImageView.image = UIImage(systemName: "person.crop.circle", withConfiguration: symbolConfig)
        profileImageView.tintColor = .gray
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(seleccionarImagen))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGesture)
        
        view.addSubview(profileImageView)
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            profileImageView.centerXAnchor.constraint(equalTo: view.rightAnchor, constant: -50),
            profileImageView.widthAnchor.constraint(equalToConstant: 55),
            profileImageView.heightAnchor.constraint(equalToConstant: 55)
        ])
    }

    func configurarBotonEliminarImagen() {
        deleteImageButton = UIButton(type: .system)
        deleteImageButton.setTitle("Eliminar", for: .normal)
        deleteImageButton.translatesAutoresizingMaskIntoConstraints = false
        deleteImageButton.addTarget(self, action: #selector(eliminarImagen), for: .touchUpInside)
        deleteImageButton.isHidden = true
        deleteImageButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)

        
        view.addSubview(deleteImageButton)
        NSLayoutConstraint.activate([
            deleteImageButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 0),
            deleteImageButton.centerXAnchor.constraint(equalTo: view.rightAnchor, constant: -50)
        ])
    }

    @objc func seleccionarImagen() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectedImage = image
            profileImageView.image = image
            deleteImageButton.isHidden = false
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    @objc func eliminarImagen() {
        profileImageView.image = UIImage(systemName: "person.crop.circle")
        selectedImage = nil
        deleteImageButton.isHidden = true
    }

    @objc func cambiarRol(_ sender: UISegmentedControl) {
        // Primero, ocultamos o mostramos el campo de departamento y su etiqueta
        if sender.selectedSegmentIndex == 1 {
            // Mostrar el departamento cuando el rol es 'empleado'
            departamento.isHidden = false
            departamentolabel.isHidden = false
        } else {
            // Ocultar el departamento cuando el rol es 'administrador' o 'soporte'
            departamento.isHidden = true
            departamentolabel.isHidden = true
        }
        
        // Reseteamos el campo de contraseña
        departamento.text = ""
        passwordField.text = ""
        passwordField.isHidden = !(sender.selectedSegmentIndex == 0 || sender.selectedSegmentIndex == 2 || sender.selectedSegmentIndex == 3)
    }


    @IBAction func enviarDatos(_ sender: Any) {
        guard let nombreValue = nombre.text, !nombreValue.isEmpty,
              let apellidoPaternoValue = apellido_paterno.text, !apellidoPaternoValue.isEmpty,
              let apellidoMaternoValue = apellido_materno.text, !apellidoMaternoValue.isEmpty,
              let curpValue = curp.text, !curpValue.isEmpty,
              let rfidValue = rfid.text, !rfidValue.isEmpty,
              let usernameValue = userName.text, !usernameValue.isEmpty else {
            mostrarAlerta(titulo: "Error", mensaje: "Por favor, complete todos los campos requeridos.")
            return
        }

        let rolSeleccionado: String
        switch rol.selectedSegmentIndex {
        case 0: rolSeleccionado = "administrador"
        case 1: rolSeleccionado = "empleado"
        case 2: rolSeleccionado = "soporte"
        case 3: rolSeleccionado = "vigilante"
        default: rolSeleccionado = "No seleccionado"
        }

        // Si no hay valor en departamento, asigna "" por defecto
        let departamentoValue = departamento.text?.isEmpty == true ? "" : departamento.text!

        var data: [String: Any] = [
            "nombre": nombreValue,
            "apellido_paterno": apellidoPaternoValue,
            "apellido_materno": apellidoMaternoValue,
            "rol": rolSeleccionado,
            "rfid": rfidValue,
            "curp": curpValue,
            "departamento": departamentoValue,
            "username": usernameValue,
            "imagen": ""  // Por defecto se envía vacío si no hay imagen seleccionada
        ]

        if let passwordValue = passwordField.text, !passwordValue.isEmpty {
            data["password"] = passwordValue
        }

        // Verifica si se ha seleccionado una imagen
        if let image = selectedImage, let imageData = image.jpegData(compressionQuality: 0.8) {
            data["imagen"] = imageData  // Agrega los datos de la imagen al diccionario
        }

        enviarSolicitud(data: data, image: selectedImage)
    }


    func enviarSolicitud(data: [String: Any], image: UIImage?) {
        guard let url = URL(string: "http://3.147.187.80/api/estacion/673a970b8548904611656030/usuario") else {
            mostrarAlerta(titulo: "Error", mensaje: "URL no válida.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Añadir datos del formulario al cuerpo
        for (key, value) in data {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Añadir la imagen si se seleccionó
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"imagen\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        // Cerrar el cuerpo de la solicitud
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.mostrarAlerta(titulo: "Error", mensaje: "Error al enviar datos: \(error.localizedDescription)")
                } else if let response = response as? HTTPURLResponse {
                    // Aquí procesamos la respuesta del servidor
                    if (200...299).contains(response.statusCode) {
                        // Si el código de estado es 2xx, el servidor ha procesado correctamente la solicitud
                        if let responseData = data, let responseString = String(data: responseData, encoding: .utf8) {
                            // Mostrar la respuesta del servidor
                            self.mostrarAlerta(titulo: "Éxito", mensaje: "Usuario registrado correctamente. Respuesta del servidor: \(responseString)")
                            
                            self.LimpiarDatos()
                        }
                    } else {
                        // Si no es un código de estado 2xx, muestra el código de error y la respuesta
                        if let responseData = data, let responseString = String(data: responseData, encoding: .utf8) {
                            self.mostrarAlerta(titulo: "Error", mensaje: "Error al registrar usuario. Código de estado: \(response.statusCode). Respuesta del servidor: \(responseString)")
                        } else {
                            self.mostrarAlerta(titulo: "Error", mensaje: "Error desconocido. Código de estado: \(response.statusCode).")
                        }
                    }
                } else {
                    self.mostrarAlerta(titulo: "Error", mensaje: "No se recibió respuesta válida del servidor.")
                }
            }
        }
        
        task.resume()
    }
    
                   


    @IBAction func generate_rfid() {
            guard let url = URL(string: "http://localhost:8000/api/estacion/673a970b8548904611656030/lector/rfid") else {
                mostrarAlerta(titulo: "Error", mensaje: "URL no válida.")
                return
            }

            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.mostrarAlerta(titulo: "Error", mensaje: "Error al realizar la solicitud: \(error.localizedDescription)")
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
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let lector = jsonResponse["lector"] as? [String: Any],
                       let valor = lector["valor"] as? String {  // Usamos "valor" para obtener el RFID
                        DispatchQueue.main.async {
                            self.rfid.text = valor
                            self.generaterfid.isEnabled = false
                            
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                       self.generaterfid.isEnabled = true
                                   }
                            
                            // Cambiar el borde del campo RFID a verde
                            self.rfid.layer.borderColor = UIColor.green.cgColor
                            self.rfid.layer.cornerRadius = 10.0
                            self.rfid.layer.borderWidth = 2
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
    
    func LimpiarDatos() {
        self.rfid.text = ""  // Si 'rfid' es un String, no hay problema
        self.nombre.text = ""
        self.rol.selectedSegmentIndex = -1  // Limpiar el valor de UISegmentedControl (ningún segmento seleccionado)
        self.apellido_materno.text = ""
        self.apellido_paterno.text = ""
        self.curp.text = ""
        self.departamento.text = ""
        
        // Si 'passwordField' y 'userName' son UITextField, debes modificar su propiedad 'text'
        self.passwordField.text = "" // Limpiar el contenido del campo de texto
        self.userName.text = "" // Limpiar el contenido del campo de texto
    }

    
    
    func mostrarAlerta(titulo: String, mensaje: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Aceptar", style: .default))
        present(alerta, animated: true)
    }
}
