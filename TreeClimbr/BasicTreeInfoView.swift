
import UIKit
import Firebase

class BasicTreeInfoView: UIView {
    
    @IBOutlet weak var alphaView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var treeNameLabel: UILabel!
    @IBOutlet weak var whiteView: UIView!
    

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var treeImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!

    @IBOutlet weak var favouritesCountLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func prepareForInterfaceBuilder()
    {
        // Called when view is live rendered on Storyboard
        super.prepareForInterfaceBuilder()
        commonInit()
    }
    
    private func commonInit() {
        setupFromXib()
    }
    
    private func setupFromXib() {
        
        if self.subviews.count == 0
        {
            let bundle = Bundle(for: type(of: self))
            let nib = UINib(nibName: "BasicTreeInfoView", bundle: bundle)
            guard let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView else {
                assertionFailure("Unable to load XIB file for ReusableView")
                return
            }
            
            contentView = view
            contentView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(contentView)
            contentView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            contentView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            
            alphaView.backgroundColor = UIColor.clear
            let mask = CAGradientLayer()
            mask.endPoint = CGPoint(x: 0.0, y: 0.0)
            mask.startPoint = CGPoint(x: 1.0, y:  0.0)
            let whiteColor = UIColor.white
            
            mask.colors = [whiteColor.withAlphaComponent(0.0).cgColor,
//                           whiteColor.withAlphaComponent(0.2).cgColor,
//                           whiteColor.withAlphaComponent(0.5).cgColor,
                           whiteColor.withAlphaComponent(1.0).cgColor]
            
            mask.locations = [NSNumber(value: 0.50),
//                              NSNumber(value: 0.4),
//                              NSNumber(value: 0.65),
                              NSNumber(value: 0.9)]
            mask.frame = whiteView.bounds
            whiteView.layer.mask = mask
            
//            alphaView.layer.cornerRadius = alphaView.frame.width/2

        }
    }
    
}
