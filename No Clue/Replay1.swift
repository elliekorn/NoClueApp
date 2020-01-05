//
//  Replay1.swift
//  No Clue
//
//  Created by Leif Kornstaedt on 12/29/19.
//  Copyright © 2019 Leif Kornstaedt. All rights reserved.
//

class Replay1 {

    var gameEdition: GameEdition
    var playerNames: [String]
    var myCards: [ClueCard]
    var numberOfCardsHeld: [Int?]
    var suggestions: [Suggestion]

    init() {
        gameEdition = AmericanModernGameEdition()
        playerNames = ["Leif", "Felix", "Ulrike", "Fritzi"]
        myCards = [ClueCard(kind: .weapon, index: 1),
                   ClueCard(kind: .weapon, index: 5),
                   ClueCard(kind: .room, index: 2),
                   ClueCard(kind: .room, index: 5)]
        numberOfCardsHeld = [nil, nil, nil]

        // Playtest session with Version 1 approved on the app store, 12/28/2019
        // If we replay 0..17, we see .maybe values: Ulrike/Fritzi, Suspect 1 and Room 1.
        // We infer that Felix cannot have Suspect 1, and Felix cannot have Room 1 (and we are still tracking 3 constraints).
        // If we replay 0..18, we infer that Weapon 2 is a murder card.
        // If we replay 0..21, we infer that Suspect 4 is a murder card and (from the maybe's) that Room 7 is a murder card.
        suggestions =
            [Suggestion(playerIndex: 0, suspectIndex: 0, weaponIndex: 0, roomIndex: 6, playerWhoShowedCard: 1, cardShownKind: .weapon),
             Suggestion(playerIndex: 1, suspectIndex: 5, weaponIndex: 5, roomIndex: 4, playerWhoShowedCard: 2, cardShownKind: nil),
             Suggestion(playerIndex: 2, suspectIndex: 3, weaponIndex: 4, roomIndex: 3, playerWhoShowedCard: 1, cardShownKind: nil),
             Suggestion(playerIndex: 3, suspectIndex: 3, weaponIndex: 5, roomIndex: 3, playerWhoShowedCard: 0, cardShownKind: .weapon),
             Suggestion(playerIndex: 0, suspectIndex: 0, weaponIndex: 2, roomIndex: 6, playerWhoShowedCard: 1, cardShownKind: .room),
             Suggestion(playerIndex: 1, suspectIndex: 1, weaponIndex: 1, roomIndex: 4, playerWhoShowedCard: 2, cardShownKind: nil),
             Suggestion(playerIndex: 2, suspectIndex: 0, weaponIndex: 3, roomIndex: 6, playerWhoShowedCard: 3, cardShownKind: nil),
             Suggestion(playerIndex: 3, suspectIndex: 0, weaponIndex: 3, roomIndex: 3, playerWhoShowedCard: 1, cardShownKind: nil),
             Suggestion(playerIndex: 0, suspectIndex: 0, weaponIndex: 2, roomIndex: 3, playerWhoShowedCard: 1, cardShownKind: .room),
             Suggestion(playerIndex: 2, suspectIndex: 5, weaponIndex: 1, roomIndex: 2, playerWhoShowedCard: 3, cardShownKind: nil),
             Suggestion(playerIndex: 1, suspectIndex: 1, weaponIndex: 3, roomIndex: 1, playerWhoShowedCard: 2, cardShownKind: nil),
             Suggestion(playerIndex: 3, suspectIndex: 3, weaponIndex: 1, roomIndex: 6, playerWhoShowedCard: 0, cardShownKind: .weapon),
             Suggestion(playerIndex: 2, suspectIndex: 1, weaponIndex: 0, roomIndex: 1, playerWhoShowedCard: 3, cardShownKind: nil),
             Suggestion(playerIndex: 3, suspectIndex: 1, weaponIndex: 3, roomIndex: 6, playerWhoShowedCard: 1, cardShownKind: nil),
             Suggestion(playerIndex: 1, suspectIndex: 0, weaponIndex: 3, roomIndex: 0, playerWhoShowedCard: 2, cardShownKind: nil),
             Suggestion(playerIndex: 3, suspectIndex: 0, weaponIndex: 3, roomIndex: 6, playerWhoShowedCard: 1, cardShownKind: nil),
             Suggestion(playerIndex: 0, suspectIndex: 0, weaponIndex: 2, roomIndex: 2, playerWhoShowedCard: 3, cardShownKind: .suspect),
             Suggestion(playerIndex: 1, suspectIndex: 3, weaponIndex: 3, roomIndex: 8, playerWhoShowedCard: 3, cardShownKind: nil),
             Suggestion(playerIndex: 2, suspectIndex: 4, weaponIndex: 2, roomIndex: 0, playerWhoShowedCard: nil, cardShownKind: nil),
             Suggestion(playerIndex: 3, suspectIndex: 0, weaponIndex: 2, roomIndex: 7, playerWhoShowedCard: nil, cardShownKind: nil),
             Suggestion(playerIndex: 0, suspectIndex: 2, weaponIndex: 2, roomIndex: 7, playerWhoShowedCard: 2, cardShownKind: .suspect),
             Suggestion(playerIndex: 1, suspectIndex: 4, weaponIndex: 0, roomIndex: 8, playerWhoShowedCard: 3, cardShownKind: nil),
             Suggestion(playerIndex: 2, suspectIndex: 4, weaponIndex: 2, roomIndex: 7, playerWhoShowedCard: nil, cardShownKind: nil)]
    }

}
