

import UIKit
import CoreGraphics
import Firebase

class PhotoFullScreenViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var photoScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var leftBarButtonItem: UIBarButtonItem!
    
    var imageArr = Array<UIImage>()
    var contentWidth : CGFloat = 0.0
    var startPage = Int()
    var justLoaded = true
    var photoObjArr = Array<Photo>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoScrollView.delegate = self
        pageControl.numberOfPages = imageArr.count
        navigationBar.isHidden = true
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
//        navigationBar.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        navigationBar.backgroundColor = UIColor(red: 189.0/225.0, green: 239.0/225.0, blue: 191.0/225.0, alpha: 0.85)

//        rgb(11, 124, 15)
//        rgb(189, 239, 191)


        
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
        } else {
            navigationBar.topItem?.title = Auth.auth().currentUser?.displayName
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.setupScrollView()
    }
    
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - ScrollViewDelegate functions
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = (Int(photoScrollView.contentOffset.x / photoScrollView.frame.width))
        if pageControl.currentPage < photoObjArr.count {
            let photo = photoObjArr[pageControl.currentPage]
            navigationBar.topItem?.title = photo.userName
        } else {
            navigationBar.topItem?.title = Auth.auth().currentUser?.displayName
        }

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
        
        for image in imageArr {
            let imageView = UIImageView(image: image)
            
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
