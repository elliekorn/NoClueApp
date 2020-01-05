//
//  GameManagementViewController.swift
//  No Clue
//
//  Created by Leif Kornstaedt on 12/28/19.
//  Copyright © 2019 Leif Kornstaedt. All rights reserved.
//

import UIKit
import MessageUI

class GameManagementViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var sendMailButton: UIButton!

    // Parameter passed in segue
    var _gameState: GameState!
    var gameState: GameState {
        get { return _gameState }
        set { _gameState = newValue }
    }

    override func viewDidAppear(_ animated: Bool) {
        sendMailButton.isHidden = !MFMailComposeViewController.canSendMail()
    }

    @IBAction func restartGame(_ sender: Any) {
        GameState.unsave()

        self.performSegue(withIdentifier: "unwindToGameSetup", sender: self)
    }
    
    @IBAction func sendDiagnosticsEmail(_ sender: Any) {
        if !MFMailComposeViewController.canSendMail() {
            return
        }

        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String

        var bodyText = "<Describe problem here>\n\n"
        bodyText += "I provide permission to the author of the No Clue app to use this data for testing purposes.\n\n"
        bodyText += "Build version: " + version
        if let build = build {
            bodyText += "\nBuild: " + build
        }
        bodyText += "\nPlayers: "
        var first = true
        for i in 0 ..< gameState.numberOfPlayers {
            if !first {
                bodyText += ", "
            }
            first = false
            bodyText += gameState.playerNames[i]
            if i > 0, let numberOfCardsHeld = gameState.numberOfCardsHeld[i - 1] {
                bodyText += " (" + String(numberOfCardsHeld) + " cards)"
            }
        }
        bodyText += "\nMy cards: "
        first = true
        for card in gameState.myCards {
            if !first {
                bodyText += ", "
            }
            first = false
            bodyText += gameState.gameEdition.cardName(card)
        }
        if first {
            bodyText += "None"
        }
        bodyText += "\n"

        var i = 0
        while i < gameState.numberOfLogEntries {
            let logEntry = gameState.log(forIndex: i)
            bodyText += logEntry.toString(gameState: gameState) + "\n"
            i += 1
        }

        let composeViewController = MFMailComposeViewController()
        composeViewController.mailComposeDelegate = self

        // Configure the fields of the interface.
        composeViewController.setToRecipients(["noclueapp@kornstaedt.us"])
        composeViewController.setSubject("Diagnostics from No Clue app")
        composeViewController.setMessageBody(bodyText, isHTML: false)
        if let encodedData = gameState.encodeGameState() {
            composeViewController.addAttachmentData(encodedData, mimeType: "application/octet-stream", fileName: "GameState.plist")
        }

        // Present the view controller modally.
        self.present(composeViewController, animated: true, completion: nil)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}
