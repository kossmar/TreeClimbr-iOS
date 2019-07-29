//
//  SettingsViewController.swift
//  
//
//  Created by Mar Koss on 2019-07-25.


import UIKit
import Firebase

protocol SettingsDisplayLogic: class
{
    func displayAuthenticationManagement(viewModel: Settings.Logout.ViewModel)
    func displayNewUsername(viewModel: Settings.ChangeUsername.ViewModel)
    func displayNewEmail(viewModel: Settings.ChangeEmail.ViewModel)
}

class SettingsViewController: UIViewController, VerifyUserDelegate, SettingsDisplayLogic
{
    
    @IBOutlet weak var blockedUsersButton: UIButton!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var changeNameButton: UIButton!
    @IBOutlet weak var changeEmailButton: UIButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var interactor: SettingsBusinessLogic?
    var router: (NSObjectProtocol & SettingsRoutingLogic & SettingsDataPassing)?
    
    var sourceVC = MapViewController()
    var delegate: VerifyUserDelegate?
    
    // TODO: Move these variables to the data store
    var signUpSegueId = "SignUp"
    var logoutErrorTitleString = "An Error Occurred"
    var logoutErrorMessageString = "Logout request could not be completed at this time. Please try again."
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup()
    {
        let viewController = self
        let interactor = SettingsInteractor()
        let presenter = SettingsPresenter()
        let router = SettingsRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: Routing
    
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    //    {
    //        if let scene = segue.identifier {
    //            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
    //            if let router = router, router.responds(to: selector) {
    //                router.perform(selector, with: segue)
    //            }
    //        }
    //    }
    
    // TODO: Update Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == signUpSegueId
        {
            let signUpVC = segue.destination as! SignUpViewController
            signUpVC.sourceVC = self
            signUpVC.fromSettings = true
            signUpVC.delegate = self
        }
    }
    
    // MARK: View lifecycle
    
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
        // TODO: Move this to the interactor
        super.viewWillAppear(animated)
        let firUser = Auth.auth().currentUser
        if firUser != nil
        {
            guard let displayName = firUser?.displayName else {return}
            self.logoutButton.title = "Logout"
            self.welcomeLabel.text = "Welcome, " + displayName + "!"
            let email = Auth.auth().currentUser?.email
            if email != nil
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
    
    // MARK: Actions
    
    @IBAction func logoutPressed(_ sender: Any)
    {
        interactor?.manageAuthentication()
    }
    
    @IBAction func changeUsernamePressed(_ sender: UIButton)
    {
        AlertShow.respond(inpView: self, titleStr: "Enter New Username", messageStr: "") { (newUsernameStr) in
            
            let request = Settings.ChangeUsername.Request(newUsernameStr: newUsernameStr)
            self.interactor?.changeUsername(request: request)
        }
    }
    
    @IBAction func changeEmailPressed(_ sender: UIButton)
    {
        
        AlertShow.respond(inpView: self, titleStr: "Enter New Email", messageStr: "") { (newEmailStr) in
            let request = Settings.ChangeEmail.Request(newEmailStr: newEmailStr)
            self.interactor?.changeEmail(request: request)
        }
    }
    
    @IBAction func backToMapViewPressed(_ sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Display Authentication Management
    
    func displayAuthenticationManagement(viewModel: Settings.Logout.ViewModel)
    {
        switch viewModel.result
        {
        case .logoutSuccess:
            self.dismiss(animated: true, completion: nil)
        case .logoutFailure:
            AlertShow.show(inpView: self, titleStr: logoutErrorTitleString, messageStr: logoutErrorMessageString)
            print(viewModel.error!.localizedDescription)
        case .login:
            performSegue(withIdentifier: signUpSegueId, sender: self)
        }
    }
    
    // MARK: Display New Username
    
    func displayNewUsername(viewModel: Settings.ChangeUsername.ViewModel)
    {
        // TODO: Update this so it copies the New Email pattern
        switch viewModel.result
        {
        case .success(let newWelcomeString):
            self.welcomeLabel.text = newWelcomeString
        case .failure(let error):
            print(error)
            // TODO: Add Alert to inform User of the error
        }
    }
    
    // MARK: Display New Email
    
    func displayNewEmail(viewModel: Settings.ChangeEmail.ViewModel)
    {
        if let newEmailLabelStr = viewModel.newEmailLabelStr
        {
            self.emailLabel.text = newEmailLabelStr
        } else if let errorStr = viewModel.error {
            AlertShow.show(inpView: self, titleStr: "An Error Occurred", messageStr: errorStr)
        }
    }
    
    // MARK: VerifyUserDelegate
    
    func verificationComplete()
    {
        self.delegate?.verificationComplete()
    }
}
