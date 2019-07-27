import Foundation
import Firebase

class ImageUploader: NSObject
{
    var viewController: UIViewController!
    
    required init(viewController: UIViewController)
    {
        self.viewController = viewController
    }
    
    func uploadImage(image: UIImage, tree: Tree, onSuccess success: @escaping (URL, String) -> Void, onFailure failure: @escaping (Error?) -> Void)
    {
        
        //        var url: URL?
        var imageDBName: String?
        
        let photoData = image.jpeg(.low)
        
        let imageID = tree.treeName + "|" + NSUUID().uuidString
        //        let _: String = tree.treeName + "|" + String(describing: Date())
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imagesRef = storageRef.child(imageID)
        
        imagesRef.putData(photoData!, metadata: nil, completion: { (metadata, error) in
            
            if let error = error
            {
                print(error)
                return
            }
            
            // TODO: Handle this optional metadata.storageReference properly!
            
            if let metadata = metadata, let downloadedDBName = metadata.name
            {
                //                let downloadURL = metadata.storageReference!.downloadURL
                imagesRef.downloadURL(completion: { (downloadURL, error) in
                    guard let downloadURL = downloadURL else
                    {
                        // TODO: Handle this error
                        failure(error)
                        print("Could not upload image")
                        return
                    }
                    print(downloadURL)
                    metadata.contentType = "image/jpeg"
                    imageDBName = downloadedDBName
                    //                    url = downloadURL
                    success(downloadURL, imageDBName!)
                })
                //                print(downloadURL)
                //                metadata.contentType = "image/jpeg"
                //                imageDBName = downloadedDBName
                //                url = downloadURL
                //                completion(url, imageDBName!)
            }
            
            //            guard let url = url else {
            //                print("NO URL, BREWWW")
            //                return
            //            }
            
            //            completion(url, imageDBName!)
        })
        
    }
    
    func createNewPhotos(images: Array<UIImage>, tree: Tree, completion: @escaping ([Photo], Photo) -> Void)
    {
        
        var tempPhotoArr = Array<Photo>()
        
        let curUser = Auth.auth().currentUser?.uid
        
        guard let user = curUser else
        {
            print("not logged in")
            return
        }
        
        let group = DispatchGroup()
        
        var firstPhoto: Photo?
        
        for image in images {
            let position = images.index(of: image)
            group.enter()
            uploadImage(image: image, tree: tree, onSuccess: { url, imageDBName in
                let urlStr = url.absoluteString
                let dbName = imageDBName
                let photo = Photo(URL: urlStr)
                photo.userID = user
                photo.imageDBName = dbName
                tempPhotoArr.append(photo)
                if position == 0 {
                    firstPhoto = photo
                }
                group.leave()
                
            }, onFailure: { error in
                AlertShow.show(inpView: self.viewController , titleStr: "Could not upload photo", messageStr: "An error occurred. Please try again")
                if let error = error
                {
                    print(error.localizedDescription)
                }
            })
        }
        
        group.notify(queue: DispatchQueue.global())
        {
            guard let firstPhoto = firstPhoto else {return}
            completion(tempPhotoArr, firstPhoto)
        }
    }
    
}
