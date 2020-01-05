//
//  LogTableData.swift
//  No Clue
//
//  Created by Leif Kornstaedt on 12/27/19.
//  Copyright © 2019 Leif Kornstaedt. All rights reserved.
//

import UIKit

class LogCell {

    let logIndex: Int
    var cell: UITableViewCell?

    init(logIndex: Int) {
        self.logIndex = logIndex
    }

    func tableViewCell(_ gameState: GameState) -> UITableViewCell {
        if self.cell == nil {
            self.cell = UITableViewCell(style: .default, reuseIdentifier: "Log")
        }
        updateCell(gameState)
        return self.cell!
    }

    private func updateCell(_ gameState: GameState) {
        let textLabel = self.cell!.textLabel!
        let logEntry = gameState.log(forIndex: logIndex)
        self.cell!.backgroundColor = logEntry.backgroundColor()
        if let suggestion = logEntry as? Suggestion {
            self.cell!.editingAccessoryType = suggestion.disabled ? .none : .checkmark
        }
        if logEntry is Suggestion {
            var moveNumber = 1
            var i = 0
            while i < logIndex {
                if gameState.log(forIndex: i) is Suggestion {
                    moveNumber += 1
                }
                i += 1
            }
            textLabel.text = String(moveNumber) + ". " + logEntry.toString(gameState: gameState)
        } else {
            textLabel.text = logEntry.toString(gameState: gameState)
        }
        textLabel.numberOfLines = 0
    }

}

enum LogViewMode {
    case recent
    case history
    case historyWithDetails
    case edit
}

@objc class LogTableData: NSObject, UITableViewDelegate, UITableViewDataSource {

    private var gameState: GameState
    private var logViewMode: LogViewMode
    private var allCells: [LogCell]
    private var historyCells: [LogCell]
    private var recentCells: [LogCell]
    private var editModeCells: [LogCell]

    init(gameState: GameState) {
        self.gameState = gameState
        self.logViewMode = .recent
        self.allCells = []
        self.historyCells = []
        self.recentCells = []
        self.editModeCells = []
        super.init()
        var i = 0
        while i < gameState.numberOfLogEntries {
            addLog()
            i += 1
        }
    }

    func changeLogViewMode(_ logViewMode: LogViewMode) {
        self.logViewMode = logViewMode
    }

    func addLog() {
        let logCell = LogCell(logIndex: allCells.count)
        if let suggestion = gameState.log(forIndex: allCells.count) as? Suggestion {
            if !suggestion.disabled {
                historyCells = allCells.filter { !(gameState.log(forIndex: $0.logIndex) is Constraint) }
                recentCells = []
            }
            editModeCells.append(logCell)
        }
        allCells.append(logCell)
        historyCells.append(logCell)
        recentCells.append(logCell)
    }

    var numberOfLogEntries: Int {
        get { return allCells.count }
    }

    private func filteredCells() -> [LogCell] {
        switch self.logViewMode {
        case .recent:
            return self.recentCells
        case .history:
            return self.historyCells
        case .historyWithDetails:
            return self.allCells
        case .edit:
            return self.editModeCells
        }
    }

    //
    // UITableView data binding
    //

    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        while self.allCells.count < gameState.numberOfLogEntries {
            addLog()
        }
        return filteredCells().count
    }

    @objc func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return filteredCells()[indexPath.row].tableViewCell(self.gameState)
    }

    @objc func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let logIndex = self.editModeCells[indexPath.row].logIndex
        self.allCells = []
        self.historyCells = []
        self.recentCells = []
        self.editModeCells = []
        gameState.toggleSuggestion(logIndex: logIndex)
        tableView.reloadData()
        return nil
    }

    @objc func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    @objc func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let logIndex = self.editModeCells[indexPath.row].logIndex
            self.allCells = []
            self.historyCells = []
            self.recentCells = []
            self.editModeCells = []
            gameState.deleteSuggestion(logIndex: logIndex)
            tableView.reloadData()
        }
    }

    @objc func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let fromLogIndex = self.editModeCells[sourceIndexPath.row].logIndex
        let toLogIndex = self.editModeCells[destinationIndexPath.row].logIndex
        if fromLogIndex != toLogIndex {
            self.allCells = []
            self.historyCells = []
            self.recentCells = []
            self.editModeCells = []
            gameState.moveSuggestion(fromLogIndex: fromLogIndex, toLogIndex: toLogIndex)
            tableView.reloadData()
        }
    }

}
