//
//  ReviewViewController.swift
//  TreeClimbr
//
//  Created by Carlo Namoca on 2017-11-21.
//  Copyright © 2017 Mar Koss. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var addCommentButton: UIButton!
    
    var commentArr = [Comment]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addCommentButton.isEnabled = false
        setupTextView()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func addComment (_ sender: UIButton) {
        //Add review
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
    
    //MARK: TableView delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CommentTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        
        cell.userLabel.text = commentArr[indexPath.row].userID
        cell.timestampLabel.text = "some random time"
        cell.commentTextView.text = commentArr[indexPath.row].body
        
        return cell
    }
    
}
