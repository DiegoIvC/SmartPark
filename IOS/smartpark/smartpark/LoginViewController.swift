//
//  LoginViewController.swift
//  smartpark
//
//  Created by Luis Fernando Robles Ibarra on 19/11/24.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtNombre: UITextField!
    @IBOutlet weak var txtContraseña: UITextField!
    @IBOutlet weak var btnIniciarSesion: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let iniciarSesion = IniciarSesion.iniciarSesionShared()
        iniciarSesion.abrirArchivo()
        print(iniciarSesion.autenticado)
        
        // Do any additional setup after loading the view.
        btnIniciarSesion.layer.cornerRadius = 5
        txtNombre.delegate = self
        txtContraseña.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let iniciarSesion = IniciarSesion.iniciarSesionShared()
        
        if iniciarSesion.autenticado {
            performSegue(withIdentifier: "segueLogin", sender: nil)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "segueLogin" {
            let iniciarSesion = IniciarSesion.iniciarSesionShared()
            
            if txtNombre.text!.isEmpty {
                DispatchQueue.main.async {
                    self.alerta("Error", "Debes llenar usuario y contraseña")
                }
                return false
            }
            
            if txtContraseña.text!.isEmpty {
                DispatchQueue.main.async {
                    self.alerta("Error", "Debes llenar usuario y contraseña")
                }
                return false
            }
            
            iniciarSesion.login(txtNombre, txtContraseña)
            print(iniciarSesion.autenticado)
            if iniciarSesion.autenticado {
                iniciarSesion.username = txtNombre.text!
                iniciarSesion.password = txtContraseña.text!
                iniciarSesion.autenticado = true
                
                iniciarSesion.guardarArchivo()
            } else {
                DispatchQueue.main.async {
                    self.alerta("Error", "Usuario o contraseña incorrectos")
                }
                return false
            }
            
        }
        return true
    }
    
    func alerta(_ titulo: String, _ mensaje: String) {
        print("alerta")
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Aceptar", style: .default)
        
        alerta.addAction(ok)
        self.present(alerta, animated: true)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
