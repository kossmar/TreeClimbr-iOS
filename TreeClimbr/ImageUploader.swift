import Foundation
import Firebase

class ImageUploader {
    
    class func uploadImage(image: UIImage, tree: Tree, completion: @escaping (URL, String) -> Void) {
        
        var url: URL?
        var imageDBName: String?
        
        let photoData = image.jpeg(.low)
        
        let imageID = NSUUID().uuidString
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imagesRef = storageRef.child(imageID)
        
        imagesRef.putData(photoData!, metadata: nil, completion: { (metadata, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            if let metadata = metadata, let downloadedURL = metadata.downloadURL(), let downloadedDBName = metadata.name {
                print(downloadedURL)
                metadata.contentType = "image/jpeg"
                imageDBName = downloadedDBName
                url = downloadedURL
            }
            
            guard let url = url else {
                print("NO URL, BREWWW")
                return
            }
            
            completion(url, imageDBName!)
        })
        
    }
    
    class func createNewPhotos(images: Array<UIImage>, tree: Tree, completion: @escaping ([Photo]) -> Void) {
        
        var tempPhotoArr = Array<Photo>()
        
        let curUser = Auth.auth().currentUser?.uid
        
        guard let user = curUser else {
            print("not logged in")
            return
        }
        
        let group = DispatchGroup()
        
        for image in images {
            
            group.enter()
            uploadImage(image: image, tree: tree, completion: { url, imageDBName in
                let urlStr = url.absoluteString
                let dbName = imageDBName
                let photo = Photo(URL: urlStr)
                photo.userID = user
                photo.imageDBName = dbName
                
                tempPhotoArr.append(photo)
                group.leave()
                
            })
        }
        
        group.notify(queue: DispatchQueue.global()) {
            completion(tempPhotoArr)
        }
    }
    
}
