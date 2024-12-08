//
//  HomeViewController.swift
//  smartpark
//
//  Created by Luis Fernando Robles Ibarra on 07/11/24.
//

import UIKit
import Foundation

class HomeViewController: UIViewController {

    
    @IBOutlet var viewCajones: [UIView]!
    @IBOutlet var labelEstadoCajones: [UILabel]!
    @IBOutlet var imageViewCajones: [UIImageView]!
    @IBOutlet var labelDisponibilidad: [UILabel]!
    
    @IBOutlet var labelNombreCajones: [UILabel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        for viewCajon in viewCajones {
            borderColorView(viewCajon)
        }
        
        for nombreCajon in labelNombreCajones {
            nombreCajon.textColor = UIColor(red: 212/255, green: 212/255, blue: 212/255, alpha: 1)
        }
        actualizarCajones()
        actualizarCajonesCada5Segundos()
    }
    
    func actualizarCajonesCada5Segundos() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.actualizarCajones()
            //print("actualizado")
        }
    }
    
    func actualizarCajones() {
        let urlSession = URLSession.shared
        let urlCajones = URL(string: "http://3.147.187.80/api/estacion/673a970b8548904611656030/datos/estacionamiento")
        urlSession.dataTask(with: urlCajones!) {
            data, response, error in
            if let data = data {
                if let cajones = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    DispatchQueue.main.async {
                        print(cajones)
                        for (indice, cajon) in cajones.enumerated() {
                            //print(String(describing: cajon["valor"]))
                            if(cajon["valor"] as? String == "0") {
                                self.labelDisponibilidad[indice].textColor = UIColor(red: 8/255, green: 164/255, blue: 0/255, alpha: 1)
                                self.labelEstadoCajones[indice].textColor = UIColor(red: 8/255, green: 164/255, blue: 0/255, alpha: 1)
                                self.imageViewCajones[indice].image = nil
                            } else {
                                self.labelDisponibilidad[indice].textColor = .red
                                self.labelEstadoCajones[indice].textColor = .red
                                self.imageViewCajones[indice].image = .carUp
                            }
                        }
                    }
                }
            }
            
        }.resume()
    }
    
    func borderColorView(_ viewCajon: UIView) {
        viewCajon.layer.borderWidth = 2
        viewCajon.layer.borderColor = UIColor(red: 212/255, green: 212/255, blue: 212/255, alpha: 1).cgColor
        viewCajon.layer.cornerRadius = 20
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
