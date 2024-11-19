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
        
        let urlSession = URLSession.shared
        let urlCajones = URL(string: "http://localhost:8000/api/estacion/672c1940e0a80c0b4f7ffdf7/datos")
        urlSession.dataTask(with: urlCajones!) {
            data, response, error in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data)
                //print(String(describing: json))
                if let jsonSerializable = json as? [String: Any] {
                    print(String(describing: jsonSerializable))
                    if let Ul01 = jsonSerializable["IN-01"] as? [String: Any] {
                        print(String(describing: Ul01))
                        if Ul01["valor"] as! Int == 0 {
                            DispatchQueue.main.async {
                                //self.viewCajones[0].backgroundColor = UIColor(red: 8/255, green: 164/255, blue: 0/255, alpha: 0.5)
                                self.labelEstadoCajones[0].textColor = UIColor(red: 8/255, green: 164/255, blue: 0/255, alpha: 1)
                                self.labelDisponibilidad[0].textColor = UIColor(red: 8/255, green: 164/255, blue: 0/255, alpha: 1)
                                
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.labelEstadoCajones[0].textColor = .red
                                self.imageViewCajones[0].image = UIImage.carUp
                                self.labelDisponibilidad[0].text = "No disponible"
                                self.labelDisponibilidad[0].textColor = .red
                            }
                        }

                    }
                    if let Ul02 = jsonSerializable["IN-02"] as? [String: Any] {
                        if Ul02["valor"] as! Int == 0 {
                            DispatchQueue.main.async {
                                DispatchQueue.main.async {
                                    self.labelEstadoCajones[1].textColor = UIColor(red: 8/255, green: 164/255, blue: 0/255, alpha: 1)
                                    self.labelDisponibilidad[1].textColor = UIColor(red: 8/255, green: 164/255, blue: 0/255, alpha: 1)
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.labelEstadoCajones[1].textColor = .red
                                self.imageViewCajones[1].image = UIImage.carUp
                                self.labelDisponibilidad[1].text = "No disponible"
                                self.labelDisponibilidad[1].textColor = .red
                            }
                        }
                    }
                    if let Ul03 = jsonSerializable["IN-03"] as? [String: Any] {
                        if Ul03["valor"] as! Int == 0 {
                            DispatchQueue.main.async {
                                self.labelEstadoCajones[2].textColor = UIColor(red: 8/255, green: 164/255, blue: 0/255, alpha: 1)
                                self.labelDisponibilidad[2].textColor = UIColor(red: 8/255, green: 164/255, blue: 0/255, alpha: 1)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.labelEstadoCajones[2].textColor = .red
                                self.imageViewCajones[2].image = UIImage.carUp
                                self.labelDisponibilidad[2].text = "No disponible"
                                self.labelDisponibilidad[2].textColor = .red
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
