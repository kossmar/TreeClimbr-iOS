import UIKit

class LoginViewController: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: Actions
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        guard let email = emailField.text, let password = passwordField.text else {
            AlertShow.show(inpView: self,
                           titleStr: "Oopies!",
                           messageStr: "Please Fill Out All Required Fields")
            return
        }
        
        
        LoginClass.loginMethod(inpView: self, inpEmail: email, inpPassword: password, completion: {
           
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            
            })
    }
    
    @IBAction func signupButtonPressed(_ sender: UIButton) {
        }
    
    
}
