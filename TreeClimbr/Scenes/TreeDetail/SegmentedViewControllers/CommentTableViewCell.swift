

import UIKit

protocol CommentMenuDelegate {
    func commentMenuPressed(senderTag: Int)
}

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentInfoView: UIView!
    @IBOutlet weak var commentTextTopView: UIView!
    @IBOutlet weak var optionsButton: UIButton!
    var delegate: CommentMenuDelegate?
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        commentTextView.isEditable = false
        commentInfoView.layer.cornerRadius = commentInfoView.frame.height/4
        commentTextTopView.layer.cornerRadius = commentTextTopView.frame.height/8
        
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when){
            self.commentTextView.contentOffset.y = 0
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: Actions
    
    @IBAction func commentOptionsPressed(_ sender: UIButton) {
     
        let buttonRow = sender.tag
        self.delegate?.commentMenuPressed(senderTag: buttonRow)
    }
    
    
    
    
    

}
