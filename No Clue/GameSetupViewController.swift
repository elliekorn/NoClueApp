//
//  ViewController.swift
//  No Clue
//
//  Created by Leif Kornstaedt on 12/26/19.
//  Copyright © 2019 Leif Kornstaedt. All rights reserved.
//

import UIKit

class GameSetupViewController: UIViewController {

    private let gameEdition: GameEdition = AmericanModernGameEdition()

    // hold on to alert while it's displayed to avoid access to released object
    private var alert: MyAlert?
    // hold on to picker popup while it's displayed to avoid access to released object
    private var pickerPopup: MyPickerPopup?

    @IBOutlet weak var playerTableView: UITableView!
    @IBOutlet weak var cardTableView: UITableView!
    @IBOutlet weak var cardsToAssignLabel: UILabel!
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var cardPickerView: UIPickerView!
    @IBOutlet weak var cardPickerCover: UILabel!
    @IBOutlet weak var cardPickerToolbar: UIToolbar!
    
    var playerTableData: PlayerTableData
    var cardTableData: CardTableData

    required init?(coder: NSCoder) {
        self.playerTableData = PlayerTableData()
        self.cardTableData = CardTableData(gameEdition: gameEdition)
        super.init(coder: coder)
        self.playerTableData.viewController = self
        self.cardTableData.viewController = self
    }

    override func viewDidLoad() {
        self.playerTableView.delegate = self.playerTableData
        self.playerTableView.dataSource = self.playerTableData
        self.playerTableView.setEditing(true, animated: true)
        self.cardTableView.delegate = self.cardTableData
        self.cardTableView.dataSource = self.cardTableData
        self.cardTableView.setEditing(true, animated: true)
        self.cardPickerView.isHidden = true
        self.cardPickerCover.isHidden = true
        self.cardPickerToolbar.isHidden = true
        gameInformationUpdated()
        super.viewDidLoad()

/*
        let replay = Replay3()
        let replayGameState = GameState(playerNames: replay.playerNames, myCards: replay.myCards, numberOfCardsHeld: replay.numberOfCardsHeld, gameEdition: replay.gameEdition)
        for i in 0 ..< replay.suggestions.count {
            replayGameState.addSuggestion(replay.suggestions[i])
        }
        replayGameState.save()
 */
        if let restoredGameState = GameState.restore() {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.performSegue(withIdentifier: "StartGameSegue", sender: restoredGameState)
            }
        }
    }

    @IBAction func unwindToGameSetup(segue: UIStoryboardSegue) {
        self.cardTableData.clear(tableView: self.cardTableView)
        self.cardTableView.reloadData()
    }

    @IBAction func addPlayer(_ sender: Any) {
        if self.playerTableData.numberOfPlayers < self.gameEdition.maxNumberOfPlayers {
            self.alert = MyAlert(controller: self, title: "Add Player", message: "Enter name for this player:",
                textFieldPlaceholder: "Name", text: "",
                button: "Done") {
                    (enteredText: String) in
                    if !enteredText.isEmpty {
                        self.playerTableData.addPlayer(enteredText)
                        self.playerTableView.insertRows(at: [IndexPath(indexes: [0, self.playerTableData.numberOfPlayers - 1])], with: .automatic)
                    }
                    self.alert = nil
                }
        }
    }
    
    func gameInformationUpdated() {
        var cardsToAssign = gameEdition.allCards.count - 3
        cardsToAssign -= cardTableData.numberOfCards
        var totalIsUnknown = false
        for numberOfCardsHeld in playerTableData.getNumberOfCardsHeld() {
            if let n = numberOfCardsHeld {
                cardsToAssign -= n
            } else {
                totalIsUnknown = true
            }
        }
        cardsToAssignLabel.text = String(cardsToAssign)
        cardsToAssignLabel.textColor = cardsToAssign < 0 ? .systemRed : .label

        self.startGameButton.isEnabled =
            self.playerTableData.numberOfPlayers >= self.gameEdition.minNumberOfPlayers &&
            (totalIsUnknown && cardsToAssign >= 0 || cardsToAssign == 0)
    }
    
    @IBAction func addCard(_ sender: Any) {
        var cards = [ClueCard]()
        var i = 0
        let myCards = cardTableData.getCards()
        while i < gameEdition.allCards.count {
            let card = gameEdition.allCardsIndexToCard(index: i)
            if !myCards.contains(card) {
                cards.append(card)
            }
            i += 1
        }
        self.pickerPopup = MyPickerPopup(
            cards.map { gameEdition.cardName($0) },
            row: 0,
            pickerView: self.cardPickerView,
            pickerCover: self.cardPickerCover,
            pickerToolbar: self.cardPickerToolbar) { (row: Int) in
                let card = cards[row]
                if let i = self.cardTableData.addCard(card) {
                    self.cardTableView.insertRows(at: [IndexPath(indexes: [0, i])], with: .automatic)
                    self.gameInformationUpdated()
                }
            }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StartGameSegue" {
            let gameState: GameState
            if let restoredGameState = sender as? GameState {
                gameState = restoredGameState
            } else {
                let playerNames = self.playerTableData.getPlayerNames()
                let myCards = self.cardTableData.getCards()
                let numberOfCardsHeld = self.playerTableData.getNumberOfCardsHeld()
                gameState = GameState(
                    playerNames: playerNames,
                    myCards: myCards,
                    numberOfCardsHeld: numberOfCardsHeld,
                    gameEdition: self.gameEdition)
                gameState.save()
            }

            let tabBarController = segue.destination as! UITabBarController

            let gameplayViewController = tabBarController.viewControllers![0] as! GameplayViewController
            gameplayViewController.gameState = gameState

            let suggestionViewController = tabBarController.viewControllers![1] as! SuggestionViewController
            suggestionViewController.gameState = gameState

            let suggestionLogViewController = tabBarController.viewControllers![2] as! SuggestionLogViewController
            suggestionLogViewController.gameState = gameState

            let gameManagementViewController = tabBarController.viewControllers![3] as! GameManagementViewController
            gameManagementViewController.gameState = gameState
        }
    }

}

