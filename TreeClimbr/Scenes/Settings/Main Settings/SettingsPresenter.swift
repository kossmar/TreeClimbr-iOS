//
//  SettingsPresenter.swift
//  
//
//  Created by Mar Koss on 2019-07-25.
//  Copyright (c) 2019 Mar Koss. All rights reserved.
//


import UIKit

protocol SettingsPresentationLogic
{
    func presentAuthenticationManagement(response: Settings.Logout.Response)
    func presentNewUsername(response: Settings.ChangeUsername.Response)
}

class SettingsPresenter: SettingsPresentationLogic
{
    weak var viewController: SettingsDisplayLogic?
    
    // MARK: Present Authentication Management
    func presentAuthenticationManagement(response: Settings.Logout.Response)
    {
        let viewModel = Settings.Logout.ViewModel(result: response.result, error: response.error)
        viewController?.displayAuthenticationManagement(viewModel: viewModel)
    }
    
    // MARK: Present New Username
    
    func presentNewUsername(response: Settings.ChangeUsername.Response)
    {
        let viewModel = Settings.ChangeUsername.ViewModel(result: response.result)
        viewController?.displayNewUsername(viewModel: viewModel)
    }
}
