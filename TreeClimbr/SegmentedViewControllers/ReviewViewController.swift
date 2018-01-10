

import UIKit
import Firebase
import MessageUI

class ReviewViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, CommentMenuDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var addCommentButton: UIButton!

    
    var commentArr = [Comment]()
    
    var tree : Tree? {
        didSet {
            guard let tree = tree else { return }
            
            CommentManager.loadComments(tree: tree) { comments in
                guard let comments = comments else { return }
                self.commentArr = comments
                self.tableView.reloadData()
                self.commentArr.sort(by: { $0.timeStamp > $1.timeStamp })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addCommentButton.isEnabled = false
        setupTextView()

        tableView.delegate = self
        tableView.dataSource = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    //MARK: Actions
    
    @IBAction func addComment (_ sender: UIButton) {
        let comment = Comment(body: descTextView.text)
        CommentManager.saveComment(comment: comment, tree: self.tree!) { success in
            self.view.endEditing(true)
        }
        descTextView.text = "Enter comment..."
        descTextView.textColor = UIColor.lightGray
        addCommentButton.isEnabled = false
        CommentManager.loadComments(tree: tree!) { comments in
            guard let comments = comments else { return }
            self.commentArr = comments
            self.tableView.reloadData()
            self.commentArr.sort(by: { $0.timeStamp > $1.timeStamp })
        }
    }
    
    //MARK: TextView delegates
    
    func setupTextView() {
        descTextView.text = "Enter comment..."
        descTextView.textColor = UIColor.lightGray
        descTextView.delegate = self
        descTextView.layer.cornerRadius = descTextView.frame.width/50
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descTextView.textColor == UIColor.lightGray {
            descTextView.text = nil
            descTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if descTextView.text.isEmpty {
            descTextView.text = "Enter comment..."
            descTextView.textColor = UIColor.lightGray
            addCommentButton.isEnabled = false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if descTextView.text.isEmpty {
            addCommentButton.isEnabled = false
        } else {
            addCommentButton.isEnabled = true
        }
    }
    
    //MARK: TableView Delegate / Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CommentTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        
        cell.userLabel.text = commentArr[indexPath.row].username
        cell.timestampLabel.text = commentArr[indexPath.row].timeStamp
        cell.commentTextView.text = commentArr[indexPath.row].body
        cell.delegate = self
        cell.optionsButton.tag = indexPath.row
//        cell.optionsButton.addTarget(self, action: Selector(("commentOptionsPressed:")), for: UIControlEvents.touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let comment = commentArr[indexPath.row]
        
        if comment.userID == Auth.auth().currentUser?.displayName {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
 
            if editingStyle == UITableViewCellEditingStyle.delete {
                AlertShow.confirm(inpView: self, titleStr: "Delete Comment?", messageStr: " ", completion: {
                    CommentManager.deleteComment(tree: self.tree!, comment: self.commentArr[indexPath.row])
                    self.commentArr.remove(at: indexPath.row)
                    tableView.reloadData()
                })
            }
    }
    
    //MARK: Comment Menu Delegate
    
    func commentMenuPressed(senderTag: Int) {
        let buttonRow = senderTag
        let comment = commentArr[buttonRow]

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let reportAction = UIAlertAction(title: "Report", style: .default) { (report) in
            let mailComposeViewController = self.configuredMailComposeViewController(buttonRow: buttonRow)
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
            
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (delete) in
            AlertShow.confirm(inpView: self, titleStr: "Delete Comment?", messageStr: " ", completion: {
                CommentManager.deleteComment(tree: self.tree!, comment: self.commentArr[buttonRow])
                self.commentArr.remove(at: buttonRow)
                self.tableView.reloadData()
            })
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(reportAction)
        
        if comment.userID == Auth.auth().currentUser?.uid {
            alertController.addAction(deleteAction)
        }
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    // MARK: MFMailComposeViewController
    
    func configuredMailComposeViewController(buttonRow: Int) -> MFMailComposeViewController {
        let buttonRow = buttonRow
        let comment = commentArr[buttonRow]

        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["someone@somewhere.com"])
        mailComposerVC.setSubject("TreeClimbr - Inappropriate Content Report")
        mailComposerVC.setMessageBody("Found inappropriate content! \n\n Username: \n \(comment.username) \n\n UserID: \n \(comment.userID) \n\n Content: \n \(comment.body) \n\n CommentID: \n \(comment.commentID) \n ", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
//        let sendMailErrorAlert = UIAlertController(title: <#T##String?#>, message: <#T##String?#>, preferredStyle: . )
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
