//
//  SettingsWorker.swift
//  
//
//  Created by Mar Koss on 2019-07-25.
//  Copyright (c) 2019 Mar Koss. All rights reserved.
//


import UIKit
import Firebase

enum AuthManagementResult
{
    case logoutFailure
    case logoutSuccess
    case login
}

class SettingsWorker
{
    
    var welcomePrefixString = "Welcome, "
    func manageAuthentication(completion:@escaping(AuthManagementResult, Error?) -> Void)
    {
        typealias result = AuthManagementResult
        
        let user = Auth.auth().currentUser
        if user != nil
        {
            do
            {
                try Auth.auth().signOut()
                AppData.sharedInstance.hiddenUsersArr.removeAll()
                completion(result.logoutSuccess, nil)
//                self.dismiss(animated: true, completion: nil)
            }
            catch let error as NSError {
                print (error.localizedDescription)
                completion(result.logoutFailure, error)
            }
//            AppData.sharedInstance.hiddenUsersArr.removeAll()
        } else {
//            performSegue(withIdentifier: signUpSegueId, sender: self)
            completion(result.login, nil)
        }
    }
    
    func changeUsername(request: Settings.ChangeUsername.Request, completion:@escaping(Result<String,Error>) -> Void)
    {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = request.newUsername
        changeRequest?.commitChanges(completion: { (error) in
            guard let error = error else
            {
                // TODO: There's probably a better way to do do this. I'm worried that in the edge case where there is no error, something bad will happen on the UI. Unsure.
                return
            }
            completion(.failure(error))
        })
//        self.welcomeLabel.text = "Welcome, " + request.newUsername
        CommentManager.updateUserCommentsUserName(newName: request.newUsername)
        PhotoManager.updateUserPhotosUserName(newName: request.newUsername)
        TreeManager.updateUserTreesUserName(newName: request.newUsername)
        
        guard let curUser = Auth.auth().currentUser else {return}
        AppData.sharedInstance.usersNode
            .child(curUser.uid)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                guard let userDict = snapshot.value as? NSDictionary else {return}
                let _ = userDict["nameKey"] as! String
                let userID = userDict["uidKey"] as! String
                let email = userDict["emailKey"] as! String
                
                let newUserDict: [String: Any] = [
                    "nameKey": request.newUsername,
                    "uidKey": userID,
                    "emailKey": email
                ]
                
                AppData.sharedInstance.usersNode
                    .child(curUser.uid)
                    .setValue(newUserDict)
            })
        let newWelcomeString = welcomePrefixString + request.newUsername
        completion(.success(newWelcomeString))
    }
}
