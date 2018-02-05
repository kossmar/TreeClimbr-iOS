

import UIKit
import Firebase

class AlertShow: NSObject {

    class func show (inpView: UIViewController, titleStr: String, messageStr: String) {
        let alert = UIAlertController(title: titleStr,
                                      message: messageStr,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK",
                                      style: UIAlertActionStyle.default,
                                      handler: nil))
        inpView.present(alert,
                        animated: true,
                        completion: nil)
    }
    
    class func confirm (inpView: UIViewController, titleStr: String, messageStr: String, completion: @escaping () -> Void ) {
        let alert = UIAlertController(title: titleStr,
                                      message: messageStr,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Yes",
                                      style: UIAlertActionStyle.default,
                                      handler: {(action) -> Void in
                                        completion()
        }))
        
        alert.addAction(UIAlertAction(title: "No",
                                      style: UIAlertActionStyle.default,
                                      handler: nil ))
        inpView.present(alert,
                        animated: true,
                        completion: nil)
    }
    
    class func deny (inpView: UIViewController, titleStr: String, messageStr: String, completion: @escaping () -> Void ) {
        let alert = UIAlertController(title: titleStr,
                                      message: messageStr,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Yes",
                                      style: UIAlertActionStyle.default,
                                      handler: nil ))
        
        alert.addAction(UIAlertAction(title: "No",
                                      style: UIAlertActionStyle.default,
                                      handler: {(action) -> Void in
                                        completion()
        }))
        
        inpView.present(alert,
                        animated: true,
                        completion: nil)
    }
    
    class func respond (inpView: UIViewController, titleStr: String, messageStr: String, completion: @escaping (String) -> Void) {
        
        let alert = UIAlertController(title: titleStr, message: messageStr, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            
            let input = alert.textFields?[0].text
            guard input != nil else {return}

            completion(input!)
            
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alert.addTextField { (textField) in
            textField.placeholder = "Enter Username"
        }
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        inpView.present(alert,
                        animated: true,
                        completion: nil)
    }
    
    
}
