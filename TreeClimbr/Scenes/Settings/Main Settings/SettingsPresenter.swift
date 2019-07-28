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
    func presentNewEmail(response: Settings.ChangeEmail.Response)
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
    
    // MARK: Present New Email
    func presentNewEmail(response: Settings.ChangeEmail.Response)
    {
        var viewModel = Settings.ChangeEmail.ViewModel()
        
        switch response.result
        {
        case .success(let newEmailStr):
            viewModel.newEmailLabelStr = "e-mail: " + newEmailStr
            viewModel.error = nil
        case .failure(let error):
            // TODO: add changes for different error codes
            viewModel.newEmailLabelStr = nil
            viewModel.error = error.localizedDescription
        }

        viewController?.displayNewEmail(viewModel: viewModel)
    }
}
