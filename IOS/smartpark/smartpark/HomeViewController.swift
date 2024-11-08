//
//  HomeViewController.swift
//  smartpark
//
//  Created by Luis Fernando Robles Ibarra on 07/11/24.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var viewCajonE4: UIView!
    @IBOutlet weak var viewCajonE3: UIView!
    @IBOutlet weak var viewCajonE2: UIView!
    @IBOutlet weak var viewCajonE1: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        borderColorView(viewCajonE1)
        borderColorView(viewCajonE2)
        borderColorView(viewCajonE3)
        borderColorView(viewCajonE4)
        
        
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
