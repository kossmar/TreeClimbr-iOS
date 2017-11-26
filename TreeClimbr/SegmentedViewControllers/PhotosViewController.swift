import UIKit
import ImagePicker

class PhotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ImagePickerDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var uploadPhotosButton: UIButton!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    var tree : Tree?
 //   var photosArr = Array<Photo>()
    var imageArr = Array<UIImage>()
    var moreImagesArr = Array<UIImage>()
    let imagePickerController = ImagePickerController()
    
    
    //MARK: View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        photoCollectionView.delegate = self
        
        moreImagesArr = []
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if moreImagesArr.isEmpty {
            uploadPhotosButton.isHidden = true
        } else {
            uploadPhotosButton.isHidden = false
        }
    }
    
    // MARK: - CollectionView DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.imageArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "basicPhotoCell", for: indexPath) as! BasicPhotoCollectionViewCell
        let photo = self.imageArr[indexPath.row]
        cell.treePhotoImageView.image = photo
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //MARK: Collection view layout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellSize = CGSize(width: collectionView.frame.size.width/2 - 5, height: collectionView.frame.size.width/2 - 5)
        
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    
    //MARK: Actions
    
    @IBAction func addPhotoButtonPressed(_ sender: UIButton) {
        if moreImagesArr.count > 0 {
            let counter = moreImagesArr.count
            imageArr.removeLast(counter)
        }

        pickTreePhotos()
    }
    
    
    @IBAction func uploadPhotosButtonPressed(_ sender: UIButton) {
        uploadPhotosButton.isHidden = true
        imageArr = []
        
                ImageUploader.createNewPhotos(images: self.moreImagesArr, tree: self.tree!) { (photos) in
        
                    PhotoManager.savePhotos(photos: photos, tree: self.tree!) { success in
                        print("winners")
        
                    }
                }
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
        }
        
        photoCollectionView.reloadData()
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
}
