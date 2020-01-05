//
//  LogEntryTests.swift
//  No ClueTests
//
//  Created by Leif Kornstaedt on 12/29/19.
//  Copyright © 2019 Leif Kornstaedt. All rights reserved.
//

import XCTest
@testable import No_Clue

class LogEntryTests: XCTestCase {

    let playerNames = ["The Doctor", "Amy", "Rory"]
    let myCards = [ClueCard(kind: .suspect, index: 2),
                   ClueCard(kind: .weapon, index: 3),
                   ClueCard(kind: .weapon, index: 4)]
    let gameEdition = AmericanModernGameEdition()

    var gameState: GameState!

    override func setUp() {
        gameState = GameState(playerNames: playerNames,
                              myCards: myCards,
                              numberOfCardsHeld: [nil, nil],
                              gameEdition: gameEdition)
    }

    func testSuggestion() {
        let suggestion = Suggestion(playerIndex: 2, suspectIndex: 1, weaponIndex: 5, roomIndex: 8, playerWhoShowedCard: nil, cardShownKind: nil)
        XCTAssertEqual(suggestion.playerIndex, 2)
        XCTAssertEqual(suggestion.suspectIndex, 1)
        XCTAssertEqual(suggestion.weaponIndex, 5)
        XCTAssertEqual(suggestion.roomIndex, 8)
        XCTAssertNil(suggestion.playerWhoShowedCard)
        XCTAssertNil(suggestion.cardShown)
        XCTAssertEqual(suggestion.guessedCards(),
                       [ClueCard(kind: .suspect, index: 1),
                        ClueCard(kind: .weapon, index: 5),
                        ClueCard(kind: .room, index: 8)])
        XCTAssertFalse(suggestion.needsToSpecifyShownCard())
        XCTAssertNotNil(suggestion.backgroundColor())
        XCTAssertEqual(suggestion.toString(gameState: gameState), "Rory suggested Mr. Green, Spanner, Study. No card was shown.")

        let cardShown = ClueCard(kind: .weapon, index: 5)
        let suggestionWithShownCard = Suggestion(playerIndex: 2, suspectIndex: 1, weaponIndex: 5, roomIndex: 8, playerWhoShowedCard: 0, cardShownKind: cardShown.kind)
        XCTAssertEqual(suggestionWithShownCard.playerWhoShowedCard, 0)
        XCTAssertEqual(suggestionWithShownCard.cardShown, cardShown)
        XCTAssertTrue(suggestionWithShownCard.needsToSpecifyShownCard())
        XCTAssertEqual(suggestionWithShownCard.toString(gameState: gameState), "Rory suggested Mr. Green, Spanner, Study. The Doctor showed Spanner.")

        let suggestionWithUnknownShownCard = Suggestion(playerIndex: 1, suspectIndex: 1, weaponIndex: 5, roomIndex: 8, playerWhoShowedCard: 2, cardShownKind: nil)
        XCTAssertEqual(suggestionWithUnknownShownCard.playerWhoShowedCard, 2)
        XCTAssertNil(suggestionWithUnknownShownCard.cardShown)
        XCTAssertEqual(suggestionWithUnknownShownCard.toString(gameState: gameState), "Amy suggested Mr. Green, Spanner, Study. Rory showed a card.")

        let suggestionMadeByMeButNoOneShowed = Suggestion(playerIndex: 0, suspectIndex: 1, weaponIndex: 5, roomIndex: 8, playerWhoShowedCard: nil, cardShownKind: nil)
        XCTAssertFalse(suggestionMadeByMeButNoOneShowed.needsToSpecifyShownCard())
        
        let suggestionMadeByMe = Suggestion(playerIndex: 0, suspectIndex: 1, weaponIndex: 5, roomIndex: 8, playerWhoShowedCard: 1, cardShownKind: nil)
        XCTAssertTrue(suggestionMadeByMe.needsToSpecifyShownCard())
    }

}
