import UIKit
import CoreLocation
import ImagePicker
import Firebase

class TreeNewViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, ImagePickerDelegate {

    //MARK: Outlets
    
    @IBOutlet weak var treeImageView: UIImageView!
//    @IBOutlet weak var treeNameLabel: UILabel!
    @IBOutlet weak var treeNameTextField: UITextField!
    @IBOutlet weak var TreeDescTextView: UITextView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var saveButton: UIButton!
    
    //MARK: Properties
    let imagePickerController = ImagePickerController()
    
    var imageArr = Array<UIImage>()
    var coordinate = CLLocationCoordinate2D()
    var sourceVC = ViewController()

    
    //MARK: ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up imageview shape
        treeImageView.layer.cornerRadius = treeImageView.frame.width/2

        treeImageView.clipsToBounds = true

        saveButton.isEnabled = false
        setupTextView()
        setupTap()
        setup()
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if imageArr.count > 0 {
            treeImageView.image = imageArr[0]
        }
        
        photoCollectionView.reloadData()
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    //MARK: VC buttons
    @IBAction func addPhoto(_ sender: UIButton) {
        pickTreePhotos()
    }
    
    @IBAction func save(_ sender: UIButton) {

        
        let photoData = treeImageView.image?.jpeg(.low)
        
        let lat = coordinate.latitude
        let long = coordinate.longitude
        
        let tree = Tree(name: treeNameTextField.text!, description: TreeDescTextView.text, treeLat: lat, treeLong: long, photo: photoData! as NSData)
        
        SaveTree.saveTree(tree: tree, completion: { success in
             self.dismiss(animated: true, completion: nil)
            
            ImageUploader.createNewPhotos(images: self.imageArr, tree: tree) { (photos) in
                
                PhotoManager.savePhotos(photos: photos, tree: tree) { success in
                    print("winners")
                    
                }
            }
            
        })
        
        


        if TreeDescTextView.textColor == UIColor.lightGray {
            TreeDescTextView.text = nil
        }
        
        dismiss(animated: true, completion: nil)

    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: ImagePicker
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imageArr = images
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Collection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddPhotoCell", for: indexPath) as! BasicPhotoCollectionViewCell
        
        let photo = imageArr[indexPath.row]
        cell.treePhotoImageView.image = photo
        
        return cell
    }
    
    func setup() {
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        imagePickerController.delegate = self
        TreeDescTextView.delegate = self
        treeNameTextField.delegate = self
    }
    
    //MARK: Tap gestures
    func setupTap() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(tapGestureRecognizer:)))
        treeImageView.isUserInteractionEnabled = true
        treeImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func imageViewTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        pickTreePhotos()
    }
    
    func pickTreePhotos() {
        present(imagePickerController, animated: true, completion: nil)
        imagePickerController.imageLimit = 5
    }
    
    //MARK: Textview delegate
    func setupTextView() {
        TreeDescTextView.text = "Enter description..."
        TreeDescTextView.textColor = UIColor.lightGray
        TreeDescTextView.layer.cornerRadius = TreeDescTextView.frame.width/50
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if TreeDescTextView.textColor == UIColor.lightGray {
            TreeDescTextView.text = nil
            TreeDescTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if TreeDescTextView.text.isEmpty {
            TreeDescTextView.text = "Enter description..."
            TreeDescTextView.textColor = UIColor.lightGray
        }
    }
    
    //MARK: Textfield delegte
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        treeNameTextField.resignFirstResponder()
        return true
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        if treeNameTextField.text!.isEmpty{
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
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
