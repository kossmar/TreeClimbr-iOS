import UIKit
import CoreLocation
import ImagePicker
import Firebase

protocol TreeNewDelegate {
    func treeSaved(tree: Tree)
}

class TreeNewViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate,UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UITextViewDelegate, ImagePickerDelegate {

    //MARK: Outlets
    
    @IBOutlet weak var treeImageView: UIImageView!
//    @IBOutlet weak var treeNameLabel: UILabel!
    @IBOutlet weak var treeNameTextField: UITextField!
    @IBOutlet weak var TreeDescTextView: UITextView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    //MARK: Properties
    let imagePickerController = ImagePickerController()
    
    var tree: Tree?
    var delegate: TreeNewDelegate?
    var imageArr = Array<UIImage>()
    var coordinate = CLLocationCoordinate2D()
    var sourceVC = UIViewController()
    
    var imageIsSet: Bool = false
    var titleIsSet: Bool = false
    var showAlert = true
    var fromMap: Bool = false
    var fromDetail: Bool = false

    
    //MARK: ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showAlert = true
        
        addPhotoButton.layer.cornerRadius = addPhotoButton.frame.height/4
        photoCollectionView.delegate = self

        setupTree()
        setupTextView()
        setup()
        canSaveTree()
        
        if fromMap == true {
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
            view.addGestureRecognizer(tap)
            
            setupTap()
        } else if fromDetail == true {
            navigationBar.topItem?.title = "Edit Tree"
            self.addPhotoButton.setTitle("Your buttons are no good here", for: .normal)
            addPhotoButton.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        AppUtility.lockOrientation(.portrait)

        
        canSaveTree()
        if tree == nil {
            if imageArr.count > 0 {
                treeImageView.image = imageArr[0]
                addPhotoButton.setTitle("Manage Photos", for: .normal)
            } else {
                addPhotoButton.setTitle("Add Photos", for: .normal)
                saveButton.isEnabled = false
            }
        }

        photoCollectionView.reloadData()
        

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if ( Auth.auth().currentUser == nil && self.showAlert == true ) {
            AlertShow.confirm(inpView: self, titleStr: "Account Required", messageStr: "Would you like to sign in?", completion: {
                self.showAlert = false
                self.performSegue(withIdentifier: "toSignUp", sender: self)
            })
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all)

    }

    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    //MARK: VC buttons
    @IBAction func addPhoto(_ sender: UIButton) {
        pickTreePhotos()
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        

        
        self.saveButton.isEnabled = false
        let charset = CharacterSet(charactersIn: "$.[]#")
        
        if treeNameTextField.text!.rangeOfCharacter(from: charset) != nil {
            treeNameTextField.text! = ""
            AlertShow.show(inpView: self, titleStr: "Oops!", messageStr: "A tree's name cannot contain the following characters: \n & . [ ] # ")
        } else {
            
            let photoData = treeImageView.image?.jpeg(.low)
            
            if fromDetail == true {
                guard let tree = tree else {return}
                tree.treeName = treeNameTextField.text!
                tree.treeDescription = TreeDescTextView.text
                TreeManager.updateTree(tree: tree, completion: { (updated) in
                    self.delegate?.treeSaved(tree: tree)
                  self.dismiss(animated: true, completion: nil)
                })
            } else {
                
                let lat = coordinate.latitude
                let long = coordinate.longitude
                
                guard let curUser = Auth.auth().currentUser else {return}
                
                let tree = Tree(name: treeNameTextField.text!, description: TreeDescTextView.text, treeLat: lat, treeLong: long, photo: photoData! as NSData)
                tree.treeCreator = curUser.uid
                tree.treeCreatorName = curUser.displayName!
                
                ImageUploader.createNewPhotos(images: self.imageArr, tree: tree) { (photos, firstPhoto) in
                    
                    PhotoManager.savePhotos(photos: photos, tree: tree) { success in
                        print("winners")
                        
                        TreeManager.saveTree(tree: tree, coverPhoto: firstPhoto, completion: { success in
                            self.dismiss(animated: true) {
                                self.sourceVC.reloadInputViews()
                            }
                        })
                    }
                }
            }
            
            if TreeDescTextView.textColor == UIColor.lightGray {
                TreeDescTextView.text = nil
            }
        }
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: ImagePicker
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imageArr = images
        imageIsSet = true
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddPhotoCell", for: indexPath) as! BasicPhotoCollectionViewCell
        
        let photo = imageArr[indexPath.row]
        cell.treePhotoImageView.image = photo
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellSize = CGSize(width: collectionView.frame.size.height , height: collectionView.frame.size.height )
        
        return cellSize
    }
    
    
    func setup() {
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        imagePickerController.delegate = self
        TreeDescTextView.delegate = self
        treeNameTextField.delegate = self
        }
    
    //MARK: Prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let signUpVC = segue.destination as! SignUpViewController
        signUpVC.sourceVC = self
        signUpVC.fromTreeNew = true
        
    }
    
    //MARK: Tap gestures
    func setupTap() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(tapGestureRecognizer:)))
        treeImageView.isUserInteractionEnabled = true
        treeImageView.addGestureRecognizer(tapGestureRecognizer)
        
        let tapGestureRecognizerCollectionView = UITapGestureRecognizer(target: self, action: #selector(collectionViewTapped(tapGestureRecognizerCollectionView:)))
        photoCollectionView.addGestureRecognizer(tapGestureRecognizerCollectionView)
    }
    
    @objc func imageViewTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        pickTreePhotos()
    }
    
    @objc func collectionViewTapped(tapGestureRecognizerCollectionView: UITapGestureRecognizer) {
         pickTreePhotos()
    }
    
    
    func pickTreePhotos() {
        present(imagePickerController, animated: true, completion: nil)
        imagePickerController.imageLimit = 5
    }
    
    //MARK: Textview delegate
    func setupTextView() {
        
        if tree == nil {
            TreeDescTextView.text = "Enter description..."
            TreeDescTextView.textColor = UIColor.lightGray
        } else {
            TreeDescTextView.text = tree?.treeDescription
        }
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

        if treeNameTextField.text!.isEmpty {
            titleIsSet = false
        } else {
            titleIsSet = true
        }
        canSaveTree()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = treeNameTextField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        return updatedText.count <= 40
    }

    //MARK: Custom Functions
    
    private func canSaveTree() {
        if fromMap == true {
            if imageIsSet == true && titleIsSet == true {
                saveButton.isEnabled = true
            } else {
                saveButton.isEnabled = false
            }
        } else {
            if titleIsSet == true {
                saveButton.isEnabled = true
            }
        }
    }
    
    private func setupTree() {
        if tree != nil {
            treeNameTextField.text = tree?.treeName
            let url = tree?.treePhotoURL
            treeImageView.sd_setImage(with: url,
                                      completed: { (image, error, cacheType, url) in
                                        print("\(String(describing: image)), \(String(describing: error)), \(cacheType), \(String(describing: url))")
            })
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
