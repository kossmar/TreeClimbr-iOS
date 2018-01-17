import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    var sourceVC = SignUpViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: Actions
    
    @IBAction func SignUpButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        guard let email = emailField.text, let password = passwordField.text else {
            AlertShow.show(inpView: self,
                           titleStr: "Oopies!",
                           messageStr: "Please Fill Out All Required Fields")
            return
        }
        
        LoginClass.loginMethod(inpView: self, inpEmail: email, inpPassword: password, completion: {
        
            let blockedUser = AppData.sharedInstance.blockedNode
            let user = Auth.auth().currentUser?.uid
            
            blockedUser.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild(user!) {
                    let alert = UIAlertController(title: "Blocked", message: "Your account has been suspended until further notice.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.dismiss(animated: true, completion: {
                        self.sourceVC.dismiss(animated: true, completion: nil)
                    })
                }
            })
            
            

            
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        let alert = UIAlertController(title: "Careful out there!",
                                      message: "Tree climbing can be dangerous. Always follow local laws and practice extreme caution when attempting to climb trees!",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.view.window?.rootViewController?.present(alert,
                                                      animated: true,
                                                      completion: nil)
    }
}
