

import UIKit

class HiddenUsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HiddenUserDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK: Tableview Delegate / Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppData.sharedInstance.hiddenUsersArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : HiddenUsersTableViewCell = tableView.dequeueReusableCell(withIdentifier: "HiddenUsersCell", for: indexPath) as! HiddenUsersTableViewCell
        
        cell.usernameLabel.text = AppData.sharedInstance.hiddenUsersArr[indexPath.row].name
        cell.delegate = self
        cell.unblockButton.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    //MARK: Custom Functions
    
    func unblockUser(senderTag: Int) {
        
        let blockedUser = AppData.sharedInstance.hiddenUsersArr[senderTag]
        AlertShow.confirm(inpView: self, titleStr: "Unblock \(blockedUser.name)?", messageStr: "\(blockedUser.name)'s trees, photos and comments will be visible to you again.", completion: {
            
            HiddenUsersManager.removeFromHidden(badUser: blockedUser) { (true) in
                for user in AppData.sharedInstance.hiddenUsersArr {
                    if user.uid == blockedUser.uid {
                        let index = AppData.sharedInstance.hiddenUsersArr.index(of: user)
                        AppData.sharedInstance.hiddenUsersArr.remove(at: index!)
                    }
                }
                self.tableView.reloadData()
                
            }
        })
    }
    
}
