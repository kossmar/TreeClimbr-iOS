

import UIKit

class AlertShow: NSObject {

    class func show (inpView: UIViewController, titleStr: String, messageStr: String)
    {
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
    
}
