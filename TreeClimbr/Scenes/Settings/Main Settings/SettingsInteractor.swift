//
//  SettingsInteractor.swift
//  
//
//  Created by Mar Koss on 2019-07-25.
//  Copyright (c) 2019 Mar Koss. All rights reserved.
//


import UIKit
import Firebase

protocol SettingsBusinessLogic
{
    func manageAuthentication()
}

protocol SettingsDataStore
{
    //var name: String { get set }
}

class SettingsInteractor: SettingsBusinessLogic, SettingsDataStore
{
    var presenter: SettingsPresentationLogic?
    var worker = SettingsWorker()
    
    // MARK: Logout
    
    func manageAuthentication()
    {
        worker.manageAuthentication { (result, error) in
            let response = Settings.Logout.Response(result: result, error: error)
            self.presenter?.presentAuthenticationManagement(response: response)
        }
    }
}
