//
//  ClueCard.swift
//  No Clue
//
//  Created by Leif Kornstaedt on 12/27/19.
//  Copyright © 2019 Leif Kornstaedt. All rights reserved.
//

struct ClueCard: Hashable {
    
    let kind: CardKind
    let index: Int

    init(kind: CardKind, index: Int) {
        self.kind = kind
        self.index = index
    }

    static func == (lhs: ClueCard, rhs: ClueCard) -> Bool {
        return lhs.kind == rhs.kind && lhs.index == rhs.index
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.kind)
        hasher.combine(self.index)
    }

}
