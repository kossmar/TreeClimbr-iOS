

import UIKit
import CoreGraphics

class PhotoFullScreenViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var photoScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var imageArr = Array<UIImage>()
    var contentWidth : CGFloat = 0.0
    var startPage = Int()
    var justLoaded = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoScrollView.delegate = self
        pageControl.numberOfPages = imageArr.count
        navigationBar.isHidden = true
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showNavBar(sender:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
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
