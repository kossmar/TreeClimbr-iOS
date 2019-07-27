import UIKit
import Firebase
//import FirebaseAuth


class RegisterClass: NSObject
{
    
    //   static var sharedInstance = RegisterClass()
    
    class func registerMethod(inpName: String, inpEmail: String, inpPassword: String, completion: @escaping () -> Void) {
        Auth.auth().createUser (withEmail: inpEmail,
                                password: inpPassword)
        { (authDataResult, error) in
            if (error == nil)
            {
                // TODO: UPDATE optional handling
                let user = authDataResult!.user
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = inpName
                
                changeRequest.commitChanges(completion:
                    { (profError) in
                        if ( profError == nil) {
                            
                            // setting local user
                            AppData.sharedInstance.curUser = User(name: user.displayName!,
                                                                  email: user.email!,
                                                                  uid: user.uid);
                            
                            
                            
                            
                            
                            
                            let userDict : [String : String] = ["nameKey": user.displayName!,
                                                                "emailKey": user.email!,
                                                                "uidKey": user.uid]
                            
                            AppData.sharedInstance.usersNode
                                .child(user.uid)
                                .setValue(userDict)
                            
                            ReadWrite.writeUser();
                            
                            sendEmailVerification()

                            completion()
                            
                            
                            // add alert to confirm register?
//                            AlertShow.show(inpView: self, titleStr: "Yay!", messageStr: "You're now registered")
                            
                            print("registered!")
                            
                            
                        }
                        
                       
                })
            }
            else
            {
                print("\(String(describing: error))")
                //                AlertShow.show(inpView: inpView, titleStr: "Error", messageStr: error.debugDescription);
            }
        }
    }
    
    class func sendEmailVerification() {
        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
            guard error == nil else {
                print("Failed to send Email verification. \(String(describing: error))")
                return
            }
            
            print("Verification sent")
        })
    }
}
