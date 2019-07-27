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
            let result: AuthManagementResult
            let error: Error?
        }
        struct ViewModel
        {
            let result: AuthManagementResult
            let error: Error?
        }
    }
}
