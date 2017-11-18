

import UIKit

class ReadWrite: NSObject {

    static let docsURL = try! FileManager.default.url(for: .documentDirectory,
                                                      in: .userDomainMask,
                                                      appropriateFor: nil,
                                                      create: true)
    // docsURL/data.plist
    static let userPath = docsURL.appendingPathComponent("user.plist").path
    
    
    class func writeUser ()
    {
        print(userPath)
        NSKeyedArchiver.archiveRootObject(AppData.sharedInstance.curUser!,
                                          toFile: userPath)
    }
    
    class func readUser ()
    {
        if let readUser = NSKeyedUnarchiver.unarchiveObject(withFile: userPath)
            as? User
        {
            AppData.sharedInstance.curUser = readUser
        }
    }
    
}
