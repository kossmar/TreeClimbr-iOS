

import UIKit
import Firebase

class LoginClass: NSObject {
    
    class func loginMethod (inpView: UIViewController, inpEmail: String, inpPassword: String)  {
        
        Auth.auth().signIn(withEmail: inpEmail,
                           password: inpPassword)
        { (user, error) in
            if (error == nil)
            {
                AppData.sharedInstance.curUser = User(name: user!.displayName!,
                                                           email: user!.email!,
                                                           uid: user!.uid)
                
// alert for logged in
                
//                ReadAll.readData(inpView: inpView);
            }
            else
            {
                AlertShow.show(inpView: inpView, titleStr: "Failed", messageStr: error.debugDescription);
            }
        }
    }
    
}
