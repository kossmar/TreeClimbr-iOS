//
//  TreeAnnotationView.swift
//  TreeClimbr
//
//  Created by Mar Koss on 2017-11-19.
//  Copyright © 2017 Mar Koss. All rights reserved.
//

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
