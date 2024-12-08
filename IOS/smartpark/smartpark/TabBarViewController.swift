//
//  TabBarViewController.swift
//  smartpark
//
//  Created by Luis Fernando Robles Ibarra on 06/12/24.
//

import UIKit

class TabBarViewController: UITabBarController {

    var username: String!
    var password: String!
    var autenticado: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let iniciarSesion = IniciarSesion.iniciarSesionShared()
        
        // Do any additional setup after loading the view.
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
