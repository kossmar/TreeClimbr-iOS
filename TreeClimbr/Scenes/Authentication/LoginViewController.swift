import UIKit
import Firebase


class LoginViewController: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var sourceVC = SignUpViewController()
    var delegate: VerifyUserDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = loginButton.frame.height/4
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all)
    }
    
    //MARK: Actions
    
    @IBAction func SignUpButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        guard let email = emailField.text, let password = passwordField.text else {
            AlertShow.show(inpView: self,
                           titleStr: "Oopsies!",
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
                    if self.sourceVC.fromSettings == true {
                        self.sourceVC.fromSettings = false
                        self.delegate?.verificationComplete()
                        self.view.window?.rootViewController?.dismiss(animated: true, completion: {
                        
                        })
                    } else {
                        self.sourceVC.sourceVC.dismiss(animated: true, completion: nil)
                        self.delegate?.verificationComplete()
                    }
                }
            })
        })
    }

    @IBAction func cancelLogInPressed(_ sender: UIBarButtonItem) {
        if self.sourceVC.fromTreeNew == true {
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            self.sourceVC.fromTreeNew = false
        } else {
            self.sourceVC.sourceVC.dismiss(animated: true, completion: nil)
        }
    }
}
