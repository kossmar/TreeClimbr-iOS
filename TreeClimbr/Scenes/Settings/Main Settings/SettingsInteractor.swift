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
    func changeUsername(request: Settings.ChangeUsername.Request)
}

protocol SettingsDataStore
{
    //var name: String { get set }
}

class SettingsInteractor: SettingsBusinessLogic, SettingsDataStore
{
    var presenter: SettingsPresentationLogic?
    var worker = SettingsWorker()
    
    // MARK: Manage Authentication
    
    func manageAuthentication()
    {
        worker.manageAuthentication { (result, error) in
            let response = Settings.Logout.Response(result: result, error: error)
            self.presenter?.presentAuthenticationManagement(response: response)
        }
    }
    
    // MARK: Change Username
    
    func changeUsername(request: Settings.ChangeUsername.Request)
    {
        worker.changeUsername(request: request, completion: { result in
            let response = Settings.ChangeUsername.Response(result: result)
            self.presenter?.presentNewUsername(response: response)
        })
    }
}
