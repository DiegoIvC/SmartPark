//
//  DashboardViewController.swift
//  smartpark
//
//  Created by Luis Fernando Robles Ibarra on 10/11/24.
//

import UIKit

class DashboardViewController: UIViewController {

    @IBOutlet weak var lblUltimaHoraLuz: UILabel!
    @IBOutlet weak var lblTiempoTotalLuz: UILabel!
    @IBOutlet weak var lblUltimaAlarmaHumo: UILabel!
    @IBOutlet weak var lblUltimaAlarmaAuto: UILabel!
    @IBOutlet weak var lblUltimoAcceso: UILabel!
    
    @IBOutlet var lblStatusCajones: [UILabel]!
    @IBOutlet var lblTextoDisponibilidad: [UILabel]!
    @IBOutlet var imvCajones: [UIImageView]!
    
    
    @IBOutlet var viewsCajones: [UIView]!
    
    @IBOutlet weak var btnAlarma: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for cajon in viewsCajones {
            cajon.layer.cornerRadius = 10
        }
        
        actualizarDashboard()
        ButtonStatus()
        actualizarDashboardCada5Segundos()
    }
    
    func actualizarDashboardCada5Segundos() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.actualizarDashboard()
            //print("actualizado")
        }
    }
    
    func actualizarDashboard() {
        let urlSession = URLSession.shared
        let url = URL(string: "http://127.0.0.1:8000/api/estacion/673a970b8548904611656030/dashboard")!
        
        urlSession.dataTask(with: url) { data, response, error in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
                //print(json)
                if let sensorLuz = json?[0] {
                    //print(sensorLuz)
                    DispatchQueue.main.async {
                        self.lblUltimaHoraLuz.text = "\(sensorLuz["horariodelValor0"] as? String ?? "No se pudo recuperar el dato")"
                        self.lblTiempoTotalLuz.text = "\(sensorLuz["tiempoTotal"] as? String ?? "No se pudo recuperar el dato")"
                    }
                }
                
                if let sensorHumo = json?[1] {
                    DispatchQueue.main.async {
                        self.lblUltimaAlarmaHumo.text = "\(sensorHumo["ultima-alarma"] as? String ?? "No se pudo recuperar el dato")"
                    }
                }
                
                if let sensorAcceso = json?[2] {
                    //print(sensorAcceso)
                    DispatchQueue.main.async {
                        self.lblUltimoAcceso.text = "\(sensorAcceso["fecha"] as? String ?? "No se pudo recuperar el valor")"
                    }
                }
                
                if let sensorEspacios = json?[3] {
                    let espacios = sensorEspacios["espacios"] as? [String:Any]
                    
                    let espacio1 = espacios?["IN-1"]
                    if let espacio1 = espacio1 as? [String:Any] {
                        if espacio1["valor"] as! Int == 0 {
                            DispatchQueue.main.async {
                                self.lblStatusCajones[0].textColor = UIColor(red: 8/255, green: 164/255, blue: 0/255, alpha: 1)
                                self.lblTextoDisponibilidad[0].textColor = UIColor(red: 8/255, green: 164/255, blue: 0/255, alpha: 1)
                                self.imvCajones[0].image = nil
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.lblStatusCajones[0].textColor = .red
                                self.lblTextoDisponibilidad[0].textColor = .red
                                self.imvCajones[0].image = .carUp
                            }
                        }
                    }
                    
                    let espacio2 = espacios?["IN-2"]
                    if let espacio2 = espacio2 as? [String:Any] {
                        if espacio2["valor"] as! Int == 0 {
                            DispatchQueue.main.async {
                                self.lblStatusCajones[1].textColor = UIColor(red: 8/255, green: 164/255, blue: 0/255, alpha: 1)
                                self.lblTextoDisponibilidad[1].textColor = UIColor(red: 8/255, green: 164/255, blue: 0/255, alpha: 1)
                                self.imvCajones[1].image = nil
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.lblStatusCajones[1].textColor = .red
                                self.lblTextoDisponibilidad[1].textColor = .red
                                self.imvCajones[1].image = .carUp
                            }
                        }
                    }
                    
                    let espacio3 = espacios?["IN-3"]
                    if let espacio3 = espacio3 as? [String:Any] {
                        if espacio3["valor"] as! Int == 0 {
                            DispatchQueue.main.async {
                                self.lblStatusCajones[2].textColor = UIColor(red: 8/255, green: 164/255, blue: 0/255, alpha: 1)
                                self.lblTextoDisponibilidad[2].textColor = UIColor(red: 8/255, green: 164/255, blue: 0/255, alpha: 1)
                                self.imvCajones[2].image = nil
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.lblStatusCajones[2].textColor = .red
                                self.lblTextoDisponibilidad[2].textColor = .red
                                self.imvCajones[2].image = .carUp
                            }
                        }
                    }
                }
                
                
            }
        }.resume()
        
        ButtonStatus()
    }
    
    func ButtonStatus(){
        let urlSession = URLSession.shared
        let url = URL(string: "http://127.0.0.1:8000/api/estacion/673a970b8548904611656030/actuadores/alarma/estatus")
        
        urlSession.dataTask(with: url!) { (data, response, error) in
            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let sensorHumedad = json["HU"] as? [[String:Any]] {
                        print(sensorHumedad)
                        if let valor = sensorHumedad[0]["valor"] as? Int {
                            DispatchQueue.main.async {
                                self.btnAlarma.isEnabled = valor == 1 ? true : false
                            }
                        }
                    }
                }
            }
        }.resume()
    }
    
    func apagarAlarma(){
        let fecha = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        let fechaFormateada = dateFormatter.string(from: fecha)
        print(fechaFormateada)
        
        let urlSession = URLSession.shared
        guard let url = URL(string: "http://127.0.0.1:8000/api/estacion/673a970b8548904611656030/actuadores/alarma/apagar") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer zfDzOl3vzfDzOl3vzfDzOl3vzfDzOl3vz", forHTTPHeaderField: "Authorization")
        
        let json = ["fecha": fechaFormateada]
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        
        request.httpBody = jsonData
        urlSession.dataTask(with: request) { data, response, error in
            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print(data)
                }
            }
            
            if let response = response {
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Response: \(httpResponse.statusCode)")
                }
            }
            
            if let error = error {
                if let urlError = error as? URLError {
                    print(urlError.localizedDescription)
                }
            }
        }.resume()
        
    }
    
    
    @IBAction func btnApagarAlarma(_ sender: UIButton) {
        apagarAlarma()
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


