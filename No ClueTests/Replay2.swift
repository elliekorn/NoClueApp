//
//  Replay2.swift
//  No ClueTests
//
//  Created by Leif Kornstaedt on 1/1/20.
//  Copyright © 2020 Leif Kornstaedt. All rights reserved.
//

import XCTest
@testable import No_Clue

class Replay2: Replay {

    var gameEdition: GameEdition
    var playerNames: [String]
    var myCards: [ClueCard]
    var numberOfCardsHeld: [Int?]
    var suggestions: [Suggestion]

    init() {
        gameEdition = AmericanModernGameEdition()
        playerNames = ["Leif", "Felix", "Jenny", "Fritzi", "Ulrike"]
        myCards = [ClueCard(kind: .weapon, index: 1),
                   ClueCard(kind: .room, index: 0),
                   ClueCard(kind: .room, index: 2)]
        numberOfCardsHeld = [3, 4, 4, 4]

        // Playtest session with Version 1.2 before submission to the app store, 12/31/2019
        // We can infer at end what all the murder cards are based on knowing all of Fritzi's cards.
        suggestions =
            [Suggestion(playerIndex: 3, suspectIndex: 2, weaponIndex: 0, roomIndex: 8, playerWhoShowedCard: 4, cardShownKind: nil),
             Suggestion(playerIndex: 4, suspectIndex: 4, weaponIndex: 5, roomIndex: 1, playerWhoShowedCard: 2, cardShownKind: nil),
             Suggestion(playerIndex: 0, suspectIndex: 2, weaponIndex: 2, roomIndex: 6, playerWhoShowedCard: 1, cardShownKind: .room),
             Suggestion(playerIndex: 1, suspectIndex: 5, weaponIndex: 3, roomIndex: 1, playerWhoShowedCard: 2, cardShownKind: nil),
             Suggestion(playerIndex: 2, suspectIndex: 4, weaponIndex: 1, roomIndex: 1, playerWhoShowedCard: 3, cardShownKind: nil),
             Suggestion(playerIndex: 3, suspectIndex: 4, weaponIndex: 1, roomIndex: 8, playerWhoShowedCard: 0, cardShownKind: .weapon),
             Suggestion(playerIndex: 0, suspectIndex: 0, weaponIndex: 0, roomIndex: 2, playerWhoShowedCard: 4, cardShownKind: .weapon),
             Suggestion(playerIndex: 1, suspectIndex: 0, weaponIndex: 4, roomIndex: 0, playerWhoShowedCard: 3, cardShownKind: nil),
             Suggestion(playerIndex: 2, suspectIndex: 2, weaponIndex: 5, roomIndex: 1, playerWhoShowedCard: 4, cardShownKind: nil),
             Suggestion(playerIndex: 3, suspectIndex: 3, weaponIndex: 4, roomIndex: 8, playerWhoShowedCard: 2, cardShownKind: nil),
             Suggestion(playerIndex: 0, suspectIndex: 0, weaponIndex: 3, roomIndex: 8, playerWhoShowedCard: 2, cardShownKind: .weapon),
             Suggestion(playerIndex: 1, suspectIndex: 3, weaponIndex: 4, roomIndex: 0, playerWhoShowedCard: 3, cardShownKind: nil),
             Suggestion(playerIndex: 2, suspectIndex: 3, weaponIndex: 4, roomIndex: 1, playerWhoShowedCard: 3, cardShownKind: nil),
             Suggestion(playerIndex: 3, suspectIndex: 1, weaponIndex: 5, roomIndex: 1, playerWhoShowedCard: 4, cardShownKind: nil),
             Suggestion(playerIndex: 1, suspectIndex: 3, weaponIndex: 0, roomIndex: 0, playerWhoShowedCard: 3, cardShownKind: nil),
             Suggestion(playerIndex: 2, suspectIndex: 3, weaponIndex: 2, roomIndex: 1, playerWhoShowedCard: 3, cardShownKind: nil),
             Suggestion(playerIndex: 1, suspectIndex: 5, weaponIndex: 0, roomIndex: 8, playerWhoShowedCard: 2, cardShownKind: nil),
             Suggestion(playerIndex: 2, suspectIndex: 0, weaponIndex: 3, roomIndex: 0, playerWhoShowedCard: 0, cardShownKind: .room),
             Suggestion(playerIndex: 4, suspectIndex: 1, weaponIndex: 0, roomIndex: 2, playerWhoShowedCard: 0, cardShownKind: .room),
             Suggestion(playerIndex: 0, suspectIndex: 0, weaponIndex: 2, roomIndex: 7, playerWhoShowedCard: 3, cardShownKind: .room),
             Suggestion(playerIndex: 3, suspectIndex: 0, weaponIndex: 2, roomIndex: 3, playerWhoShowedCard: nil, cardShownKind: nil)]
    }

}
