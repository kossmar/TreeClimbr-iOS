

import UIKit
import CoreGraphics

class PhotoFullScreenViewController: UIViewController {
   
    @IBOutlet weak var photoScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var imageArr = Array<UIImage>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let x = 0
        
        for image in imageArr {
            let imageView = UIImageView(image: image)

            let width = self.view.frame.width
            let frame:CGRect = CGRectMake((xPos * x), self.view.frame.origin.y , self.view.frame.width, self.view.frame.height)
            imageView.frame = frame
            photoScrollView.addSubview(imageView)
            
            x+=1
            
        }

    }
    
}
