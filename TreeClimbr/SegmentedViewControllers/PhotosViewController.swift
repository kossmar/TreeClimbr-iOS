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
    let flowLayout = UICollectionViewFlowLayout()
    
    
    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        photoCollectionView.delegate = self
        moreImagesArr = []
        
//        let width = view.frame.width / 2
//        flowLayout.itemSize = CGSize(width: width, height: width)
//        flowLayout.minimumInteritemSpacing = 0
//        photoCollectionView.collectionViewLayout = flowLayout
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
        }
        
    }
    
    
    // MARK: - Actions
    
    @IBAction func addPhotoButtonPressed(_ sender: UIButton) {
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
            self.imagePickerController.resetAssets()
//            self.imageArr = []
            
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
        }
        
        photoCollectionView.reloadData()
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
}
