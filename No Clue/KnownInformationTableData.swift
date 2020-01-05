//
//  KnownInformationTableData.swift
//  No Clue
//
//  Created by Leif Kornstaedt on 12/27/19.
//  Copyright © 2019 Leif Kornstaedt. All rights reserved.
//

import UIKit

class KnownInformationCell {

    private let cardKind: CardKind?
    private let cardIndex: Int?
    private var cardKnowledge: [CardKnowledge]
    private var isMurderCard: Bool
    private var cell: KnownInformationTableViewCell?

    init(cardKind: CardKind?, cardIndex: Int?) {
        self.cardKind = cardKind
        self.cardIndex = cardIndex
        self.cardKnowledge = [CardKnowledge]()
        self.isMurderCard = false
    }

    func tableViewCell(_ gameState: GameState) -> UITableViewCell {
        if self.cell == nil {
            self.cell = KnownInformationTableViewCell(style: .default, reuseIdentifier: "KnownInformation")
        }
        updateCell(gameState: gameState)
        return self.cell!
    }

    func updateCell(gameState: GameState) {
        self.cell!.numberOfPlayers = gameState.numberOfPlayers
        if let cardKind = cardKind {
            if let cardIndex = cardIndex {
                // card row
                let card = ClueCard(kind: cardKind, index: cardIndex)
                self.cell!.cardName = gameState.gameEdition.cardName(card)
                updateKnowledge(playerOffset: 0, gameState: gameState)
            } else {
                // header row
                self.cell!.cardName = gameState.gameEdition.kindName(cardKind)
                self.cell!.setPlayerNames(gameState.playerNames)
            }
        } else {
            // footer row
            self.cell!.cardName = "Cards held"
            var data = [String(gameState.myCards.count)]
            for numberOfCardsHeld in gameState.numberOfCardsHeld {
                if let numberOfCardsHeld = numberOfCardsHeld {
                    data.append(String(numberOfCardsHeld))
                } else {
                    data.append("N/A")
                }
            }
            self.cell!.setPlayerNames(data)
        }
    }

    func updateKnowledge(playerOffset: Int, gameState: GameState) {
        if let cardIndex = cardIndex {
            let card = ClueCard(kind: cardKind!, index: cardIndex)
            for i in 0 ..< gameState.numberOfPlayers {
                let knowledge = gameState.cardKnowledge(forPlayerIndex: (gameState.numberOfPlayers + i - playerOffset) % gameState.numberOfPlayers, card: card)
                if i < cardKnowledge.count {
                    cardKnowledge[i] = knowledge
                } else {
                    cardKnowledge.append(knowledge)
                }
            }
            isMurderCard = gameState.isMurderCard(card)

            if let cell = cell {
                cell.setCardKnowledge(cardKnowledge, isMurderCard: isMurderCard)
            }
        }
    }

}

@objc class KnownInformationTableData: NSObject, UITableViewDelegate, UITableViewDataSource {

    var gameState: GameState
    var cells: [KnownInformationCell]

    init(gameState: GameState) {
        self.gameState = gameState
        self.cells = []
        super.init()

        self.cells.append(KnownInformationCell(cardKind: .suspect, cardIndex: nil))
        for i in 0 ..< gameState.gameEdition.suspects.count {
            self.cells.append(KnownInformationCell(cardKind: .suspect, cardIndex: i))
        }

        self.cells.append(KnownInformationCell(cardKind: .weapon, cardIndex: nil))
        for i in 0 ..< gameState.gameEdition.weapons.count {
            self.cells.append(KnownInformationCell(cardKind: .weapon, cardIndex: i))
        }

        self.cells.append(KnownInformationCell(cardKind: .room, cardIndex: nil))
        for i in 0 ..< gameState.gameEdition.rooms.count {
            self.cells.append(KnownInformationCell(cardKind: .room, cardIndex: i))
        }

        self.cells.append(KnownInformationCell(cardKind: nil, cardIndex: nil))
    }

    func updateKnowledge(playerOffset: Int, displayGameState: GameState) {
        for cell in cells {
            cell.updateKnowledge(playerOffset: playerOffset, gameState: displayGameState)
        }
    }

    //
    // UITableView data binding
    //

    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + gameState.gameEdition.suspects.count +
            1 + gameState.gameEdition.weapons.count +
            1 + gameState.gameEdition.rooms.count +
            1
    }

    @objc func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.cells[indexPath.row].tableViewCell(self.gameState)
    }

}
