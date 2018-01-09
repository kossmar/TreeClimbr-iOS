//
//  ReportInappropriate.swift
//  TreeClimbr
//
//  Created by Carlo Namoca on 2018-01-09.
//  Copyright © 2018 Mar Koss. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

extension UIViewController : MFMessageComposeViewControllerDelegate {
    
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    func makeReport(withEmail email: String, messageBody: String) {
        if MFMailComposeViewController.canSendMail() {
            let mc: MFMailComposeViewController = MFMailComposeViewController()
            
            mc.mailComposeDelegate = self as? MFMailComposeViewControllerDelegate
            mc.setSubject("\(self.getAppName()) - Report Inappropriate")
            mc.setToRecipients([email])
            mc.setMessageBody(messageBody, isHTML: false)
            self.present(mc, animated: true, completion: nil)
        }
    }
    
    private func getAppName() -> String {
        if let info = Bundle.main.infoDictionary {
            if let appName = info["CFBundleName"] as? String {
                return appName
            }
        }
        return ""
    }
//
//    public func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
//        controller.dismiss(animated: true, completion: nil)
//    }
    
    
}
