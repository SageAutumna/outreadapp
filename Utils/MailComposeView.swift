//
//  MailComposeView.swift
//  Outread
//
//  Created by iosware on 24/08/2024.
//

import SwiftUI
import MessageUI

struct MailComposeView: UIViewControllerRepresentable {
    typealias UIViewControllerType = MFMailComposeViewController
    
    var to: String
    var subject: String
    var isPresented: Binding<Bool>
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailComposeView
        
        init(parent: MailComposeView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true) {
                self.parent.isPresented.wrappedValue = false
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = context.coordinator
        mailComposeVC.setToRecipients([to])
        mailComposeVC.setSubject(subject)
        return mailComposeVC
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        // No update needed
    }
}
