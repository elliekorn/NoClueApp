//
//  Replay3.swift
//  No ClueTests
//
//  Created by Leif Kornstaedt on 1/5/20.
//  Copyright © 2020 Leif Kornstaedt. All rights reserved.
//

import XCTest
@testable import No_Clue

class Replay3: Replay {

    var gameEdition: GameEdition
    var playerNames: [String]
    var myCards: [ClueCard]
    var numberOfCardsHeld: [Int?]
    var suggestions: [Suggestion]

    init() {
        gameEdition = AmericanModernGameEdition()
        playerNames = ["Leif", "Felix", "Ulrike", "Großmama", "Fritzi"]
        myCards = [ClueCard(kind: .suspect, index: 1),
                   ClueCard(kind: .room, index: 2),
                   ClueCard(kind: .room, index: 4)]
        numberOfCardsHeld = [4, 3, 4, 4]

        // Playtest session with Version 1.2 before submission to the app store, 1/2/2020
        suggestions =
            [Suggestion(playerIndex: 0, suspectIndex: 0, weaponIndex: 0, roomIndex: 6, playerWhoShowedCard: 2, cardShownKind: .weapon),
             Suggestion(playerIndex: 1, suspectIndex: 2, weaponIndex: 2, roomIndex: 4, playerWhoShowedCard: 3, cardShownKind: nil),
             Suggestion(playerIndex: 3, suspectIndex: 3, weaponIndex: 1, roomIndex: 1, playerWhoShowedCard: 4, cardShownKind: nil),
             Suggestion(playerIndex: 4, suspectIndex: 3, weaponIndex: 4, roomIndex: 1, playerWhoShowedCard: 3, cardShownKind: nil),
             Suggestion(playerIndex: 0, suspectIndex: 5, weaponIndex: 1, roomIndex: 6, playerWhoShowedCard: 1, cardShownKind: .weapon),
             Suggestion(playerIndex: 1, suspectIndex: 3, weaponIndex: 5, roomIndex: 5, playerWhoShowedCard: 3, cardShownKind: nil),
             Suggestion(playerIndex: 2, suspectIndex: 4, weaponIndex: 3, roomIndex: 6, playerWhoShowedCard: 1, cardShownKind: nil),
             Suggestion(playerIndex: 3, suspectIndex: 2, weaponIndex: 0, roomIndex: 2, playerWhoShowedCard: 0, cardShownKind: .room),
             Suggestion(playerIndex: 4, suspectIndex: 1, weaponIndex: 5, roomIndex: 5, playerWhoShowedCard: 0, cardShownKind: .suspect),
             Suggestion(playerIndex: 0, suspectIndex: 5, weaponIndex: 3, roomIndex: 6, playerWhoShowedCard: 1, cardShownKind: .weapon),
             Suggestion(playerIndex: 1, suspectIndex: 4, weaponIndex: 4, roomIndex: 6, playerWhoShowedCard: 2, cardShownKind: nil),
             Suggestion(playerIndex: 2, suspectIndex: 5, weaponIndex: 1, roomIndex: 3, playerWhoShowedCard: 4, cardShownKind: nil),
             Suggestion(playerIndex: 3, suspectIndex: 1, weaponIndex: 2, roomIndex: 5, playerWhoShowedCard: 4, cardShownKind: nil),
             Suggestion(playerIndex: 4, suspectIndex: 2, weaponIndex: 0, roomIndex: 4, playerWhoShowedCard: 0, cardShownKind: .room),
             Suggestion(playerIndex: 0, suspectIndex: 0, weaponIndex: 4, roomIndex: 6, playerWhoShowedCard: 2, cardShownKind: .room),
             Suggestion(playerIndex: 1, suspectIndex: 4, weaponIndex: 4, roomIndex: 2, playerWhoShowedCard: 0, cardShownKind: .room),
             Suggestion(playerIndex: 2, suspectIndex: 4, weaponIndex: 2, roomIndex: 3, playerWhoShowedCard: 3, cardShownKind: nil),
             Suggestion(playerIndex: 4, suspectIndex: 2, weaponIndex: 4, roomIndex: 4, playerWhoShowedCard: 0, cardShownKind: .room),
             Suggestion(playerIndex: 0, suspectIndex: 5, weaponIndex: 4, roomIndex: 3, playerWhoShowedCard: 2, cardShownKind: .room),
             Suggestion(playerIndex: 1, suspectIndex: 4, weaponIndex: 4, roomIndex: 3, playerWhoShowedCard: 2, cardShownKind: nil),
             Suggestion(playerIndex: 2, suspectIndex: 1, weaponIndex: 0, roomIndex: 6, playerWhoShowedCard: 0, cardShownKind: .suspect),
             Suggestion(playerIndex: 2, suspectIndex: 0, weaponIndex: 3, roomIndex: 2, playerWhoShowedCard: 4, cardShownKind: nil),
             Suggestion(playerIndex: 3, suspectIndex: 2, weaponIndex: 1, roomIndex: 7, playerWhoShowedCard: 1, cardShownKind: nil),
             Suggestion(playerIndex: 2, suspectIndex: 2, weaponIndex: 1, roomIndex: 6, playerWhoShowedCard: 1, cardShownKind: nil),
             Suggestion(playerIndex: 3, suspectIndex: 5, weaponIndex: 3, roomIndex: 8, playerWhoShowedCard: 4, cardShownKind: nil),
             Suggestion(playerIndex: 4, suspectIndex: 2, weaponIndex: 4, roomIndex: 7, playerWhoShowedCard: 1, cardShownKind: nil),
             Suggestion(playerIndex: 0, suspectIndex: 2, weaponIndex: 4, roomIndex: 0, playerWhoShowedCard: 1, cardShownKind: .suspect),
             Suggestion(playerIndex: 2, suspectIndex: 1, weaponIndex: 0, roomIndex: 8, playerWhoShowedCard: 0, cardShownKind: .suspect),
             Suggestion(playerIndex: 3, suspectIndex: 3, weaponIndex: 0, roomIndex: 8, playerWhoShowedCard: 2, cardShownKind: nil)]
    }

}
