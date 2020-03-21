

import UIKit
import MapKit

class TreeAnnotation: NSObject, MKAnnotation {
    var coordinate = CLLocationCoordinate2D()
    var title: String?
    var subtitle: String?
    var tree : Tree!
    
}
