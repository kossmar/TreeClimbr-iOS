

import UIKit
import Firebase

class LoginClass: NSObject {
    
    class func loginMethod (inpView: UIViewController, inpEmail: String, inpPassword: String, completion:@escaping () -> Void )  {
        
        // TODO: Catch these errors properly
        
        Auth.auth().signIn(withEmail: inpEmail,
                           password: inpPassword)
        { (authDataResult, error) in
            if (error == nil)
            {
                guard let dataResult = authDataResult else {return}
                let user = dataResult.user
                let uid = user.uid
                guard let displayName = user.displayName, let email = user.email else {return}
                
                AppData.sharedInstance.curUser = User(name: displayName,
                                                           email: email,
                                                           uid: uid)
                print("LOGGED IN!")
                completion()
            }
            else
            {
                // TODO: This is not the only error case. UPDATE
                
                AlertShow.show(inpView: inpView, titleStr: "Failed", messageStr: "Your email or password was entered incorrectly.");
            }
        }
    }
    
}
