//
//  GameStateTests.swift
//  No ClueTests
//
//  Created by Leif Kornstaedt on 12/29/19.
//  Copyright © 2019 Leif Kornstaedt. All rights reserved.
//

import XCTest
@testable import No_Clue

protocol Replay {
    var gameEdition: GameEdition { get }
    var playerNames: [String] { get }
    var myCards: [ClueCard] { get }
    var numberOfCardsHeld: [Int?] { get }
    var suggestions: [Suggestion] { get }
}

extension Replay {

    func replay(fromIndex: Int, toIndex: Int, gameState: GameState) {
        var i = fromIndex
        while i <= toIndex {
            let suggestion = suggestions[i]
            XCTAssertNil(gameState.isValidGameMove(suggestion: suggestion))
            XCTAssertNil(gameState.isInconsistentGameMove(suggestion: suggestion))
            XCTAssertNil(gameState.isGoodGameMove(suggestion: suggestion))
            gameState.addSuggestion(suggestion)
            i += 1
        }
    }

}

class GameStateTests: XCTestCase {

    let mrGreen = ClueCard(kind: .suspect, index: 1)
    let leadPipe = ClueCard(kind: .weapon, index: 2)
    let diningRoom = ClueCard(kind: .room, index: 3)

    var playerNames: [String]!
    var myCards: [ClueCard]!
    var numberOfCardsHeld: [Int?]!
    var gameEdition: AmericanModernGameEdition!
    var gameState: GameState!
    var replay: Replay!

    override func setUp() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "GameState")
    }

    override func tearDown() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "GameState")
    }

    private func setUpEmptyThreePlayerGame() {
        playerNames = ["The Doctor", "Amy", "Rory"]
        myCards = [ClueCard(kind: .suspect, index: 2),
                   ClueCard(kind: .weapon, index: 3),
                   ClueCard(kind: .room, index: 4)]
        numberOfCardsHeld = [nil, nil]
        gameEdition = AmericanModernGameEdition()
        gameState = GameState(playerNames: playerNames,
                              myCards: myCards,
                              numberOfCardsHeld: numberOfCardsHeld,
                              gameEdition: gameEdition)
    }

    private func setUpReplay(_ replay: Replay) {
        self.replay = replay
        self.playerNames = replay.playerNames
        self.myCards = replay.myCards
        self.numberOfCardsHeld = replay.numberOfCardsHeld
        self.gameEdition = replay.gameEdition as? AmericanModernGameEdition
        gameState = GameState(playerNames: playerNames,
                              myCards: myCards,
                              numberOfCardsHeld: numberOfCardsHeld,
                              gameEdition: gameEdition)
    }

    func testConstructor() {
        setUpEmptyThreePlayerGame()
        XCTAssertEqual(gameState.playerNames, playerNames)
        XCTAssertEqual(gameState.numberOfPlayers, playerNames.count)
        XCTAssertEqual(gameState.myCards, myCards)
        XCTAssertEqual(gameState.numberOfCardsHeld, numberOfCardsHeld)
        XCTAssertTrue(gameState.gameEdition as? AmericanModernGameEdition === gameEdition)
        XCTAssertEqual(gameState.numberOfLogEntries, 0)
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 0, card: myCards[0]), .yes)
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 0, card: myCards[1]), .yes)
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 0, card: myCards[2]), .yes)
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 1, card: myCards[0]), .no)
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 2, card: myCards[1]), .no)
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 1, card: myCards[2]), .no)
        let otherCard = ClueCard(kind: .room, index: 7)
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 0, card: otherCard), .no)
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 2, card: otherCard), .unknown)
    }

    func testSaveRestore() {
        // TODO:
    }

    func testIsValidGameMove() {
        setUpEmptyThreePlayerGame()

        let suggestionFromMyselfToMyself = Suggestion(playerIndex: 0, suspectIndex: 2, weaponIndex: 2, roomIndex: 3, playerWhoShowedCard: 0, cardShownKind: .suspect)
        XCTAssertEqual(gameState.isValidGameMove(suggestion: suggestionFromMyselfToMyself), "Showing player cannot be guessing player")

        let suggestionWithExtraneousShownCard = Suggestion(playerIndex: 1, suspectIndex: 2, weaponIndex: 2, roomIndex: 3, playerWhoShowedCard: 2, cardShownKind: .weapon)
        XCTAssertEqual(gameState.isValidGameMove(suggestion: suggestionWithExtraneousShownCard), "May not specify shown card")

        let suggestionWithMissingShownCard1 = Suggestion(playerIndex: 0, suspectIndex: 2, weaponIndex: 2, roomIndex: 3, playerWhoShowedCard: 2, cardShownKind: nil)
        XCTAssertEqual(gameState.isValidGameMove(suggestion: suggestionWithMissingShownCard1), "Must specify shown card")

        let suggestionWithMissingShownCard2 = Suggestion(playerIndex: 1, suspectIndex: 2, weaponIndex: 2, roomIndex: 3, playerWhoShowedCard: 0, cardShownKind: nil)
        XCTAssertEqual(gameState.isValidGameMove(suggestion: suggestionWithMissingShownCard2), "Must specify shown card")

        let suggestionWithMeShowingValidCard = Suggestion(playerIndex: 1, suspectIndex: 2, weaponIndex: 2, roomIndex: 3, playerWhoShowedCard: 0, cardShownKind: .suspect)
        XCTAssertNil(gameState.isValidGameMove(suggestion: suggestionWithMeShowingValidCard))

        let suggestionWithMeShowingCardIAmNotHolding = Suggestion(playerIndex: 1, suspectIndex: 2, weaponIndex: 2, roomIndex: 3, playerWhoShowedCard: 0, cardShownKind: .weapon)
        XCTAssertEqual(gameState.isValidGameMove(suggestion: suggestionWithMeShowingCardIAmNotHolding), "Not holding the shown card")
    }

    func testIsGoodGameMove() {
        setUpEmptyThreePlayerGame()

        // Find out that Player 1 has Suspect 1.
        let suggestionToAddKnownCard1 = Suggestion(playerIndex: 0, suspectIndex: 1, weaponIndex: 2, roomIndex: 3, playerWhoShowedCard: 1, cardShownKind: .suspect)
        XCTAssertNil(gameState.isGoodGameMove(suggestion: suggestionToAddKnownCard1))
        gameState.addSuggestion(suggestionToAddKnownCard1)

        // Asking whether Player 1 has Suspect 1 is now not a good move.
        XCTAssertEqual(gameState.isGoodGameMove(suggestion: suggestionToAddKnownCard1), "Amy already known to have Mr. Green")

        // Find out that Player 2 has Suspect 3.
        let suggestionToAddKnownCard2 = Suggestion(playerIndex: 0, suspectIndex: 3, weaponIndex: 2, roomIndex: 3, playerWhoShowedCard: 2, cardShownKind: .suspect)
        XCTAssertNil(gameState.isGoodGameMove(suggestion: suggestionToAddKnownCard2))
        gameState.addSuggestion(suggestionToAddKnownCard2)

        // Asking whether Player 2 has Suspect 3 is now not a good move (skipping a player).
        XCTAssertEqual(gameState.isGoodGameMove(suggestion: suggestionToAddKnownCard2), "Rory already known to have Professor Plum")

        let suggestionAboutOnlyCardsIHave = Suggestion(playerIndex: 0, suspectIndex: 2, weaponIndex: 3, roomIndex: 4, playerWhoShowedCard: nil, cardShownKind: nil)
        XCTAssertEqual(gameState.isGoodGameMove(suggestion: suggestionAboutOnlyCardsIHave), "This guess is not going to reveal new information")
    }

    func testIGetShownCardByDirectNeighbor() {
        setUpEmptyThreePlayerGame()

        // Find our that Player 1 has Mr. Green.
        let suggestion0 = Suggestion(playerIndex: 0, suspectIndex: 1, weaponIndex: 2, roomIndex: 3, playerWhoShowedCard: 1, cardShownKind: .suspect)
        gameState.addSuggestion(suggestion0)

        XCTAssertEqual(gameState.numberOfLogEntries, 2)
        let logEntry0 = gameState.log(forIndex: 0)
        XCTAssertTrue(logEntry0 as? Suggestion === suggestion0)
        let logEntry1 = gameState.log(forIndex: 1) as? PlayerMustHaveCard
        XCTAssertNotNil(logEntry1)
        XCTAssertEqual(logEntry1?.playerIndex, 1)
        XCTAssertEqual(logEntry1?.card, mrGreen)

        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 0, card: mrGreen), .no)
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 0, card: leadPipe), .no)
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 0, card: diningRoom), .no)

        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 1, card: mrGreen), .yes)
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 1, card: leadPipe), .unknown)
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 1, card: diningRoom), .unknown)

        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 2, card: mrGreen), .no)
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 2, card: leadPipe), .unknown)
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 2, card: diningRoom), .unknown)
    }

    func testDirectNeighborDoesNotShowCard() {
        setUpEmptyThreePlayerGame()

        // Find out that Player 2 has Mr. Green.
        let suggestion0 = Suggestion(playerIndex: 0, suspectIndex: 1, weaponIndex: 2, roomIndex: 3, playerWhoShowedCard: 2, cardShownKind: .suspect)
        gameState.addSuggestion(suggestion0)

        XCTAssertEqual(gameState.numberOfLogEntries, 4)
        let logEntry0 = gameState.log(forIndex: 0)
        XCTAssertTrue(logEntry0 as? Suggestion === suggestion0)
        let logEntry1 = gameState.log(forIndex: 1) as? PlayerMustHaveCard
        XCTAssertNotNil(logEntry1)
        XCTAssertEqual(logEntry1?.playerIndex, 2)
        XCTAssertEqual(logEntry1?.card, mrGreen)
        let logEntry2 = gameState.log(forIndex: 2) as? PlayerCannotHaveCard
        XCTAssertNotNil(logEntry2)
        XCTAssertEqual(logEntry2?.playerIndex, 1)
        XCTAssertEqual(logEntry2?.card, leadPipe)
        let logEntry3 = gameState.log(forIndex: 3) as? PlayerCannotHaveCard
        XCTAssertNotNil(logEntry3)
        XCTAssertEqual(logEntry3?.playerIndex, 1)
        XCTAssertEqual(logEntry3?.card, diningRoom)

        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 0, card: mrGreen), .no)
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 0, card: leadPipe), .no)
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 0, card: diningRoom), .no)

        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 1, card: mrGreen), .no)
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 1, card: leadPipe), .no)
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 1, card: diningRoom), .no)

        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 2, card: mrGreen), .yes)
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 2, card: leadPipe), .unknown)
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 2, card: diningRoom), .unknown)
    }

    func testInferFromConstraint() {
        setUpEmptyThreePlayerGame()

        // Observe how Player 1 asks Player 2 and is shown a card.
        let suggestion0 = Suggestion(playerIndex: 1, suspectIndex: 1, weaponIndex: 2, roomIndex: 3, playerWhoShowedCard: 2, cardShownKind: nil)
        gameState.addSuggestion(suggestion0)

        XCTAssertEqual(gameState.numberOfLogEntries, 2)
        let logEntry0 = gameState.log(forIndex: 0)
        XCTAssertTrue(logEntry0 as? Suggestion === suggestion0)
        let logEntry1 = gameState.log(forIndex: 1)
        XCTAssertTrue(logEntry1 is Constraint)
        let constraint1 = logEntry1 as! Constraint
        XCTAssertEqual(constraint1.playerIndex, 2)
        XCTAssertEqual(constraint1.cards, [ClueCard(kind: .suspect, index: 1),
                                           ClueCard(kind: .weapon, index: 2),
                                           ClueCard(kind: .room, index: 3)])

        // Observe how Player 1 asks Player 2 and is shown a card, but we can simplify the constraint to remove a card we're holding ourselves.
        let suggestion1 = Suggestion(playerIndex: 1, suspectIndex: 2, weaponIndex: 2, roomIndex: 3, playerWhoShowedCard: 2, cardShownKind: nil)
        gameState.addSuggestion(suggestion1)

        XCTAssertEqual(gameState.numberOfLogEntries, 5)
        let logEntry2 = gameState.log(forIndex: 2)
        XCTAssertTrue(logEntry2 as? Suggestion === suggestion1)
        let logEntry3 = gameState.log(forIndex: 3)
        XCTAssertTrue(logEntry3 is Constraint)
        let constraint3 = logEntry3 as! Constraint
        XCTAssertEqual(constraint3.cards, constraint1.cards)
        let logEntry4 = gameState.log(forIndex: 4)
        XCTAssertTrue(logEntry4 is Constraint)
        let constraint4 = logEntry4 as! Constraint
        XCTAssertEqual(constraint4.playerIndex, 2)
        XCTAssertEqual(constraint4.cards, [ClueCard(kind: .weapon, index: 2),
                                           ClueCard(kind: .room, index: 3)])

        // Find out that Player 1 has Room 3. This then causes us to infer that Player 2 has Weapon 2, and both constraints disappear.
        let suggestion2 = Suggestion(playerIndex: 0, suspectIndex: 5, weaponIndex: 5, roomIndex: 3, playerWhoShowedCard: 1, cardShownKind: .room)
        gameState.addSuggestion(suggestion2)

        XCTAssertEqual(gameState.numberOfLogEntries, 8)
        let logEntry5 = gameState.log(forIndex: 5)
        XCTAssertTrue(logEntry5 as? Suggestion === suggestion2)
        let logEntry6 = gameState.log(forIndex: 6) as? PlayerMustHaveCard
        XCTAssertNotNil(logEntry6)
        XCTAssertEqual(logEntry6?.playerIndex, 1)
        XCTAssertEqual(logEntry6?.card, ClueCard(kind: .room, index: 3))
        let logEntry7 = gameState.log(forIndex: 7) as? PlayerMustHaveCard
        XCTAssertNotNil(logEntry7)
        XCTAssertEqual(logEntry7?.playerIndex, 2)
        XCTAssertEqual(logEntry7?.card, ClueCard(kind: .weapon, index: 2))
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 2, card: ClueCard(kind: .weapon, index: 2)), .yes)
    }

    func testInferenceOfMaybeKnowledge() {
        setUpReplay(Replay1())
        replay.replay(fromIndex: 0, toIndex: 17, gameState: gameState)

        // If we replay 0..17, we see .maybe values: Ulrike/Fritzi, Suspect 1 and Room 1.
        // We infer that Felix cannot have Suspect 1, and Felix cannot have Room 1 (and we are still tracking 3 constraints).
        let n = gameState.numberOfLogEntries
        XCTAssertTrue(gameState.log(forIndex: n - 1) is Constraint)
        XCTAssertTrue(gameState.log(forIndex: n - 2) is Constraint)
        XCTAssertTrue(gameState.log(forIndex: n - 3) is Constraint)
        XCTAssertTrue(gameState.log(forIndex: n - 4) is PlayersMayHaveCards)
        XCTAssertTrue(gameState.log(forIndex: n - 5) is PlayerMustHaveCard)
        XCTAssertTrue(gameState.log(forIndex: n - 6) is PlayerCannotHaveCard)
        XCTAssertTrue(gameState.log(forIndex: n - 7) is PlayerCannotHaveCard)
        XCTAssertTrue(gameState.log(forIndex: n - 8) is PlayerCannotHaveCard)
        XCTAssertTrue(gameState.log(forIndex: n - 9) is Suggestion)

        let playerMustHaveCard = gameState.log(forIndex: n - 5) as? PlayerMustHaveCard
        let playersMayHaveCards = gameState.log(forIndex: n - 4) as? PlayersMayHaveCards
        XCTAssertEqual(playerMustHaveCard?.playerIndex, 2)
        XCTAssertEqual(playerMustHaveCard?.card, ClueCard(kind: .room, index: 0))
        XCTAssertEqual(playersMayHaveCards?.playerIndex1, 2)
        XCTAssertEqual(playersMayHaveCards?.playerIndex2, 3)
        XCTAssertEqual(playersMayHaveCards?.card1, ClueCard(kind: .suspect, index: 1))
        XCTAssertEqual(playersMayHaveCards?.card2, ClueCard(kind: .room, index: 1))

        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 2, card: ClueCard(kind: .suspect, index: 1)), .maybe)
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 3, card: ClueCard(kind: .suspect, index: 1)), .maybe)
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 2, card: ClueCard(kind: .room, index: 1)), .maybe)
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 3, card: ClueCard(kind: .room, index: 1)), .maybe)

        // If we replay 0..18, we infer that Weapon 2 is a murder card.
        XCTAssertFalse(gameState.isMurderCard(ClueCard(kind: .weapon, index: 2)))
        replay.replay(fromIndex: 18, toIndex: 18, gameState: gameState)
        XCTAssertTrue(gameState.isMurderCard(ClueCard(kind: .weapon, index: 2)))

        // If we replay 0..21, we infer that Suspect 4 is a murder card and that Room 7 is a murder card.
        XCTAssertFalse(gameState.isMurderCard(ClueCard(kind: .suspect, index: 4)))
        XCTAssertFalse(gameState.isMurderCard(ClueCard(kind: .room, index: 7)))
        replay.replay(fromIndex: 19, toIndex: 21, gameState: gameState)
        XCTAssertTrue(gameState.isMurderCard(ClueCard(kind: .suspect, index: 4)))
        XCTAssertTrue(gameState.isMurderCard(ClueCard(kind: .room, index: 7)))

        replay.replay(fromIndex: 22, toIndex: 22, gameState: gameState)
    }

    func testInferenceBasedOnMurderCardsWithMaybes() {
        setUpReplay(Replay1())
        replay.replay(fromIndex: 0, toIndex: 20, gameState: gameState)

        // Create a constraint that would be removed by the inference of a murder card.
        gameState.addSuggestion(Suggestion(playerIndex: 2, suspectIndex: 2, weaponIndex: 3, roomIndex: 7, playerWhoShowedCard: 3, cardShownKind: nil))
        let constraint = gameState.log(forIndex: gameState.numberOfLogEntries - 1) as? Constraint
        XCTAssertNotNil(constraint)
        XCTAssertEqual(constraint?.playerIndex, 3)
        XCTAssertEqual(constraint?.cards, [ClueCard(kind: .weapon, index: 3), ClueCard(kind: .room, index: 7)])

        // The game move that infers Hall to be a murder card, which should eliminate the constraint and we know that Player 3 has Revolver.
        replay.replay(fromIndex: 21, toIndex: 21, gameState: gameState)
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 3, card: ClueCard(kind: .weapon, index: 3)), .yes)
    }

    func testInferenceBasedOnNumberCardsHeld1() {
        setUpReplay(Replay2())
        replay.replay(fromIndex: 0, toIndex: 19, gameState: gameState)

        XCTAssertFalse(gameState.isMurderCard(ClueCard(kind: .suspect, index: 1)))

        XCTAssertFalse(gameState.isMurderCard(ClueCard(kind: .weapon, index: 2)))
        XCTAssertFalse(gameState.isMurderCard(ClueCard(kind: .room, index: 3)))
        replay.replay(fromIndex: 20, toIndex: 20, gameState: gameState)
        XCTAssertTrue(gameState.isMurderCard(ClueCard(kind: .weapon, index: 2)))
        XCTAssertTrue(gameState.isMurderCard(ClueCard(kind: .room, index: 3)))
    }

    func testInferenceBasedOnNumberCardsHeld2() {
        setUpReplay(Replay3())
        replay.replay(fromIndex: 0, toIndex: 21, gameState: gameState)

        // Inference based on number of cards and presence of a ".maybe" allows us to infer .no for everything else
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 4, card: ClueCard(kind: .weapon, index: 5)), .no)

        replay.replay(fromIndex: 22, toIndex: 28, gameState: gameState)

        // We know 3 out of 4 of Felix's cards. If he didn't have Spanner or Kitchen, he would have to have Hall.
        // Also, Großmama would have to have Spanner and Kitchen.
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 3, card: ClueCard(kind: .weapon, index: 5)), .unknown)
        gameState.addSuggestion(Suggestion(playerIndex: 0, suspectIndex: 3, weaponIndex: 5, roomIndex: 3, playerWhoShowedCard: 2, cardShownKind: .room))
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 3, card: ClueCard(kind: .weapon, index: 5)), .yes)

        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 1, card: ClueCard(kind: .room, index: 7)), .unknown)
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 3, card: ClueCard(kind: .room, index: 0)), .unknown)
        gameState.addSuggestion(Suggestion(playerIndex: 0, suspectIndex: 3, weaponIndex: 0, roomIndex: 0, playerWhoShowedCard: 2, cardShownKind: .weapon))
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 1, card: ClueCard(kind: .room, index: 7)), .yes)
        XCTAssertEqual(gameState.cardKnowledge(forPlayerIndex: 3, card: ClueCard(kind: .room, index: 0)), .yes)
    }

    func testDirectNeighborFailedToShowCardWhenTheyHadIt() {
        // TODO:
    }

    func testConflictingMurderCards() {
        // TODO:
    }

    func testMisrecordedThatAPlayerShowedACardWhenWeLaterLearnTheyCouldNotHaveIt() {
        // TODO: this should bring coverage of simplifyExistConstraint to 100%
        // TODO: check for EmptyConstraintWarning
    }

    func testIncorrectNoCardShow() {
        setUpEmptyThreePlayerGame()

        let invalidSuggestion = Suggestion(playerIndex: 1, suspectIndex: 2, weaponIndex: 3, roomIndex: 4, playerWhoShowedCard: nil, cardShownKind: nil)
        XCTAssertEqual(gameState.isInconsistentGameMove(suggestion: invalidSuggestion), "The Doctor was believed to have Colonel Mustard, but is now implied not to have it. Try to correct the mistake!")
        gameState.addSuggestion(invalidSuggestion)
        XCTAssertEqual(gameState.numberOfLogEntries, 10)
        XCTAssertTrue(gameState.log(forIndex: 2) is ContradictionWarning)
        XCTAssertTrue(gameState.log(forIndex: 4) is ContradictionWarning)
        XCTAssertTrue(gameState.log(forIndex: 6) is ContradictionWarning)
        let warning1 = gameState.log(forIndex: 2) as! ContradictionWarning
        XCTAssertEqual(warning1.playerIndex, 0)
        XCTAssertEqual(warning1.card, ClueCard(kind: .suspect, index: 2))
        let warning2 = gameState.log(forIndex: 4) as! ContradictionWarning
        XCTAssertEqual(warning2.playerIndex, 0)
        XCTAssertEqual(warning2.card, ClueCard(kind: .weapon, index: 3))
        let warning3 = gameState.log(forIndex: 6) as! ContradictionWarning
        XCTAssertEqual(warning3.playerIndex, 0)
        XCTAssertEqual(warning3.card, ClueCard(kind: .room, index: 4))
    }

    func testEmergencyEdit() {
        // TODO:
    }

}
