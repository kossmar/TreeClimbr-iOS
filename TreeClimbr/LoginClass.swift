

import UIKit
import Firebase

class LoginClass: NSObject {
    
    class func loginMethod (inpView: UIViewController, inpEmail: String, inpPassword: String, completion:@escaping () -> Void )  {
        
        Auth.auth().signIn(withEmail: inpEmail,
                           password: inpPassword)
        { (user, error) in
            if (error == nil)
            {
                AppData.sharedInstance.curUser = User(name: user!.displayName!,
                                                           email: user!.email!,
                                                           uid: user!.uid)
                
                print("LOGGED IN!")
                completion()
            }
            else
            {
                AlertShow.show(inpView: inpView, titleStr: "Failed", messageStr: "Your email or password was entered incorrectly.");
            }
        }
    }
    
}
