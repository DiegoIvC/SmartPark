//
//  DashboardViewController.swift
//  smartpark
//
//  Created by Luis Fernando Robles Ibarra on 10/11/24.
//

import UIKit

class DashboardViewController: UIViewController {

    
    
    @IBOutlet var cuadrosCajones: [UILabel]!
    @IBOutlet weak var horaUltimoAcceso: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print("pantalla de dashboard")
        // Do any additional setup after loading the view.
        let urlSession = URLSession.shared
        let urlAccesos = URL(string: "http://127.0.0.1:8000/api/estacion/672c1940e0a80c0b4f7ffdf7/accesos")
        urlSession.dataTask(with: urlAccesos!) {
            data, response, error in
            if let data = data {
                if let accesos = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    print(accesos)
                    DispatchQueue.main.async {
                        self.horaUltimoAcceso.text = "\(accesos.first?["fecha"] as? String ?? "") por \(accesos.first?["nombre"] as? String ?? "")"
                    }
                }
            }
        }.resume()
        
        actualizarCajones()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func actualizarCajones() {
        let urlSession = URLSession.shared
        let urlCajones = URL(string: "http://127.0.0.1:8000/api/estacion/672c1940e0a80c0b4f7ffdf7/datos/estacionamiento")
        urlSession.dataTask(with: urlCajones!) {
            data, response, error in
            if let data = data {
                if let cajones = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    DispatchQueue.main.async {
                        //print(cajones)
                        for (indice, cajon) in cajones.enumerated() {
                            //print(String(describing: cajon["valor"]))
                            self.cuadrosCajones[indice].textColor = cajon["valor"] as? String == "1" ? UIColor(red: 8/255, green: 164/255, blue: 0/255, alpha: 1) : .red
                        }
                    }
                }
            }
            
        }.resume()
    }

}


