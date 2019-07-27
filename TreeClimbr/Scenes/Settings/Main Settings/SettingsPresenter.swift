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
}
