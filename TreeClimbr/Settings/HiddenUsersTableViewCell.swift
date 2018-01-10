
import UIKit

protocol HiddenUserDelegate {
    func unblockUser(senderTag: Int)
}

class HiddenUsersTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var unblockButton: UIButton!
    var delegate: HiddenUserDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    //MARK: Actions
    
    @IBAction func unblockPressed(_ sender: UIButton) {
        self.delegate?.unblockUser(senderTag: sender.tag)
    }
    

}
