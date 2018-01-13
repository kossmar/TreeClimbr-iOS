

import UIKit
import CoreGraphics
import Firebase
import MessageUI

class PhotoFullScreenViewController: UIViewController, UIScrollViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var photoScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var leftBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    
    var imageArr = Array<UIImage>()
    var contentWidth : CGFloat = 0.0
    var startPage = Int()
    var justLoaded = true
    var photoObjArr = Array<Photo>()
    var sourceVC = PhotosViewController()
    var canDelete = Bool()
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoScrollView.delegate = self
        pageControl.numberOfPages = photoObjArr.count
        navigationBar.isHidden = true
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = UIColor(red: 189.0/225.0, green: 239.0/225.0, blue: 191.0/225.0, alpha: 0.85)
        
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showNavBar(sender:)))
        self.view.addGestureRecognizer(tapGesture)
        
        leftBarButtonItem.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: 20)!], for: UIControlState.normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if pageControl.currentPage < photoObjArr.count {
            let photo = photoObjArr[pageControl.currentPage]
            navigationBar.topItem?.title = photo.userName
            if Auth.auth().currentUser?.uid == photo.userID {
                canDelete = true
            }
        } else {
            navigationBar.topItem?.title = Auth.auth().currentUser?.displayName
            
        }
        
        rightBarButtonItem.isEnabled = true
        
    }
    
    override func viewDidLayoutSubviews() {
        self.setupScrollView()
    }
    
    
    
    
    // MARK: - ScrollViewDelegate functions
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = (Int(photoScrollView.contentOffset.x / photoScrollView.frame.width))
        if pageControl.currentPage < photoObjArr.count {
            let photo = photoObjArr[pageControl.currentPage]
            navigationBar.topItem?.title = photo.userName
            
            rightBarButtonItem.isEnabled = true
//            rightBarButtonItem.tintColor = UIColor(red: 183.0/225.0, green: 20.0/225.0, blue: 20.0/225.0, alpha: 1.0)
            rightBarButtonItem.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: 20)!], for: UIControlState.normal)
            
        } else {
            navigationBar.topItem?.title = Auth.auth().currentUser?.displayName
        }
        
    }
    
    
    // MARK: - Actions
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func menuButtonPressed(_ sender: UIBarButtonItem) {
        
        let photo = photoObjArr[pageControl.currentPage]
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let reportAction = UIAlertAction(title: "Report", style: .default) { (report) in

            let mailComposeViewController = self.configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        }
        let blockAction = UIAlertAction(title: "Block", style: .default) { (block) in
            let photo = self.photoObjArr[self.pageControl.currentPage]
            let badUser =  User(name: photo.userName, email: "", uid: photo.userID)
            AlertShow.confirm(inpView: self, titleStr: "Block \(photo.userName)?", messageStr: "You won't see \(photo.userName)'s trees, photos and comments anymore.", completion: {
                AppData.sharedInstance.hiddenUsersArr.append(badUser)
//                self.photoObjArr.remove(at: self.pageControl.currentPage)
//                self.sourceVC.photoObjArr.remove(at: self.pageControl.currentPage)
                self.sourceVC.photoCollectionView.reloadData()
                HiddenUsersManager.addToHiddenUsersList(badUser: badUser, completion: {_ in
                })
                self.dismiss(animated: true, completion: {
                    if badUser.uid == self.sourceVC.tree!.treeCreator {
                        self.sourceVC.dismiss(animated: true, completion: nil)
                    }
                })
            }
            )}
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (delete) in
            if self.canDelete == true {
                AlertShow.confirm(inpView: self, titleStr: "Delete photo?", messageStr: " ") {
                    let photo = self.photoObjArr[self.pageControl.currentPage]
                    if self.pageControl.numberOfPages > 1 {
                        if self.pageControl.currentPage != 0 {
                            self.pageControl.currentPage = (self.pageControl.currentPage) - 1
                            self.setupScrollView()
                            self.photoObjArr.remove(at: (self.pageControl.currentPage) + 1)
                            self.sourceVC.photoObjArr.remove(at: (self.pageControl.currentPage) + 1)
                        } else {
                            self.pageControl.currentPage = (self.pageControl.currentPage) + 1
                            self.setupScrollView()
                            self.photoObjArr.remove(at: (self.pageControl.currentPage) - 1)
                            self.sourceVC.photoObjArr.remove(at: (self.pageControl.currentPage) - 1)
                        }
                        self.pageControl.numberOfPages = self.photoObjArr.count
                        self.setupScrollView()
                        
                        
                    } else {
                        self.photoObjArr.remove(at: self.pageControl.currentPage)
                        self.sourceVC.photoObjArr.remove(at: self.pageControl.currentPage)
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    PhotoManager.deletePhoto(photo: photo, tree: self.sourceVC.tree!)
                    
                }
                
            }
        }
        
        alertController.addAction(cancelAction)
        
        if self.canDelete == true {
            alertController.addAction(deleteAction)
        } else {
            alertController.addAction(reportAction)
            alertController.addAction(blockAction)
        }
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    // MARK: MFMailComposeViewController
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {

        let photo = photoObjArr[pageControl.currentPage]
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["treeclimbrcontact@gmail.com"])
        mailComposerVC.setSubject("TreeClimbr - Inappropriate Content Report")
        mailComposerVC.setMessageBody("Found inappropriate content! \n\n Username: \n \(photo.userName) \n\n PhotoID: \n \(photo.photoID) \n\n", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Custom Functions
    
    @objc func showNavBar(sender: UITapGestureRecognizer) {
        if navigationBar.isHidden == true {
            UIView.animate(withDuration: 0.5, animations: {
                self.navigationBar.isHidden = false
                self.navigationBar.barTintColor = UIColor.white.withAlphaComponent(0.3)
                
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.navigationBar.isHidden = true
            })
        }
    }
    
    func setupScrollView() {
        let width = self.view.frame.width
        
        if justLoaded == true {
            photoScrollView.contentOffset.x = width * CGFloat(startPage)
        } else {
            photoScrollView.contentOffset.x = width * CGFloat(pageControl.currentPage)
        }
        
        var x: CGFloat = 0
        contentWidth = 0
        
        let subviews = photoScrollView.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
        
        for photo in photoObjArr {
            let imageView = UIImageView(image: photo.image)
            
            let frame = CGRect(x: (width * x), y: self.view.frame.origin.y, width: self.view.frame.width, height: photoScrollView.frame.height)
            imageView.frame = frame
            imageView.contentMode = .scaleAspectFit
            photoScrollView.addSubview(imageView)
            
            contentWidth += view.frame.width
            x+=1
        }
        photoScrollView.contentSize = CGSize(width: contentWidth, height: view.frame.height)
        justLoaded = false
    }
    
}
