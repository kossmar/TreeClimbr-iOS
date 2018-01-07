import UIKit
import Firebase
//import FirebaseAuth


class RegisterClass: NSObject {
    
    //   static var sharedInstance = RegisterClass()
    
    class func registerMethod(inpName: String, inpEmail: String, inpPassword: String, completion: @escaping () -> Void) {
        Auth.auth().createUser (withEmail: inpEmail,
                                password: inpPassword)
        { (onlineUser, error) in
            if (error == nil) {
                let changeRequest = onlineUser?.createProfileChangeRequest()
                changeRequest?.displayName = inpName
                
                changeRequest?.commitChanges(completion:
                    { (profError) in
                        if ( profError == nil) {
                            
                            // setting local user
                            AppData.sharedInstance.curUser = User(name: onlineUser!.displayName!,
                                                                  email: onlineUser!.email!,
                                                                  uid: onlineUser!.uid);
                            
                            
                            
                            
                            
                            
                            let userDict : [String : String] = ["nameKey": onlineUser!.displayName!,
                                                                "emailKey": onlineUser!.email!,
                                                                "uidKey": onlineUser!.uid]
                            
                            AppData.sharedInstance.usersNode
                                .child(onlineUser!.uid)
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
