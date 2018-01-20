import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField?
    @IBOutlet weak var emailTextField: UITextField?
    @IBOutlet weak var passwordTextField: UITextField?
    @IBOutlet weak var signUpButton: UIButton!
    
    var delegate: VerifyUserDelegate?
    var sourceVC = UIViewController()
    var fromSettings = false
    var fromTreeNew = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUpButton.layer.cornerRadius = signUpButton.frame.height/4

    }
    
    // MARK: - Actions
    
    @IBAction func registerNewUserPressed(_ sender: UIButton) {
        
        
        guard let username = usernameTextField?.text, let email = emailTextField?.text, let password = passwordTextField?.text else {
        
                return
        }
        
        if usernameTextField?.text == "" || emailTextField?.text == "" || passwordTextField?.text == "" {
            AlertShow.show(inpView: self,
                           titleStr: "Oopies!",
                           messageStr: "Please Fill Out All Required Fields") }
        
        RegisterClass.registerMethod(inpName: username, inpEmail: email, inpPassword: password, completion:{
            
            self.view.window?.rootViewController?.dismiss(animated: true, completion: {
                self.delegate?.verificationComplete()
            })
        })
    }
    
    @IBAction func goToLoginPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func cancelSignUpPressed(_ sender: UIBarButtonItem) {
        if fromTreeNew == false {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            self.fromTreeNew = false
        }
    }

    
    //MARK: Prepare For Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toLogin" {
            guard let treeVC = segue.destination as? LoginViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            treeVC.sourceVC = self
        }
    }
    
}
