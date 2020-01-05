//
//  PlayerList.swift
//  No Clue
//
//  Created by Leif Kornstaedt on 12/26/19.
//  Copyright © 2019 Leif Kornstaedt. All rights reserved.
//

import Foundation
import UIKit

class PlayerCell {

    var playerName: String {
        didSet { if let cell = cell { cell.playerName = playerName } }
    }
    var isMe: Bool {
        didSet { if let cell = cell { cell.isMe = isMe } }
    }
    var numberOfCardsHeld: Int? {
        didSet { if let cell = cell { cell.numberOfCardsHeld = numberOfCardsHeld }}
    }
    var cell: PlayerInformationTableViewCell?

    init(_ playerName: String, isMe: Bool) {
        self.playerName = playerName
        self.isMe = isMe
    }

    func tableViewCell(tableView: UITableView, playerTableData: PlayerTableData) -> UITableViewCell {
        if self.cell == nil {
            self.cell = (tableView.dequeueReusableCell(withIdentifier: "Player") as! PlayerInformationTableViewCell)
            self.cell!.playerTableData = playerTableData
            self.cell!.playerName = playerName
            self.cell!.isMe = isMe
            self.cell!.numberOfCardsHeld = numberOfCardsHeld
        }
        return self.cell!
    }

}

@objc class PlayerTableData: NSObject, UITableViewDelegate, UITableViewDataSource {

    private var playerCells: [PlayerCell]
    var viewController: GameSetupViewController?

    override init() {
        self.playerCells = []
        super.init()
    }

    //
    // Adding a player from main view controller
    //

    func addPlayer(_ playerName: String) {
        self.playerCells.append(PlayerCell(playerName, isMe: numberOfPlayers == 0))
        self.viewController!.gameInformationUpdated()
    }
    
    var numberOfPlayers: Int { get { return playerCells.count } }

    func getPlayerNames() -> [String] {
        return playerCells.map { $0.playerName }
    }

    func getNumberOfCardsHeld() -> [Int?] {
        var numberOfCardsHeld = [Int?]()
        var i = 1
        while i < numberOfPlayers {
            numberOfCardsHeld.append(playerCells[i].numberOfCardsHeld)
            i += 1
        }
        return numberOfCardsHeld
    }

    //
    // Modifying number of cards held
    //

    func decreaseNumberOfCardsHeld(cell: PlayerInformationTableViewCell) {
        if let playerCell = playerCells.first(where: { $0.cell === cell }) {
            if let numberOfCardsHeld = playerCell.numberOfCardsHeld {
                playerCell.numberOfCardsHeld = numberOfCardsHeld == 0 ? nil : numberOfCardsHeld - 1
                self.viewController!.gameInformationUpdated()
            }
        }
    }

    func increaseNumberOfCardsHeld(cell: PlayerInformationTableViewCell) {
        if let playerCell = playerCells.first(where: { $0.cell === cell }) {
            playerCell.numberOfCardsHeld = (playerCell.numberOfCardsHeld ?? -1) + 1
            self.viewController!.gameInformationUpdated()
        }
    }

    //
    // UITableView data binding
    //

    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfPlayers
    }

    @objc func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.playerCells[indexPath.row].tableViewCell(tableView: tableView, playerTableData: self)
    }

    @objc func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.playerCells.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            if indexPath.row == 0 && self.playerCells.count > 0 {
                self.playerCells[0].isMe = true
            }
            self.viewController!.gameInformationUpdated()
        }
    }

    @objc func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.section != destinationIndexPath.section || sourceIndexPath.row != destinationIndexPath.row {
            self.playerCells[0].isMe = false
            let playerCell = self.playerCells.remove(at: sourceIndexPath.row)
            self.playerCells.insert(playerCell, at: destinationIndexPath.row)
            self.playerCells[0].isMe = true
            self.viewController!.gameInformationUpdated()
        }
    }

}
