//
//  TreeNewViewController.swift
//  TreeClimbr
//
//  Created by Carlo Namoca on 2017-11-17.
//  Copyright © 2017 Mar Koss. All rights reserved.
//

import UIKit
import CoreLocation

class TreeNewViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var treeImageView: UIImageView!
    @IBOutlet weak var treeNameLabel: UILabel!
    @IBOutlet weak var treeNameTextField: UITextField!
    @IBOutlet weak var TreeDescTextView: UITextView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    let imagePickerController = UIImagePickerController()
    var photoArr = Array<UIImage>()
    var coordinate = CLLocationCoordinate2D()
    var sourceVC = ViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up imageview shape
        treeImageView.layer.cornerRadius = treeImageView.frame.width/2
        treeImageView.clipsToBounds = true
        
        TreeDescTextView.layer.cornerRadius = TreeDescTextView.frame.width/50
        
        setupTap()
        setup()
        
        
    }
    
    //MARK: VC buttons
    @IBAction func addPhoto(_ sender: UIButton) {
        imagePickerController.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
        // add photo should go to collection view
    }
    
    @IBAction func save(_ sender: UIButton) {
//        let photoData = UIImagePNGRepresentation(treeImageView.image!) as NSData?
        let photoData = treeImageView.image?.jpeg(.low)
        
        let lat = coordinate.latitude
        let long = coordinate.longitude
        
        let tree = Tree(name: treeNameTextField.text!, description: TreeDescTextView.text, treeLat: lat, treeLong: long, photo: photoData! as NSData)
        
        
//        let treesArr = AppData.sharedInstance.treesArr
        
        SaveTree.saveTree(tree: tree, completion: {
//            ReadTrees.read {
//                for tree in treesArr{
//                    let treeLat = tree.treeLatitude
//                    let treeLong = tree.treeLongitude
//                    let treeAnn : TreeAnnotation = TreeAnnotation()
//                    treeAnn.coordinate = CLLocationCoordinate2DMake(treeLat, treeLong)
//                    treeAnn.title = tree.treeName
//                    treeAnn.tree = tree
//                    self.sourceVC.mapView.addAnnotation(treeAnn)
//                }
//            }
        })
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Collection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddPhotoCell", for: indexPath)
        return cell
    }
    
    func setup() {
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        imagePickerController.delegate = self //as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
    }
    
    //MARK: Tap gestures
    func setupTap() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(tapGestureRecognizer:)))
        treeImageView.isUserInteractionEnabled = true
        treeImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func imageViewTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        imagePickerController.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            treeImageView.contentMode = .scaleToFill
            treeImageView.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Textfield delegte
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        treeNameTextField.resignFirstResponder()
        return true
    }
    
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
    
}
