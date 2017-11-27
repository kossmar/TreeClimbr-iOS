

import UIKit
import CoreGraphics

class PhotoFullScreenViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var photoScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var imageArr = Array<UIImage>()
    var contentWidth : CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoScrollView.delegate = self
        
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
//        pageControl.currentPage = (photoScrollView.contentOffset / CGFloat(414))
    }
    
    
    // MARK: - Custom Functions
    
    func setupScrollView() {
        var x: CGFloat = 0
        
        let subviews = photoScrollView.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
        
        for image in imageArr {
            let imageView = UIImageView(image: image)
            
            let width = self.view.frame.width
            let frame = CGRect(x: (width * x), y: self.view.frame.origin.y, width: self.view.frame.width, height: photoScrollView.frame.height)
            imageView.frame = frame
            imageView.contentMode = .scaleAspectFit
            photoScrollView.addSubview(imageView)
            //            imageView.translatesAutoresizingMaskIntoConstraints = false
            //            imageView.leadingAnchor.constraint(equalTo: photoScrollView.leadingAnchor, constant: 0).isActive = true
            //            imageView.trailingAnchor.constraint(equalTo: photoScrollView.trailingAnchor, constant: 0).isActive = true
            //            imageView.bottomAnchor.constraint(equalTo: photoScrollView.bottomAnchor, constant: 0).isActive = true
            //            imageView.topAnchor.constraint(equalTo: photoScrollView.topAnchor, constant: 0).isActive = true
            
            
            contentWidth += view.frame.width
            x+=1
        }
        photoScrollView.contentSize = CGSize(width: contentWidth, height: view.frame.height)

    }
    
}
