//
//  SplashViewController.swift
//  smartpark
//
//  Created by Luis Fernando Robles Ibarra on 10/12/24.
//

import UIKit

class SplashViewController: UIViewController {

    @IBOutlet weak var imvSplash: UIImageView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let w = view.frame.width * 0.9
        let h = w * 0.43181818
        let x = (view.frame.width - w)/2
        let y = -h
        imvSplash.frame = CGRect(x: x, y: y, width: w, height: h)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 3.0) {
            super.viewDidLoad()
            
            let y = (self.view.frame.height - self.imvSplash.frame.height) / 2.0
            self.imvSplash.frame.origin.y = y
        } completion: { comp in
            self.performSegue(withIdentifier: "sgSplash", sender: nil)
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
