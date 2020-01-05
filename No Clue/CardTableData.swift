//
//  CardList.swift
//  No Clue
//
//  Created by Leif Kornstaedt on 12/26/19.
//  Copyright © 2019 Leif Kornstaedt. All rights reserved.
//

import Foundation
import UIKit

class CardCell {

    let _card: ClueCard
    var cell: UITableViewCell?

    var card: ClueCard {
        get { return _card }
    }

    init(_ card: ClueCard) {
        self._card = card
    }

    func tableViewCell(_ gameEdition: GameEdition) -> UITableViewCell {
        if self.cell == nil {
            self.cell = UITableViewCell(style: .default, reuseIdentifier: "Card")
            self.cell!.backgroundColor = .none
        }
        self.cell!.textLabel!.text = gameEdition.cardName(self.card)
        return self.cell!
    }

}

@objc class CardTableData: NSObject, UITableViewDelegate, UITableViewDataSource {

    let gameEdition: GameEdition
    var cardCells: [CardCell]
    var viewController: GameSetupViewController?

    init(gameEdition: GameEdition) {
        self.gameEdition = gameEdition
        self.cardCells = []
        super.init()
    }
    
    //
    // Adding a card from main view controller
    //

    func addCard(_ card: ClueCard) -> Int? {
        let allCardsIndex = gameEdition.cardToAllCardsIndex(card: card)
        var i = 0
        for cardCell in cardCells {
            if cardCell.card == card {
                return nil
            } else if gameEdition.cardToAllCardsIndex(card: cardCell.card) > allCardsIndex {
                cardCells.insert(CardCell(card), at: i)
                return i
            }
            i += 1
        }
        cardCells.append(CardCell(card))
        return cardCells.count - 1
    }
    
    var numberOfCards: Int {
        get { return cardCells.count }
    }

    func getCards() -> [ClueCard] {
        var cards = [ClueCard]()
        for cardCell in self.cardCells {
            cards.append(cardCell.card)
        }
        return cards
    }

    func clear(tableView: UITableView) {
        self.cardCells = [CardCell]()
    }

    //
    // UITableView data binding
    //

    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardCells.count
    }

    @objc func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.cardCells[indexPath.row].tableViewCell(gameEdition)
    }

    @objc func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.cardCells.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.viewController?.gameInformationUpdated()
        }
    }

}
