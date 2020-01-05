//
//  GameEditionTests.swift
//  No ClueTests
//
//  Created by Leif Kornstaedt on 12/29/19.
//  Copyright © 2019 Leif Kornstaedt. All rights reserved.
//

import XCTest
@testable import No_Clue

class GameEditionTests: XCTestCase {

    func testKindName() {
        let gameEdition = AmericanModernGameEdition()
        XCTAssertEqual(gameEdition.editionName, "American Modern")
        XCTAssertEqual(gameEdition.kindName(.suspect), "Suspects")
        XCTAssertEqual(gameEdition.kindName(.weapon), "Weapons")
        XCTAssertEqual(gameEdition.kindName(.room), "Rooms")
    }

    func testCardName() {
        let gameEdition = AmericanModernGameEdition()
        XCTAssertEqual(gameEdition.cardName(ClueCard(kind: .suspect, index: 1)), "Mr. Green")
        XCTAssertEqual(gameEdition.cardName(ClueCard(kind: .weapon, index: 2)), "Lead Pipe")
        XCTAssertEqual(gameEdition.cardName(ClueCard(kind: .room, index: 3)), "Dining Room")
    }

    func testAllCards() {
        let gameEdition = AmericanModernGameEdition()

        let numberOfSuspects = gameEdition.suspects.count
        let numberOfWeapons = gameEdition.weapons.count
        let numberOfRooms = gameEdition.rooms.count
        XCTAssertEqual(numberOfSuspects, 6)
        XCTAssertEqual(numberOfWeapons, 6)
        XCTAssertEqual(numberOfRooms, 9)
        XCTAssertEqual(gameEdition.allCards.count, numberOfSuspects + numberOfWeapons + numberOfRooms)
        XCTAssertEqual(gameEdition.allCards[numberOfSuspects], gameEdition.weapons[0])
        XCTAssertEqual(gameEdition.allCards[numberOfSuspects + numberOfWeapons], gameEdition.rooms[0])
        XCTAssertEqual(gameEdition.allCards[gameEdition.allCards.count - 1], gameEdition.rooms[numberOfRooms - 1])

        let suspectCard = ClueCard(kind: .suspect, index: 2)
        let suspectCardIndex = gameEdition.cardToAllCardsIndex(card: suspectCard)
        XCTAssertEqual(suspectCardIndex, suspectCard.index)
        XCTAssertEqual(gameEdition.allCardsIndexToCard(index: suspectCardIndex), suspectCard)
        let weaponCard = ClueCard(kind: .weapon, index: 3)
        let weaponCardIndex = gameEdition.cardToAllCardsIndex(card: weaponCard)
        XCTAssertEqual(weaponCardIndex, numberOfSuspects + weaponCard.index)
        XCTAssertEqual(gameEdition.allCardsIndexToCard(index: weaponCardIndex), weaponCard)
        let roomCard = ClueCard(kind: .room, index: 7)
        let roomCardIndex = gameEdition.cardToAllCardsIndex(card: roomCard)
        XCTAssertEqual(roomCardIndex, numberOfSuspects + numberOfWeapons + roomCard.index)
        XCTAssertEqual(gameEdition.allCardsIndexToCard(index: roomCardIndex), roomCard)
    }

}
