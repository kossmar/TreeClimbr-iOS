

import UIKit
import Firebase

class SettingsViewController: UIViewController {
    
    
    @IBOutlet weak var blockedUsersButton: UIButton!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    var sourceVC = ViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        //        self.navigationController?.navigationBar.titleTextAttributes. = UIColor.white
        blockedUsersButton.layer.cornerRadius = blockedUsersButton.frame.height/4
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let firUser = Auth.auth().currentUser
        if firUser != nil {
            self.logoutButton.title = "Logout"
        } else {
            self.logoutButton.title = "Login"
        }
    }
    
    //MARK: Prepare For Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toSignUp" {
            
            let signUpVC = segue.destination as! SignUpViewController
            signUpVC.sourceVC = self
            signUpVC.fromSettings = true
        }
    }
    
    //MARK: Actions
    
    @IBAction func logout(_ sender: Any) {
        
        let user = Auth.auth().currentUser
        
        if user != nil {
            
            do {
                try Auth.auth().signOut()
                self.dismiss(animated: true, completion: nil)
            }
            catch let error as NSError {
                print (error.localizedDescription)
            }
            
            AppData.sharedInstance.hiddenUsersArr.removeAll()
            
        } else {
            performSegue(withIdentifier: "toSignUp", sender: self)
        }

    }
    
    @IBAction func backToMapView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
