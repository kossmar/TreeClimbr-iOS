//
//  AboutViewController.swift
//  TreeClimbr
//
//  Created by Carlo Namoca on 2017-11-21.
//  Copyright © 2017 Mar Koss. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var treeDescTextView: UITextView!
    @IBOutlet weak var coordinateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        treeDescTextView.isEditable = false
        userLabel.text = "USER"
        coordinateLabel.text = "-123.97236429734, -30.97236429734"
    }


}
