//
//  SettingsModels.swift
//  
//
//  Created by Mar Koss on 2019-07-25.
//  Copyright (c) 2019 Mar Koss. All rights reserved.
//

import UIKit

enum Settings
{
    // MARK: Use cases
    
    enum Logout
    {
        struct Request
        {
        }
        struct Response
        {
            var result: AuthManagementResult
            var error: Error?
        }
        struct ViewModel
        {
            var result: AuthManagementResult
            var error: Error?
        }
    }
    
    enum ChangeUsername
    {
        struct Request
        {
            var newUsername: String
        }
        struct Response
        {
            var result: Result<String, Error>
        }
        struct ViewModel
        {
            var result: Result<String, Error>
        }
    }
}
