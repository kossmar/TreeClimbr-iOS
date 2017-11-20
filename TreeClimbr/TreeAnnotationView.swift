

import UIKit
import MapKit

class TreeAnnotationView: MKAnnotationView {

    var treeAnnotation : TreeAnnotation?
    
    override convenience init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        self.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
