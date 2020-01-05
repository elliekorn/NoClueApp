//
//  KnownInformation.swift
//  No Clue
//
//  Created by Leif Kornstaedt on 12/27/19.
//  Copyright © 2019 Leif Kornstaedt. All rights reserved.
//

import Foundation

class SerializableGameState: Codable {
    
    var playerNames: [String]
    let myCardIndices: [Int]
    let numberOfCardsHeld: [Int?]
    var suggestions: [Suggestion]
    var gameEditionName: String

    init(gameState: GameState) {
        let gameEdition = gameState.gameEdition

        self.playerNames = gameState.playerNames
        self.myCardIndices = gameState.myCards.map { gameEdition.cardToAllCardsIndex(card: $0) }
        self.numberOfCardsHeld = gameState.numberOfCardsHeld
        self.suggestions = gameState.getSuggestions()
        self.gameEditionName = gameEdition.editionName
    }

}

class GameState {

    typealias Knowledge = [[ClueCard: CardKnowledge]]
    let playerNames: [String]
    let myCards: [ClueCard]
    let numberOfCardsHeld: [Int?]
    let gameEdition: GameEdition

    private var logEntries: [LogEntry]
    private var knowledge: Knowledge!
    private var murderCards: [CardKind: [ClueCard]]
    private var existsConstraints: [Constraint]
    private var numberOfTimesShown: [Int]

    var numberOfPlayers: Int {
        get { return playerNames.count }
    }

    init(playerNames: [String], myCards: [ClueCard], numberOfCardsHeld: [Int?], gameEdition: GameEdition, simulated: Bool = false) {
        precondition(numberOfCardsHeld.count == playerNames.count - 1)

        self.playerNames = playerNames
        self.myCards = myCards
        self.numberOfCardsHeld = numberOfCardsHeld
        self.gameEdition = gameEdition
        self.logEntries = []
        self.murderCards = [:]
        self.existsConstraints = [Constraint]()
        self.numberOfTimesShown = [Int](repeating: 0, count: myCards.count)
        initializeKnowledge(simulated: simulated)
    }

    private func initializeKnowledge(simulated: Bool = false) {
        knowledge = [[ClueCard: CardKnowledge]]()
        for _ in 0 ..< playerNames.count {
            knowledge.append([ClueCard: CardKnowledge]())
        }

        let numberOfAllCards = gameEdition.allCards.count
        for i in 0 ..< numberOfAllCards {
            let card = gameEdition.allCardsIndexToCard(index: i)
            if myCards.contains(card) {
                recordPlayerMustHaveCard(playerIndex: 0, card: card, silent: true)
            } else if !simulated {
                recordPlayerCannotHaveCard(playerIndex: 0, card: card, silent: true)
            }
        }
    }

    convenience init(gameEdition: GameEdition, serializableGameState: SerializableGameState) {
        self.init(playerNames: serializableGameState.playerNames,
                  myCards: serializableGameState.myCardIndices.map { gameEdition.allCardsIndexToCard(index: $0) },
                  numberOfCardsHeld: serializableGameState.numberOfCardsHeld,
                  gameEdition: gameEdition)
        replaceSuggestions(logEntries: serializableGameState.suggestions)
    }

    func save() {
        let encodedData = encodeGameState()
        UserDefaults.standard.set(encodedData, forKey: "GameState")
    }

    func encodeGameState() -> Data? {
        let serializableGameState = SerializableGameState(gameState: self)
        return try? PropertyListEncoder().encode(serializableGameState)
    }

    static func restore() -> GameState? {
        let userDefaults = UserDefaults.standard
        if let encodedData = userDefaults.object(forKey: "GameState") as? Data {
            if let serializableGameState = try? PropertyListDecoder().decode(SerializableGameState.self, from: encodedData) {
                if let gameEdition = GameEditions.createEdition(fromEditionName: serializableGameState.gameEditionName) {
                    return GameState(gameEdition: gameEdition, serializableGameState: serializableGameState)
                }
            }
        }
        return nil
    }

    static func unsave() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "GameState")
    }

    func isValidGameMove(suggestion: Suggestion, simulated: Bool = false) -> String? {
        if suggestion.playerWhoShowedCard == suggestion.playerIndex {
            return "Showing player cannot be guessing player"
        }

        if !suggestion.needsToSpecifyShownCard() && suggestion.cardShown != nil {
            return "May not specify shown card"
        } else if suggestion.needsToSpecifyShownCard() && suggestion.cardShown == nil && !simulated {
            return "Must specify shown card"
        }

        if let cardShown = suggestion.cardShown {
            if suggestion.playerWhoShowedCard == 0 && !myCards.contains(cardShown) && !simulated {
                return "Not holding the shown card"
            }
        }

        return nil
    }

    func isInconsistentGameMove(suggestion: Suggestion) -> String? {
        let logIndex = numberOfLogEntries
        addSuggestion(suggestion)
        var i = logIndex
        var warningText: String? = nil
        while i < numberOfLogEntries {
            if let warning = log(forIndex: i) as? Warning {
                warningText = warning.toString(gameState: self)
                break
            }
            i += 1
        }
        deleteSuggestion(logIndex: logIndex)
        return warningText
    }

    func isGoodGameMove(suggestion: Suggestion) -> String? {
        if suggestion.playerIndex == 0 {
            let suggestionCards = suggestion.guessedCards()
            var checkingPlayerIndex = 1
            while true {
                // If player has one of the cards, break with a warning that I will be shown that card.
                var someUnknown = false
                for card in suggestionCards {
                    let knowledge = cardKnowledge(forPlayerIndex: checkingPlayerIndex, card: card)
                    if knowledge == .yes {
                        return playerNames[checkingPlayerIndex] + " already known to have " + gameEdition.cardName(card)
                    } else if knowledge != .no {
                        someUnknown = true
                    }
                }

                // If player is known not to have any of the cards, move on to next player.
                // Put differently, if for one of the cards, it is not known whether they player has it,
                // break out without warning.
                if someUnknown {
                    break
                }

                checkingPlayerIndex += 1

                if checkingPlayerIndex == playerNames.count {
                    return "This guess is not going to reveal new information"
                }
            }
        }
        return nil
    }

    func addSuggestion(_ suggestion: Suggestion, simulated: Bool = false) {
        precondition(isValidGameMove(suggestion: suggestion, simulated: simulated) == nil)

        logEntries.append(suggestion)
        infer(suggestion: suggestion)
        if suggestion.playerWhoShowedCard == 0 {
            if let cardShown = suggestion.cardShown {
                let myCardsIndex = myCards.firstIndex(of: cardShown)!
                numberOfTimesShown[myCardsIndex] += 1
            }
        }
    }

    func deleteSuggestion(logIndex: Int) {
        var newLogEntries = logEntries
        newLogEntries.remove(at: logIndex)
        replaceSuggestions(logEntries: newLogEntries)
    }

    func moveSuggestion(fromLogIndex: Int, toLogIndex: Int) {
        var newLogEntries = logEntries
        let movedLogEntry = logEntries[fromLogIndex]
        newLogEntries.remove(at: fromLogIndex)
        newLogEntries.insert(movedLogEntry, at: toLogIndex)
        replaceSuggestions(logEntries: newLogEntries)
    }

    func toggleSuggestion(logIndex: Int) {
        if let suggestion = logEntries[logIndex] as? Suggestion {
            var newLogEntries = logEntries
            newLogEntries.remove(at: logIndex)
            newLogEntries.insert(suggestion.toggle(), at: logIndex)
            replaceSuggestions(logEntries: newLogEntries)
        }
    }

    private func replaceSuggestions(logEntries: [LogEntry]) {
        self.logEntries = []
        self.murderCards = [:]
        self.existsConstraints = [Constraint]()
        self.numberOfTimesShown = [Int](repeating: 0, count: myCards.count)
        initializeKnowledge()
        for logEntry in logEntries {
            if let suggestion = logEntry as? Suggestion {
                addSuggestion(suggestion)
            }
        }
    }

    var numberOfLogEntries: Int {
        get { return logEntries.count }
    }

    func log(forIndex: Int) -> LogEntry {
        return logEntries[forIndex]
    }

    fileprivate func getSuggestions() -> [Suggestion] {
        var suggestions = [Suggestion]()
        for logEntry in self.logEntries {
            if let suggestion = logEntry as? Suggestion {
                suggestions.append(suggestion)
            }
        }
        return suggestions
    }

    func cardKnowledge(forPlayerIndex: Int, card: ClueCard) -> CardKnowledge {
        if let cardKnowledge = knowledge[forPlayerIndex][card] {
            return cardKnowledge
        } else {
            return .unknown
        }
    }

    func numberOfTimesShown(card: ClueCard) -> Int? {
        if let myCardsIndex = myCards.firstIndex(of: card) {
            return numberOfTimesShown[myCardsIndex]
        }
        return nil
    }

    private func infer(suggestion: Suggestion) {
        if suggestion.disabled {
            return
        }

        let suggestionCards = [ClueCard(kind: .suspect, index: suggestion.suspectIndex),
                               ClueCard(kind: .weapon, index: suggestion.weaponIndex),
                               ClueCard(kind: .room, index: suggestion.roomIndex)]

        if let playerWhoShowedCard = suggestion.playerWhoShowedCard {
            if let cardShown = suggestion.cardShown {
                // If we know which card was shown, the player who has shown it has it - and nobody else
                recordPlayerMustHaveCard(playerIndex: playerWhoShowedCard, card: cardShown)
            } else {
                // If a player has shown a card but we haven't seen it, record that they had one of the cards in the suggestion
                existsConstraints.append(Constraint(playerIndex: playerWhoShowedCard, cards: suggestionCards))
            }
        }

        // Any player who has not shown a card does not have any of the cards in the suggestion
        var askedPlayerIndex = (suggestion.playerIndex + 1) % playerNames.count
        while askedPlayerIndex != suggestion.playerIndex {
            if askedPlayerIndex != suggestion.playerWhoShowedCard {
                for card in suggestionCards {
                    recordPlayerCannotHaveCard(playerIndex: askedPlayerIndex, card: card)
                }
            } else {
                break
            }
            askedPlayerIndex = (askedPlayerIndex + 1) % playerNames.count
        }

        // Simplify constraints in a loop until none found to simplify
        var inferredMoreKnowledge = true
        while inferredMoreKnowledge {
            inferredMoreKnowledge = simplifyExistsConstraints()
            if checkPairsOfExistsContraints() {
                inferredMoreKnowledge = true
            }
            if checkKnowAllCardsOfAPlayer() {
                inferredMoreKnowledge = true
            }
            if updateMurderCards() {
                inferredMoreKnowledge = true
            }
            if assignNonMurderCards() {
                inferredMoreKnowledge = true
            }
        }

        for constraint in existsConstraints {
            logEntries.append(constraint)
        }
    }

    // Returns true iff we inferred more knowledge
    private func simplifyExistsConstraints() -> Bool {
        var inferredMoreKnowledge = false
        var remainingConstraints = [Constraint]()
        for constraint in existsConstraints {
            let playerIndex = constraint.playerIndex
            if let simplifiedConstraint = simplifyExistsConstraint(playerIndex: playerIndex, hasOneOf: constraint.cards) {
                if simplifiedConstraint.count == 1 {
                    // Only a single card left that the player could have - they have to have it
                    let card = simplifiedConstraint[0]
                    if knowledge[playerIndex][card] != .yes {
                        recordPlayerMustHaveCard(playerIndex: playerIndex, card: card)
                        inferredMoreKnowledge = true
                    }
                } else {
                    remainingConstraints.append(Constraint(playerIndex: playerIndex, cards: simplifiedConstraint))
                }
            }
        }
        existsConstraints = remainingConstraints
        return inferredMoreKnowledge
    }

    private func simplifyExistsConstraint(playerIndex: Int, hasOneOf: [ClueCard]) -> [ClueCard]? {
        var unknownCards = [ClueCard]()
        for card in hasOneOf {
            switch knowledge[playerIndex][card] {
            case .yes:
                // Do not need to remember constraint - we already know the player has one of the cards
                return nil
            case .no:
                ()
            default:
                unknownCards.append(card)
            }
        }
        if unknownCards.count == 0 {
            // inconsistency - this player cannot have any of the cards but has shown one
            logEntries.append(EmptyConstraintWarning(playerIndex: playerIndex, cards: hasOneOf))
            return nil
        }
        return unknownCards
    }

    // Returns true iff we inferred more knowledge
    private func checkPairsOfExistsContraints() -> Bool {
        // Check whether multiple constraints combine to provide new information.
        // For instance, if Ulrike is known to have A or B and Fritzi is known to have A or B,
        // nobody else can have A or B (including the cellar).
        var inferredMoreKnowledge = false
        var i = 0
        while i < existsConstraints.count {
            let firstConstraint = existsConstraints[i]
            if firstConstraint.cards.count == 2 {
                var j = i + 1
                while j < existsConstraints.count {
                    let secondConstraint = existsConstraints[j]
                    if areSameBinaryExistConstraintsForDifferentPlayers(first: firstConstraint, second: secondConstraint) {
                        if recordMaybes(playerIndex1: firstConstraint.playerIndex,
                                        playerIndex2: secondConstraint.playerIndex,
                                        card1: firstConstraint.cards[0],
                                        card2: firstConstraint.cards[1]) {
                            inferredMoreKnowledge = true
                        }
                    }
                    j += 1
                }
            }
            i += 1
        }
        return inferredMoreKnowledge
    }

    private func areSameBinaryExistConstraintsForDifferentPlayers(first: Constraint, second: Constraint) -> Bool {
        if first.playerIndex == second.playerIndex {
            return false
        }
        if first.cards.count != 2 || second.cards.count != 2 {
            return false
        }
        if first.cards[0] == second.cards[0] && first.cards[1] == second.cards[1] {
            return true
        }
        if first.cards[0] == second.cards[1] && first.cards[1] == second.cards[0] {
            // Note that during normal execution this will never happen as we happen to always keep cards within constraints sorted.
            return true
        }
        return false
    }

    // Returns true if we inferred more knowledg
    private func recordMaybes(playerIndex1: Int, playerIndex2: Int, card1: ClueCard, card2: ClueCard) -> Bool {
        var playerIndex = 0
        var inferredMoreKnowledge = false
        var updatedMaybes = false
        while playerIndex < playerNames.count {
            if playerIndex == playerIndex1 || playerIndex == playerIndex2 {
                if knowledge[playerIndex][card1] != .maybe {
                    knowledge[playerIndex][card1] = .maybe
                    updatedMaybes = true
                }
                if knowledge[playerIndex][card2] != .maybe {
                    knowledge[playerIndex][card2] = .maybe
                    updatedMaybes = true
                }
            } else {
                if eliminateCard(playerIndex: playerIndex, card: card1) {
                    inferredMoreKnowledge = true
                }
                if eliminateCard(playerIndex: playerIndex, card: card2) {
                    inferredMoreKnowledge = true
                }
            }
            playerIndex += 1
        }
        if updatedMaybes || inferredMoreKnowledge {
            logEntries.append(PlayersMayHaveCards(playerIndex1: playerIndex1, playerIndex2: playerIndex2, card1: card1, card2: card2))
        }
        return inferredMoreKnowledge
    }

    // Returns true if we didn't already know that
    private func eliminateCard(playerIndex: Int, card: ClueCard) -> Bool {
        let didntAlreadyKnow = knowledge[playerIndex][card] != .no
        recordPlayerCannotHaveCard(playerIndex: playerIndex, card: card, silent: true)
        return didntAlreadyKnow
    }

    private func checkKnowAllCardsOfAPlayer() -> Bool {
        var inferredMoreKnowledge = false
        for playerIndex in 1 ..< playerNames.count {
            if let numberOfCardsHeld = self.numberOfCardsHeld[playerIndex - 1] {
                var numberOfCardsKnown = 0
                var foundMaybe = false
                var numberOfCardsUnknownOrMaybe = 0
                for cardIndex in 0 ..< gameEdition.allCards.count {
                    let card = gameEdition.allCardsIndexToCard(index: cardIndex)
                    switch cardKnowledge(forPlayerIndex: playerIndex, card: card) {
                    case .yes:
                        numberOfCardsKnown += 1
                    case .maybe:
                        foundMaybe = true
                        numberOfCardsUnknownOrMaybe += 1
                    case .unknown:
                        numberOfCardsUnknownOrMaybe += 1
                    case .no:
                        break
                    }
                }
                if foundMaybe {
                    numberOfCardsKnown += 1
                }
                if numberOfCardsKnown == numberOfCardsHeld {
                    // I know all cards held by a player - so they cannot have any other cards.
                    for cardIndex in 0 ..< gameEdition.allCards.count {
                        let card = gameEdition.allCardsIndexToCard(index: cardIndex)
                        let knowledge = cardKnowledge(forPlayerIndex: playerIndex, card: card)
                        if knowledge != .yes && knowledge != .no && (!foundMaybe || knowledge != .maybe) {
                            inferredMoreKnowledge = true
                            recordPlayerCannotHaveCard(playerIndex: playerIndex, card: card)
                        }
                    }
                } else if numberOfCardsKnown == numberOfCardsHeld - 1 && numberOfCardsUnknownOrMaybe == 1 {
                    // I know all but one card held by a player - so they must have that last card.
                    for cardIndex in 0 ..< gameEdition.allCards.count {
                        let card = gameEdition.allCardsIndexToCard(index: cardIndex)
                        let knowledge = cardKnowledge(forPlayerIndex: playerIndex, card: card)
                        if knowledge == .unknown || knowledge == .maybe {
                            inferredMoreKnowledge = true
                            recordPlayerMustHaveCard(playerIndex: playerIndex, card: card)
                        }
                    }
                }
            }
        }
        return inferredMoreKnowledge
    }

    private func recordPlayerMustHaveCard(playerIndex: Int, card: ClueCard, silent: Bool = false) {
        var i = 0
        while i < playerNames.count {
            if i == playerIndex {
                if knowledge[i][card] == .yes {
                    return
                }
                if !silent {
                    logEntries.append(PlayerMustHaveCard(playerIndex: i, card: card))
                }
                if knowledge[i][card] == .no {
                    logEntries.append(ContradictionWarning(playerIndex: i, card: card, old: false))
                }
                knowledge[i][card] = .yes
            } else {
                recordPlayerCannotHaveCard(playerIndex: i, card: card, silent: true)
            }
            i += 1
        }
    }

    private func recordPlayerCannotHaveCard(playerIndex: Int, card: ClueCard, silent: Bool = false) {
        if knowledge[playerIndex][card] == .no {
            return
        }
        if !silent {
            logEntries.append(PlayerCannotHaveCard(playerIndex: playerIndex, card: card))
        }
        if knowledge[playerIndex][card] == .yes {
            logEntries.append(ContradictionWarning(playerIndex: playerIndex, card: card, old: true))
        }
        knowledge[playerIndex][card] = .no
    }

    func isMurderCard(_ card: ClueCard) -> Bool {
        return murderCards[card.kind] != nil && murderCards[card.kind]!.contains(card)
    }

    enum MurderCardState {
        case isMurderCard
        case canBeMurderCard
        case cannotBeMurderCard
        case unknown
    }

    private func updateMurderCards() -> Bool {
        let inferredMoreKnowledge1 = checkForMurderCards(kind: .suspect, numberOfCards: gameEdition.suspects.count)
        let inferredMoreKnowledge2 = checkForMurderCards(kind: .weapon, numberOfCards: gameEdition.weapons.count)
        let inferredMoreKnowledge3 = checkForMurderCards(kind: .room, numberOfCards: gameEdition.rooms.count)
        return inferredMoreKnowledge1 || inferredMoreKnowledge2 || inferredMoreKnowledge3
    }

    private func checkForMurderCards(kind: CardKind, numberOfCards: Int) -> Bool {
        var possibleMurderCards: [ClueCard]? = murderCards[kind] == nil ? [] : nil
        var i = 0
        while i < numberOfCards {
            let card = ClueCard(kind: kind, index: i)
            let murderCardState = checkForMurderCard(card: card)
            switch murderCardState {
            case .isMurderCard:
                if murderCards[kind] == nil {
                    murderCards[kind] = [card]
                    logEntries.append(MurderCard(card: card))
                } else if !murderCards[kind]!.contains(card) {
                    murderCards[kind]!.append(card)
                    logEntries.append(MultipleMurderCardsWarning(cards: murderCards[kind]!))
                }
                possibleMurderCards = nil
            case .canBeMurderCard:
                if possibleMurderCards != nil {
                    possibleMurderCards!.append(card)
                }
            case .cannotBeMurderCard:
                break
            case .unknown:
                possibleMurderCards = nil
            }
            i += 1
        }

        var inferredMoreKnowledge = false
        if possibleMurderCards != nil && possibleMurderCards!.count == 1 {
            let card = possibleMurderCards![0]
            murderCards[kind] = [card]
            logEntries.append(MurderCard(card: card))
            var playerIndex = 0
            while playerIndex < playerNames.count {
                if eliminateCard(playerIndex: playerIndex, card: card) {
                    inferredMoreKnowledge = true
                }
                playerIndex += 1
            }
        }
        return inferredMoreKnowledge
    }

    private func checkForMurderCard(card: ClueCard) -> MurderCardState {
        var allNo = true
        var allNoOrUnknown = true
        var allNoOrMaybe = true
        var someYes = false

        var playerIndex = 0
        while playerIndex < playerNames.count {
            switch cardKnowledge(forPlayerIndex: playerIndex, card: card) {
            case .unknown:
                allNo = false
                allNoOrMaybe = false
            case .yes:
                allNo = false
                allNoOrUnknown = false
                allNoOrMaybe = false
                someYes = true
            case .no:
                break
            case .maybe:
                allNo = false
                allNoOrUnknown = false
            }
            playerIndex += 1
        }
        return
            allNo ? .isMurderCard :
            allNoOrUnknown ? .canBeMurderCard :
            allNoOrMaybe || someYes ? .cannotBeMurderCard :
            .unknown
    }

    private func assignNonMurderCards() -> Bool {
        // If I know the murder card of a kind, then for any card of that kind that is known not to be held by any except one player, that player must have it.
        let inferredMoreKnowledge1 = assignNonMurderCards(kind: .suspect, numberOfCards: gameEdition.suspects.count)
        let inferredMoreKnowledge2 = assignNonMurderCards(kind: .weapon, numberOfCards: gameEdition.weapons.count)
        let inferredMoreKnowledge3 = assignNonMurderCards(kind: .room, numberOfCards: gameEdition.rooms.count)
        return inferredMoreKnowledge1 || inferredMoreKnowledge2 || inferredMoreKnowledge3
    }

    private func assignNonMurderCards(kind: CardKind, numberOfCards: Int) -> Bool {
        if murderCards[kind]?.count != 1 {
            return false
        }

        var inferredMoreKnowledge = false
        for cardIndex in 0 ..< numberOfCards {
            let card = ClueCard(kind: kind, index: cardIndex)
            var allNoOrUnknown = true
            var numberOfUnknown = 0
            for playerIndex in 0 ..< numberOfPlayers {
                switch cardKnowledge(forPlayerIndex: playerIndex, card: card) {
                case .unknown:
                    numberOfUnknown += 1
                case .maybe:
                    numberOfUnknown += 1
                case .no:
                    break
                case .yes:
                    allNoOrUnknown = false
                }
            }
            if allNoOrUnknown && numberOfUnknown == 1 {
                for playerIndex in 0 ..< numberOfPlayers {
                    let knowledge = cardKnowledge(forPlayerIndex: playerIndex, card: card)
                    if knowledge == .unknown || knowledge == .maybe {
                        inferredMoreKnowledge = true
                        recordPlayerMustHaveCard(playerIndex: playerIndex, card: card)
                    }
                }
            }
        }
        return inferredMoreKnowledge
    }

}
