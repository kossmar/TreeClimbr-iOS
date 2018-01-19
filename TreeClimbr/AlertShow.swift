

import UIKit

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
    
}
