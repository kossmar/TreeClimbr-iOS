

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Actions
    
    @IBAction func registerNewUserPressed(_ sender: UIButton) {
        
        guard let username = usernameTextField.text, let email = emailTextField.text, let password = passwordTextField.text else {
            AlertShow.show(inpView: self,
                           titleStr: "Oopies!",
                           messageStr: "Please Fill Out All Required Fields")
            return
        }
        
//        DispatchQueue.main.async(execute: {() -> Void in
        
            RegisterClass.registerMethod(inpName: username, inpEmail: email, inpPassword: password, completion:{
                
                self.dismiss(animated: true, completion: nil)
                
                
            })
//        })
        
//        if AppData.sharedInstance.curUser != nil {
//            dismiss(animated: true, completion: nil)
//
//        }
        
    }
    
    @IBAction func goToLoginPressed(_ sender: UIButton) {
        
        
    }
    
}
