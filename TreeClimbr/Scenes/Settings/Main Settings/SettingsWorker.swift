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
}
