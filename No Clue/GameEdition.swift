//
//  GameEdition.swift
//  No Clue
//
//  Created by Leif Kornstaedt on 12/26/19.
//  Copyright © 2019 Leif Kornstaedt. All rights reserved.
//

protocol GameEdition {

    var editionName: String { get }
    var minNumberOfPlayers: Int { get }
    var maxNumberOfPlayers: Int { get }
    var suspects: [String] { get }
    var weapons: [String] { get }
    var rooms: [String] { get }
    var allCards: [String] { get }
    func kindName(_ kind: CardKind) -> String

}

extension GameEdition {

    func cardNames(forKind: CardKind) -> [String] {
        switch forKind {
        case .suspect:
            return suspects
        case .weapon:
            return weapons
        case .room:
            return rooms
        }
    }

    func cardName(_ card: ClueCard) -> String {
        return cardNames(forKind: card.kind)[card.index]
    }

    var allCards: [String] { get { return suspects + weapons + rooms } }

    func cardToAllCardsIndex(card: ClueCard) -> Int {
        switch card.kind {
        case .suspect:
            return card.index
        case .weapon:
            return suspects.count + card.index
        case .room:
            return suspects.count + weapons.count + card.index
        }
    }

    func allCardsIndexToCard(index: Int) -> ClueCard {
        if index < suspects.count {
            return ClueCard(kind: .suspect, index: index)
        } else if index < suspects.count + weapons.count {
            return ClueCard(kind: .weapon, index: index - suspects.count)
        } else {
            return ClueCard(kind: .room, index: index - suspects.count - weapons.count)
        }
    }

}

class AmericanModernGameEdition: GameEdition {

    static let name = "American Modern"
    let editionName = name
    let minNumberOfPlayers: Int = 2
    let maxNumberOfPlayers: Int = 6
    let suspects: [String] = ["Miss Scarlet", "Mr. Green", "Colonel Mustard", "Professor Plum", "Mrs. Peacock", "Mrs. White"]
    let weapons: [String] = ["Candlestick", "Knife", "Lead Pipe", "Revolver", "Rope", "Spanner"]
    let rooms: [String] = ["Kitchen", "Ballroom", "Conservatory", "Dining Room", "Billiard Room", "Library", "Lounge", "Hall", "Study"]

    func kindName(_ kind: CardKind) -> String {
        switch kind {
        case .suspect:
            return "Suspects"
        case .weapon:
            return "Weapons"
        case .room:
            return "Rooms"
        }
    }

}

class GameEditions {

    static func createEdition(fromEditionName: String) -> GameEdition? {
        if fromEditionName == AmericanModernGameEdition.name {
            return AmericanModernGameEdition()
        } else {
            return nil
        }
    }

}
