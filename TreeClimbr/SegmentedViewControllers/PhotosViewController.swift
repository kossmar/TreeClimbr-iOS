import UIKit
import ImagePicker
import Firebase

class PhotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ImagePickerDelegate, UICollectionViewDelegateFlowLayout, VerifyUserDelegate {
    


    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var uploadPhotosButton: UIButton!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    var tree : Tree?
 //   var photosArr = Array<Photo>()
    var imageArr = Array<UIImage>()
    var moreImagesArr = Array<UIImage>()
    let imagePickerController = ImagePickerController()
    let flowLayout = UICollectionViewFlowLayout()
    var photoObjArr = Array<Photo>()
    
    
    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        photoCollectionView.delegate = self
        moreImagesArr = []

        addPhotoButton.layer.cornerRadius = addPhotoButton.frame.height/4
        uploadPhotosButton.layer.cornerRadius = uploadPhotosButton.frame.height/4

//        uploadPhotosButton.backgroundColor = UIColor.clear.withAlphaComponent(0.7)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if moreImagesArr.isEmpty {
            uploadPhotosButton.isHidden = true
            addPhotoButton.setTitle("Add Photos", for: .normal)
        } else {
            uploadPhotosButton.isHidden = false
            addPhotoButton.setTitle("Manage Photos", for: .normal)
        }
    }
    
    // MARK: - CollectionView DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.photoObjArr = HiddenUsersManager.hideBlockedUsersPhotos(array: self.photoObjArr)
        return self.photoObjArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "basicPhotoCell", for: indexPath) as! BasicPhotoCollectionViewCell
        if indexPath.item < self.photoObjArr.count {
            let photo = self.photoObjArr[indexPath.row]
            cell.treePhotoImageView.image = photo.image
        } else {
            let image = self.imageArr[indexPath.row]
            cell.treePhotoImageView.image = image
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // MARK: - Collection view layout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellSize = CGSize(width: collectionView.frame.size.width/2 - 1 , height: collectionView.frame.size.width/2 - 1 )
        
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "toFullScreen", sender: indexPath.row)
    }
    
    // MARK: - Prepare for Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toFullScreen" {
            
            let fullScreenVC = segue.destination as! PhotoFullScreenViewController
            let startPage = sender as! Int
            fullScreenVC.startPage = startPage
            fullScreenVC.imageArr = self.imageArr
            fullScreenVC.photoObjArr = self.photoObjArr
            fullScreenVC.sourceVC = self
        }
        
        if segue.identifier == "photoToSignUp" {
            let signUpVC = segue.destination as! SignUpViewController
            signUpVC.delegate = self
            signUpVC.sourceVC = self
        }
        
    }
    
    //MARK: VerifyUserDelegate
    
    func verificationComplete() {
        
        pickTreePhotos()
        
    }
    
    
    // MARK: - Actions
    
    @IBAction func addPhotoButtonPressed(_ sender: UIButton) {
        
        if ( Auth.auth().currentUser == nil ) {
            AlertShow.confirm(inpView: self, titleStr: "Account Required", messageStr: "Would you like to sign in?", completion: {
                self.performSegue(withIdentifier: "photoToSignUp", sender: self)
            })
        }
        
        if moreImagesArr.count > 0 {
            let counter = moreImagesArr.count
            imageArr.removeLast(counter)
        }

        pickTreePhotos()
    }
    
    
    @IBAction func uploadPhotosButtonPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Upload pictures?", message: nil, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancelAction)
        
        let uploadAction = UIAlertAction(title: "Upload", style: .default) { (action) in
            self.uploadPhotosButton.isHidden = true
            self.addPhotoButton.setTitle("Add Photos", for: .normal)
            self.imagePickerController.resetAssets()
            
            ImageUploader.createNewPhotos(images: self.moreImagesArr, tree: self.tree!) { (photos) in
                
                PhotoManager.savePhotos(photos: photos, tree: self.tree!) { success in
                    print("winners")
                    self.moreImagesArr = []
                }
            }
        }
        alert.addAction(uploadAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func pickTreePhotos() {
        present(imagePickerController, animated: true, completion: nil)
        imagePickerController.imageLimit = 5
    }
    
    //MARK: ImagePicker
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        moreImagesArr = images
        
        for image in moreImagesArr {
            imageArr.append(image)
            let photo = Photo(URL: "null")
            photo.image = image
            photo.userName = (Auth.auth().currentUser?.displayName)! + " (unsaved)"
            photoObjArr.insert(photo, at: 0)
        }
        
        photoCollectionView.reloadData()
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        self.moreImagesArr = []
        for photo in photoObjArr {
            if photo.photoURL == "null" {
                if let index = photoObjArr.index(of: photo) {
                photoObjArr.remove(at: index)
                }
            }
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
