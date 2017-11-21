
import UIKit

class BasicTreeTableViewCell: UITableViewCell {
    @IBOutlet weak var basicTreeInfoView: BasicTreeInfoView!
    
    var tree : Tree!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
