
import UIKit

class BasicTreeInfoView: UIView {
    
    @IBOutlet var contentView: UIView!
    
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
//        Bundle.main.loadNibNamed("BasicTreeInfoView", owner: self, options: nil)
//        addSubview(contentView)
//        contentView.frame = self.bounds
//        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
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
            
        }
    }
    
}
