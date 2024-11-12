//
//  DashboardViewController.swift
//  smartpark
//
//  Created by Luis Fernando Robles Ibarra on 10/11/24.
//

import UIKit

class DashboardViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let urlSession = URLSession.shared
        let urlAccesos = URL(string: "https://api.chucknorris.io/jokes/random")
        urlSession.dataTask(with: urlAccesos!) {
            data, response, error in
            if let data = data {
                print(String(describing: data))
            }
        }
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
