//
//  MyAlert.swift
//  TrashTrekScorer
//
//  Created by Leif Kornstaedt on 9/6/15.
//  Copyright (c) 2015 Leif Kornstaedt. All rights reserved.
//

import Foundation
import UIKit

class MyAlert: NSObject, UIAlertViewDelegate {

    let completion: ((String) -> Void)?

    init(controller: UIViewController, title: String, message: String, button: String) {
        self.completion = nil
        super.init()

        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: button, style: .default, handler: nil))
            controller.present(alert, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertView()
            alert.title = title
            alert.message = message
            alert.addButton(withTitle: button)
            alert.show()
        }
    }

    init(controller: UIViewController, title: String, message: String,
        textFieldPlaceholder: String, text: String?, button: String,
        completion: @escaping (String) -> Void) {

        self.completion = completion
        super.init()

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = textFieldPlaceholder
            textField.text = text
        }
        alert.addAction(UIAlertAction(title: button, style: .default, handler: {
            (UIAlertAction) in
            let textField = alert.textFields![0]
            completion(textField.text ?? "")
        }))
        controller.present(alert, animated: true, completion: nil)
    }

}
