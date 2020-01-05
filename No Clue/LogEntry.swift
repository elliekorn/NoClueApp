//
//  LogEntry.swift
//  No Clue
//
//  Created by Leif Kornstaedt on 12/27/19.
//  Copyright © 2019 Leif Kornstaedt. All rights reserved.
//

import UIKit

protocol LogEntry {
    func backgroundColor() -> UIColor?
    func toString(gameState: GameState) -> String
}

class Suggestion: Codable, LogEntry {

    private static let bgColor = UIColor(red: 0.6, green: 0.6, blue: 1.0, alpha: 0.6)

    let playerIndex: Int
    let suspectIndex: Int
    let weaponIndex: Int
    let roomIndex: Int
    let playerWhoShowedCard: Int?
    let cardShownKind: Int?
    let disabled: Bool

    var cardShown: ClueCard? {
        get {
            if cardShownKind == 0 {
                return ClueCard(kind: .suspect, index: suspectIndex)
            } else if cardShownKind == 1 {
                return ClueCard(kind: .weapon, index: weaponIndex)
            } else if cardShownKind == 2 {
                return ClueCard(kind: .room, index: roomIndex)
            } else {
                return nil
            }
        }
    }

    init(playerIndex: Int, suspectIndex: Int, weaponIndex: Int, roomIndex: Int, playerWhoShowedCard: Int?, cardShownKind: CardKind?, disabled: Bool = false) {
        self.playerIndex = playerIndex
        self.suspectIndex = suspectIndex
        self.weaponIndex = weaponIndex
        self.roomIndex = roomIndex
        self.playerWhoShowedCard = playerWhoShowedCard
        self.cardShownKind = cardShownKind == nil ? nil :
            cardShownKind == .suspect ? 0 : cardShownKind == .weapon ? 1 : 2
        self.disabled = disabled
    }

    func toggle() -> Suggestion {
        return Suggestion(playerIndex: playerIndex, suspectIndex: suspectIndex, weaponIndex: weaponIndex, roomIndex: roomIndex, playerWhoShowedCard: playerWhoShowedCard, cardShownKind: cardShown?.kind, disabled: !disabled)
    }

    func backgroundColor() -> UIColor? {
        return disabled ? .systemGray3 : Suggestion.bgColor
    }

    func toString(gameState: GameState) -> String {
        let player = gameState.playerNames[playerIndex]
        let suspect = gameState.gameEdition.suspects[suspectIndex]
        let weapon = gameState.gameEdition.weapons[weaponIndex]
        let room = gameState.gameEdition.rooms[roomIndex]
        var shown: String
        if let playerWhoShowedCard = playerWhoShowedCard {
            shown = gameState.playerNames[playerWhoShowedCard] + " showed "
            if let cardShown = cardShown {
                shown += gameState.gameEdition.cardName(cardShown)
            } else {
                shown += "a card"
            }
        } else {
            shown = "No card was shown"
        }
        return player + " suggested " + suspect + ", " + weapon + ", " + room + ". " + shown + "."
    }

    func needsToSpecifyShownCard() -> Bool {
        return playerIndex == 0 && playerWhoShowedCard != nil || playerWhoShowedCard == 0
    }

    func guessedCards() -> [ClueCard] {
        return [ClueCard(kind: .suspect, index: suspectIndex),
                ClueCard(kind: .weapon, index: weaponIndex),
                ClueCard(kind: .room, index: roomIndex)]
    }

}

class PlayerMustHaveCard: LogEntry {

    private static let bgColor = UIColor(red: 0.8, green: 1.0, blue: 0.8, alpha: 0.6)

    let playerIndex: Int
    let card: ClueCard

    init(playerIndex: Int, card: ClueCard) {
        self.playerIndex = playerIndex
        self.card = card
    }

    func backgroundColor() -> UIColor? {
        return PlayerMustHaveCard.bgColor
    }

    func toString(gameState: GameState) -> String {
        return gameState.playerNames[playerIndex] + " must have " + gameState.gameEdition.cardName(card) + "."
    }

}

class PlayerCannotHaveCard: LogEntry {

    private static let bgColor = UIColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 0.6)

    let playerIndex: Int
    let card: ClueCard

    init(playerIndex: Int, card: ClueCard) {
        self.playerIndex = playerIndex
        self.card = card
    }

    func backgroundColor() -> UIColor? {
        return PlayerCannotHaveCard.bgColor
    }

    func toString(gameState: GameState) -> String {
        return gameState.playerNames[playerIndex] + " cannot have " + gameState.gameEdition.cardName(card) + "."
    }

}

class PlayersMayHaveCards: LogEntry {

    private static let bgColor = UIColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 0.6)

    let playerIndex1: Int
    let playerIndex2: Int
    let card1: ClueCard
    let card2: ClueCard

    init(playerIndex1: Int, playerIndex2: Int, card1: ClueCard, card2: ClueCard) {
        self.playerIndex1 = playerIndex1
        self.playerIndex2 = playerIndex2
        self.card1 = card1
        self.card2 = card2
    }

    func backgroundColor() -> UIColor? {
        return PlayersMayHaveCards.bgColor
    }

    func toString(gameState: GameState) -> String {
        return "Based on previous information, " + gameState.playerNames[playerIndex1] + " and " + gameState.playerNames[playerIndex2] + " have (and the murder cards cannot be) " + gameState.gameEdition.cardName(card1) + " and " + gameState.gameEdition.cardName(card2) + "."
    }

}

class MurderCard: LogEntry {

    private static let bgColor = UIColor(red: 0.6, green: 1.0, blue: 1.0, alpha: 0.6)

    let card: ClueCard

    init(card: ClueCard) {
        self.card = card
    }

    func backgroundColor() -> UIColor? {
        return MurderCard.bgColor
    }

    func toString(gameState: GameState) -> String {
        return gameState.gameEdition.cardName(card) + " must be one of the murder cards."
    }

}

class Constraint: LogEntry {

    let playerIndex: Int
    let cards: [ClueCard]

    init(playerIndex: Int, cards: [ClueCard]) {
        self.playerIndex = playerIndex
        self.cards = cards
    }

    func backgroundColor() -> UIColor? {
        return .systemBackground
    }

    func toString(gameState: GameState) -> String {
        var cardsString = "Still tracking that " + gameState.playerNames[playerIndex] + " must have one of "
        var first = true
        for card in cards {
            if !first {
                cardsString += ", "
            }
            first = false
            cardsString += gameState.gameEdition.cardName(card)
        }
        return cardsString + "."
    }

}

protocol Warning {
    func toString(gameState: GameState) -> String
}

class ContradictionWarning: LogEntry, Warning {

    private static let bgColor = UIColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 0.6)

    let playerIndex: Int
    let card: ClueCard
    let old: Bool

    init(playerIndex: Int, card: ClueCard, old: Bool) {
        self.playerIndex = playerIndex
        self.card = card
        self.old = old
    }

    func backgroundColor() -> UIColor? {
        return ContradictionWarning.bgColor
    }

    func toString(gameState: GameState) -> String {
        let oldText = old ? "" : "not "
        let newText = old ? "not " : ""
        return gameState.playerNames[playerIndex] + " was believed " + oldText + "to have " + gameState.gameEdition.cardName(card) + ", but is now implied " + newText + "to have it. Try to correct the mistake!"
    }

}

class EmptyConstraintWarning: LogEntry, Warning {

    private static let bgColor = UIColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 0.6)

    let playerIndex: Int
    let cards: [ClueCard]

    init(playerIndex: Int, cards: [ClueCard]) {
        self.playerIndex = playerIndex
        self.cards = cards
    }

    func backgroundColor() -> UIColor? {
        return EmptyConstraintWarning.bgColor
    }

    func toString(gameState: GameState) -> String {
        var text = gameState.playerNames[playerIndex] + " was previously inferred to hold one of "
        for card in cards {
            text += gameState.gameEdition.cardName(card) + ", "
        }
        return text + "but is now inferred not to have any of them. Try to correct the mistake!"
    }

}

class MultipleMurderCardsWarning: LogEntry, Warning {

    private static let bgColor = UIColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 0.6)

    let cards: [ClueCard]

    init(cards: [ClueCard]) {
        self.cards = cards
    }

    func backgroundColor() -> UIColor? {
        return MultipleMurderCardsWarning.bgColor
    }

    func toString(gameState: GameState) -> String {
        var text = "Found more than one murder card from same group: "
        var first = true
        for card in cards {
            if !first {
                text += ", "
            }
            first = false
            text += gameState.gameEdition.cardName(card)
        }
        return text + ". Try to correct the mistake!"
    }

}
