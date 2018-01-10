//
//  SettingsViewController.swift
//  TreeClimbr
//
//  Created by Carlo Namoca on 2018-01-10.
//  Copyright © 2018 Mar Koss. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func logout(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
        do {
            try Auth.auth().signOut()
        }
        catch let error as NSError {
            print (error.localizedDescription)
        }
    }
    
    @IBAction func backToMapView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
 

}
