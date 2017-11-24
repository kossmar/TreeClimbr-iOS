
import UIKit

class PhotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    var tree : Tree?
    var photosArr = Array<Photo>()
    
    //    var tree : Tree? {
    //        didSet {
    //            guard let tree = tree else { return }
    //
    //        }
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    // MARK: - CollectionView DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photosArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "basicPhotoCell", for: indexPath) as! BasicPhotoCollectionViewCell
        let photo = self.photosArr[indexPath.row]
        let url = URL(string: photo.photoURL)
        
        cell.treePhotoImageView.sd_setImage(with: url,
                                            completed: { (image, error, cacheType, url) in
                                                print("\(String(describing: image)), \(String(describing: error)), \(cacheType), \(String(describing: url))")
        })
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
}
