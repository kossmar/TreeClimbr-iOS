

import UIKit
import Firebase
import MessageUI

class CommentViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, CommentMenuDelegate, MFMailComposeViewControllerDelegate, VerifyUserDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var addCommentButton: UIButton!
    let sourceVC = TreeDetailViewController()

    
    var commentArr = [Comment]()
    
    var tree : Tree? {
        didSet {
            guard let tree = tree else { return }
            
            CommentManager.loadComments(tree: tree) { comments in
                guard let comments = comments else { return }
                self.commentArr = HiddenUsersManager.hideBlockedUsersComments(array: comments)
                self.commentArr.sort(by: { $0.timeStamp > $1.timeStamp })
                self.tableView.reloadData()
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
        
        if ( Auth.auth().currentUser == nil ) {
            UserDefaults.standard.set(self.descTextView.text, forKey: "commentBody")
            AlertShow.confirm(inpView: self, titleStr: "Account Required", messageStr: "Would you like to sign in?", completion: {
                self.performSegue(withIdentifier: "commentToSignUp", sender: self)
                return
            })
        }
        
        let comment = Comment(body: descTextView.text)
        self.saveComment(comment: comment)
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
    
    //MARK: Prepare For Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let signUpVC = segue.destination as! SignUpViewController
        signUpVC.delegate = self
        signUpVC.sourceVC = self 
    }
    
    //MARK: CommentMenu Delegate
    
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
        
        let blockAction = UIAlertAction(title: "Block", style: .default) { (block) in
            let badUser =  User(name: comment.username, email: "", uid: comment.userID)
            AlertShow.confirm(inpView: self, titleStr: "Block \(comment.username)?", messageStr: "You won't see \(comment.username)'s trees, photos and comments anymore.", completion: {
                AppData.sharedInstance.hiddenUsersArr.append(badUser)
                HiddenUsersManager.addToHiddenUsersList(badUser: badUser, completion: {_ in
                    
                })
                
                if badUser.uid == self.tree!.treeCreator {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.commentArr = HiddenUsersManager.hideBlockedUsersComments(array: self.commentArr)
                    self.tableView.reloadData()
                }
            }
            )}
        
        alertController.addAction(cancelAction)
        alertController.addAction(reportAction)
        alertController.addAction(blockAction)
        
        if comment.userID == Auth.auth().currentUser?.uid {
            alertController.addAction(deleteAction)
        }
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    //MARK: VerifyUserDelegate
    
    func verificationComplete() {
        let commentBody = UserDefaults.standard.string(forKey: "commentBody")
        if let commentTrue = commentBody {
            let comment = Comment(body: commentTrue)
            self.saveComment(comment: comment)
        }
    }
    
    // MARK: MFMailComposeViewController
    
    func configuredMailComposeViewController(buttonRow: Int) -> MFMailComposeViewController {
        let buttonRow = buttonRow
        let comment = commentArr[buttonRow]

        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["treeclimbrcontact@gmail.com"])
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
    
    //MARK: Custom Functions
    
    func saveComment(comment: Comment) {
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
    
}
