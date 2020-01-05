//
//  SuggestionViewController.swift
//  No Clue
//
//  Created by Leif Kornstaedt on 12/27/19.
//  Copyright © 2019 Leif Kornstaedt. All rights reserved.
//

import UIKit

class SuggestionViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var pickerCover: UILabel!
    @IBOutlet weak var pickerToolbar: UIToolbar!
    @IBOutlet weak var whoIsGuessingField: UITextField!
    @IBOutlet weak var suspectField: UITextField!
    @IBOutlet weak var weaponField: UITextField!
    @IBOutlet weak var roomField: UITextField!
    @IBOutlet weak var whichPlayerShowedField: UITextField!
    @IBOutlet weak var whichCardShownLabel: UILabel!
    @IBOutlet weak var whichCardShownField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var addSuggestionButton: UIButton!
    
    // hold on to picker popup while it's displayed to avoid access to released object
    var pickerPopup: MyPickerPopup?

    // Parameter passed in segue
    var _gameState: GameState!
    var gameState: GameState {
        get { return _gameState }
        set { _gameState = newValue }
    }

    var playerIndex: Int?
    var suspectIndex: Int?
    var weaponIndex: Int?
    var roomIndex: Int?
    var playerWhoShowedCard: Int?
    var cardShown: ClueCard?

    override func viewDidLoad() {
        pickerView.isHidden = true
        pickerCover.isHidden = true
        pickerToolbar.isHidden = true
        self.whoIsGuessingField.delegate = self
        self.suspectField.delegate = self
        self.weaponField.delegate = self
        self.roomField.delegate = self
        self.whichPlayerShowedField.delegate = self
        self.whichCardShownField.delegate = self
        validate()
    }

    override func viewDidAppear(_ animated: Bool) {
        // Refresh fields in case an edit has happened.
        if let suspectIndex = self.suspectIndex {
            suspectField.text = getAnnotatedCard(ClueCard(kind: .suspect, index: suspectIndex))
        }
        if let weaponIndex = self.weaponIndex {
            weaponField.text = getAnnotatedCard(ClueCard(kind: .weapon, index: weaponIndex))
        }
        if let roomIndex = self.roomIndex {
            roomField.text = getAnnotatedCard(ClueCard(kind: .room, index: roomIndex))
        }
        validate()
        if let cardShown = self.cardShown {
            whichCardShownField.text = getAnnotatedShowableCard(cardShown)
        }
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField === whoIsGuessingField {
            pick(textField: whoIsGuessingField,
                 pickerData: _gameState.playerNames,
                 row: playerIndex ?? 0) { (row: Int) in
                    self.playerIndex = row
            }
        } else if textField === suspectField {
            pick(textField: suspectField,
                 pickerData: getAnnotatedCards(ofKind: .suspect),
                 row: suspectIndex ?? 0) { (row: Int) in
                    self.suspectIndex = row
            }
        } else if textField === weaponField {
            pick(textField: weaponField,
                 pickerData: getAnnotatedCards(ofKind: .weapon),
                 row: weaponIndex ?? 0) { (row: Int) in
                    self.weaponIndex = row
            }
        } else if textField === roomField {
            pick(textField: roomField,
                 pickerData: getAnnotatedCards(ofKind: .room),
                 row: roomIndex ?? 0) { (row: Int) in
                    self.roomIndex = row
            }
        } else if textField === whichPlayerShowedField {
            pick(textField: whichPlayerShowedField,
                 pickerData: ["No one"] + _gameState.playerNames,
                 row: playerWhoShowedCard == nil ? 0 : playerWhoShowedCard! + 1) { (row: Int) in
                    if row == 0 {
                        self.playerWhoShowedCard = nil
                    } else {
                        self.playerWhoShowedCard = row - 1
                    }
            }
        } else if textField === whichCardShownField {
            if let maybeSuggestion = suggestion() {
                let suggestionCards = showableCards(suggestion: maybeSuggestion)
                if suggestionCards.count != 0 {
                    pick(textField: whichCardShownField,
                         pickerData: suggestionCards.map { getAnnotatedShowableCard($0) },
                         row: cardShown == nil ? 0 : (gameState.myCards.firstIndex(of: cardShown!) ?? 0)) { (row: Int) in
                            self.cardShown = suggestionCards[row]
                    }
                }
            }
        }
        return false
    }

    private func getAnnotatedCards(ofKind: CardKind) -> [String] {
        let cardNames = gameState.gameEdition.cardNames(forKind: ofKind)
        var result = [String]()
        for cardIndex in 0 ..< cardNames.count {
            result.append(getAnnotatedCard(ClueCard(kind: ofKind, index: cardIndex)))
        }
        return result
    }

    private func getAnnotatedCard(_ card: ClueCard) -> String {
        let cardName = gameState.gameEdition.cardName(card)
        if gameState.isMurderCard(card) {
            return cardName + " (murder card)"
        }
        for playerIndex in 0 ..< gameState.numberOfPlayers {
            if gameState.cardKnowledge(forPlayerIndex: playerIndex, card: card) == .yes {
                return cardName + " (held by " + gameState.playerNames[playerIndex] + ")"
            }
        }
        return cardName
    }

    private func getAnnotatedShowableCard(_ card: ClueCard) -> String {
        let cardName = gameState.gameEdition.cardName(card)
        if let numberOfTimesShown = gameState.numberOfTimesShown(card: card) {
            switch numberOfTimesShown {
            case 0:
                return cardName + " (never shown)"
            case 1:
                return cardName + " (shown once)"
            case 2:
                return cardName + " (shown twice)"
            default:
                return cardName + " (shown " + String(numberOfTimesShown) + " times)"
            }
        } else {
            return cardName
        }
    }

    func pick(textField: UITextField, pickerData: [String], row: Int, completion: @escaping (Int) -> Void) {
        self.pickerPopup = MyPickerPopup(pickerData,
            row: row,
            pickerView: self.pickerView,
            pickerCover: self.pickerCover,
            pickerToolbar: self.pickerToolbar) { (row: Int) in
                completion(row)
                textField.text = pickerData[row]
                self.validate()
        }
    }

    private func validate() {
        let valid: Bool
        var warningText: String? = nil

        let enableWhichCardShown: Bool
        if let maybeSuggestion = self.suggestion() {
            enableWhichCardShown = maybeSuggestion.needsToSpecifyShownCard()
            whichCardShownLabel.isEnabled = enableWhichCardShown
            whichCardShownField.isEnabled = enableWhichCardShown

            let warningText0: String?
            let suggestion: Suggestion
            if !maybeSuggestion.needsToSpecifyShownCard() || cardShown != nil && !showableCards(suggestion: maybeSuggestion).contains(cardShown!) {
                whichCardShownField.text = nil
                cardShown = nil
                warningText0 = nil
                suggestion = self.suggestion()!
            } else {
                if showableCards(suggestion: maybeSuggestion).count == 0 {
                    warningText0 = "Player is not holding any of the suggested cards"
                } else {
                    warningText0 = nil
                }
                suggestion = maybeSuggestion
            }

            // Provide guidance for making a good suggestion intentionally before checking
            // whether it's a valid move (or "Must specify shown card" can hide the guidance).
            // Still, also need to compute whether the move is valid.
            let warningText1 = gameState.isGoodGameMove(suggestion: suggestion)
            let warningText2 = gameState.isValidGameMove(suggestion: suggestion)
            warningText = warningText0 ?? warningText1 ?? warningText2
            if warningText2 != nil {
                valid = false
            } else if (whichPlayerShowedField.text == nil || whichPlayerShowedField.text!.isEmpty) {
                valid = false
            } else {
                let warningText2 = gameState.isInconsistentGameMove(suggestion: suggestion)
                warningText = warningText ?? warningText2
                valid = warningText2 == nil
            }
        } else {
            enableWhichCardShown = false
            whichCardShownField.text = nil
            cardShown = nil

            valid = false
        }

        whichCardShownLabel.isEnabled = enableWhichCardShown
        whichCardShownField.isEnabled = enableWhichCardShown

        addSuggestionButton.isEnabled = valid && (!enableWhichCardShown || cardShown != nil)
        warningLabel.text = warningText
        warningLabel.isHidden = warningText == nil
    }

    private func showableCards(suggestion: Suggestion) -> [ClueCard] {
        var cards = suggestion.guessedCards()

        if suggestion.playerIndex == 0 {
            cards = cards.filter { !gameState.myCards.contains($0) }
        }

        if let playerWhoShowedCard = suggestion.playerWhoShowedCard {
            cards = cards.filter { gameState.cardKnowledge(forPlayerIndex: playerWhoShowedCard, card: $0) != .no }
        }

        return cards
    }

    private func suggestion() -> Suggestion? {
        if let playerIndex = playerIndex,
            let suspectIndex = suspectIndex,
            let weaponIndex = weaponIndex,
            let roomIndex = roomIndex {
            return Suggestion(playerIndex: playerIndex,
                              suspectIndex: suspectIndex,
                              weaponIndex: weaponIndex,
                              roomIndex: roomIndex,
                              playerWhoShowedCard: playerWhoShowedCard,
                              cardShownKind: cardShown?.kind)
        }
        return nil
    }

    @IBAction func addSuggestion(_ sender: Any) {
        if let newSuggestion = suggestion() {
            if gameState.isValidGameMove(suggestion: newSuggestion) == nil {
                gameState.addSuggestion(newSuggestion)
                gameState.save()

                // Avoid the mistake of user forgetting to update any fields for the next suggestion
                playerIndex = nil
                whoIsGuessingField.text = nil
                suspectIndex = nil
                suspectField.text = nil
                weaponIndex = nil
                weaponField.text = nil
                roomIndex = nil
                roomField.text = nil
                playerWhoShowedCard = nil
                whichPlayerShowedField.text = nil
                cardShown = nil
                whichCardShownField.text = nil

                // Switch to log view
                tabBarController!.selectedIndex = 2
            }
        }
    }

}
