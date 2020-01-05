//
//  PlayerInformationCell.swift
//  No Clue
//
//  Created by Leif Kornstaedt on 1/1/20.
//  Copyright © 2020 Leif Kornstaedt. All rights reserved.
//

import UIKit

class PlayerInformationTableViewCell: UITableViewCell {

    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var decreaseButton: UIButton!
    @IBOutlet weak var numberOfCardsHeldLabel: UILabel!
    @IBOutlet weak var increaseButton: UIButton!

    var playerTableData: PlayerTableData!

    var playerName: String! { didSet { updateCell() } }
    var isMe: Bool = false { didSet { updateCell() } }
    var numberOfCardsHeld: Int? {
        didSet {
            numberOfCardsHeldLabel.text = numberOfCardsHeld == nil ? "?" : String(numberOfCardsHeld!)
        }
    }

    private func updateCell() {
        playerNameLabel.text = (playerName ?? "") + (isMe ? " (me)" : "")
        decreaseButton.isHidden = isMe
        numberOfCardsHeldLabel.isHidden = isMe
        increaseButton.isHidden = isMe
    }
    
    @IBAction func decrease(_ sender: Any) {
        playerTableData.decreaseNumberOfCardsHeld(cell: self)
    }
    
    @IBAction func increase(_ sender: Any) {
        playerTableData.increaseNumberOfCardsHeld(cell: self)
    }
}
