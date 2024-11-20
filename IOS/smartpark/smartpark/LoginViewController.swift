//
//  LoginViewController.swift
//  smartpark
//
//  Created by Luis Fernando Robles Ibarra on 19/11/24.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var txtNombre: UITextField!

    @IBOutlet weak var txtContraseña: UITextField!
    @IBOutlet weak var btnIniciarSesion: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnIniciarSesion.layer.cornerRadius = 5
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
