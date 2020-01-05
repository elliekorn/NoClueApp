//
//  ClueCardTests.swift
//  No ClueTests
//
//  Created by Leif Kornstaedt on 12/29/19.
//  Copyright © 2019 Leif Kornstaedt. All rights reserved.
//

import XCTest
@testable import No_Clue

class ClueCardTests: XCTestCase {

    func testClueCard() {
        let weaponCard = ClueCard(kind: .weapon, index: 1)
        XCTAssertEqual(weaponCard.kind, CardKind.weapon)
        XCTAssertEqual(weaponCard.index, 1)
        let suspectCard = ClueCard(kind: .suspect, index: 5)
        XCTAssertEqual(suspectCard.kind, CardKind.suspect)
        XCTAssertEqual(suspectCard.index, 5)
        let roomCard = ClueCard(kind: .room, index: 6)
        XCTAssertEqual(roomCard.kind, CardKind.room)
        XCTAssertEqual(roomCard.index, 6)

        XCTAssertTrue(weaponCard == weaponCard)
        XCTAssertFalse(weaponCard == suspectCard)
        XCTAssertFalse(ClueCard(kind: .suspect, index: 0) == ClueCard(kind: .suspect, index: 1))
        XCTAssertFalse(ClueCard(kind: .weapon, index: 0) == ClueCard(kind: .room, index: 0))
    }

}
