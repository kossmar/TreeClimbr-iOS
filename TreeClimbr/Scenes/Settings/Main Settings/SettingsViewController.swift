

import UIKit
import Firebase

class SettingsViewController: UIViewController, VerifyUserDelegate
{

    
    @IBOutlet weak var blockedUsersButton: UIButton!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var changeNameButton: UIButton!
    @IBOutlet weak var changeEmailButton: UIButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    
    var sourceVC = MapViewController()
    var delegate: VerifyUserDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        blockedUsersButton.layer.cornerRadius = blockedUsersButton.frame.height/4
        changeNameButton.layer.cornerRadius = changeNameButton.frame.height/4
        changeEmailButton.layer.cornerRadius = changeEmailButton.frame.height/4
    

    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        let firUser = Auth.auth().currentUser
        if firUser != nil
        {
            guard let displayName = firUser?.displayName else {return}
            self.logoutButton.title = "Logout"
            self.welcomeLabel.text = "Welcome, " + displayName + "!"
            let email = Auth.auth().currentUser?.email
            if  email != nil
            {
                self.emailLabel.text = "e-mail: " + email!
            }
        } else {
            self.logoutButton.title = "Login"
            self.welcomeLabel.text = "Hello, Stranger."
            self.emailLabel.text = ""
            self.blockedUsersButton.isHidden = true
            self.changeNameButton.isHidden = true
            self.changeEmailButton.isHidden = true

        }
    }
    
    //MARK: Prepare For Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
        if segue.identifier == "toSignUp"
        {
            
            let signUpVC = segue.destination as! SignUpViewController
            signUpVC.sourceVC = self
            signUpVC.fromSettings = true
            signUpVC.delegate = self
        }
    }
    
    //MARK: Actions
    
    @IBAction func logout(_ sender: Any)
    {
        
        let user = Auth.auth().currentUser
        if user != nil
        {
            do
            {
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
    
    @IBAction func changeUsernamePressed(_ sender: UIButton)
    {

        AlertShow.respond(inpView: self, titleStr: "Enter New Username", messageStr: "") { (name) in
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = name
            changeRequest?.commitChanges(completion: { (error) in
            })
            self.welcomeLabel.text = "Welcome, " + name
            CommentManager.updateUserCommentsUserName(newName: name)
            PhotoManager.updateUserPhotosUserName(newName: name)
            TreeManager.updateUserTreesUserName(newName: name)
            
            guard let curUser = Auth.auth().currentUser else {return}
            AppData.sharedInstance.usersNode
                .child(curUser.uid)
                .observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let userDict = snapshot.value as? NSDictionary else {return}
                    let _ = userDict["nameKey"] as! String
                    let userID = userDict["uidKey"] as! String
                    let email = userDict["emailKey"] as! String
                    
                    let newUserDict: [String: Any] = [
                        "nameKey": name,
                        "uidKey": userID,
                        "emailKey": email
                    ]
                    
                    AppData.sharedInstance.usersNode
                        .child(curUser.uid)
                        .setValue(newUserDict)
                })
        }
    }
    
    @IBAction func changeEmailPressed(_ sender: UIButton)
    {
        
        AlertShow.respond(inpView: self, titleStr: "Enter New Email", messageStr: "") { (newEmail) in
            Auth.auth().currentUser?.updateEmail(to: newEmail) { (error) in
                if error == nil
                {
                    guard let curUser = Auth.auth().currentUser else {return}
                    self.emailLabel.text = "e-mail: " + newEmail
                    
                    AppData.sharedInstance.usersNode
                        .child(curUser.uid)
                        .observeSingleEvent(of: .value, with: { (snapshot) in
                            guard let userDict = snapshot.value as? NSDictionary else {return}
                            let userName = userDict["nameKey"] as! String
                            let userID = userDict["uidKey"] as! String
                            let _ = userDict["emailKey"] as! String
                            
                            let newUserDict: [String: Any] = [
                                "nameKey": userName,
                                "uidKey": userID,
                                "emailKey": newEmail
                            ]
                            
                            AppData.sharedInstance.usersNode
                                .child(curUser.uid)
                                .setValue(newUserDict)
                        })
                } else {
                    print(error!)
                }
            }
        }
    }
    
    @IBAction func backToMapView(_ sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: VerifyUserDelegate
    
    func verificationComplete()
    {
        self.delegate?.verificationComplete()
    }
    
}
