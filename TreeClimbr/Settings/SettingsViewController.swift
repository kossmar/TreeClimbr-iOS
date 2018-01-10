

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    @IBOutlet weak var blockedUsersButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
//        self.navigationController?.navigationBar.titleTextAttributes. = UIColor.white
        blockedUsersButton.layer.cornerRadius = blockedUsersButton.frame.height/4
        
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
