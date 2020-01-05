//
//  GameplayViewController.swift
//  No Clue
//
//  Created by Leif Kornstaedt on 12/26/19.
//  Copyright © 2019 Leif Kornstaedt. All rights reserved.
//

import UIKit

class GameplayViewController: UIViewController {

    private var knownInformationTableData: KnownInformationTableData!

    @IBOutlet weak var knownInformationTableView: UITableView!
    @IBOutlet weak var perspectiveControl: UISegmentedControl!

    // Parameter passed in segue
    var gameState: GameState!

    override func viewDidLoad() {
        self.knownInformationTableData = KnownInformationTableData(gameState: self.gameState)
        self.knownInformationTableView.dataSource = self.knownInformationTableData
        self.knownInformationTableView.delegate = self.knownInformationTableData

        self.perspectiveControl.removeAllSegments()
        for i in 0 ..< self.gameState.numberOfPlayers {
            self.perspectiveControl.insertSegment(withTitle: self.gameState.playerNames[i], at: i, animated: false)
        }
        self.perspectiveControl.selectedSegmentIndex = 0
    }

    override func viewWillAppear(_ animated: Bool) {
        self.perspectiveControl.selectedSegmentIndex = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        updateKnowledge(playerOffset: self.perspectiveControl.selectedSegmentIndex)
    }

    @IBAction func perspectiveChanged(_ sender: Any) {
        updateKnowledge(playerOffset: self.perspectiveControl.selectedSegmentIndex)
    }

    private func updateKnowledge(playerOffset: Int) {
        let displayGameState: GameState
        if playerOffset == 0 {
            displayGameState = gameState
        } else {
            var simulatedPlayerNames = [String]()
            for i in 0 ..< gameState.numberOfPlayers {
                simulatedPlayerNames.append(gameState.playerNames[(i + playerOffset) % gameState.numberOfPlayers])
            }

            var simulatedMyCards = [ClueCard]()
            for cardIndex in 0 ..< gameState.gameEdition.allCards.count {
                let card = gameState.gameEdition.allCardsIndexToCard(index: cardIndex)
                if gameState.cardKnowledge(forPlayerIndex: playerOffset, card: card) == .yes {
                    simulatedMyCards.append(card)
                }
            }

            var simulatedNumberOfCardsHeld = [Int?]()
            for i in playerOffset ..< gameState.numberOfCardsHeld.count {
                simulatedNumberOfCardsHeld.append(gameState.numberOfCardsHeld[i])
            }
            simulatedNumberOfCardsHeld.append(gameState.myCards.count)
            for i in 0 ..< playerOffset - 1 {
                simulatedNumberOfCardsHeld.append(gameState.numberOfCardsHeld[i])
            }

            let simulatedGameState = GameState(playerNames: simulatedPlayerNames, myCards: simulatedMyCards, numberOfCardsHeld: simulatedNumberOfCardsHeld, gameEdition: gameState.gameEdition, simulated: true)

            for i in 0 ..< gameState.numberOfLogEntries {
                if let suggestion = gameState.log(forIndex: i) as? Suggestion {
                    let simulatedPlayerIndex = (gameState.numberOfPlayers + suggestion.playerIndex - playerOffset) % gameState.numberOfPlayers
                    let simulatedPlayerWhoShowedCard = suggestion.playerWhoShowedCard == nil ? nil : (gameState.numberOfPlayers + suggestion.playerWhoShowedCard! - playerOffset) % gameState.numberOfPlayers
                    let simulatedCardShown = suggestion.playerIndex == playerOffset ? suggestion.cardShown : nil
                    let simulatedSuggestion = Suggestion(playerIndex: simulatedPlayerIndex, suspectIndex: suggestion.suspectIndex, weaponIndex: suggestion.weaponIndex, roomIndex: suggestion.roomIndex, playerWhoShowedCard: simulatedPlayerWhoShowedCard, cardShownKind: simulatedCardShown?.kind)
                    simulatedGameState.addSuggestion(simulatedSuggestion, simulated: true)
                }
            }
            displayGameState = simulatedGameState
        }

        self.knownInformationTableData.updateKnowledge(playerOffset: playerOffset, displayGameState: displayGameState)
    }

}
