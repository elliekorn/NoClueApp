//
//  SuggestionLogViewController.swift
//  No Clue
//
//  Created by Leif Kornstaedt on 12/27/19.
//  Copyright © 2019 Leif Kornstaedt. All rights reserved.
//

import UIKit

class SuggestionLogViewController: UIViewController {

    @IBOutlet weak var logTableView: UITableView!
    @IBOutlet weak var historicalDetailsLabel: UILabel!
    @IBOutlet weak var detailLevel: UISegmentedControl!
    @IBOutlet weak var emergencyEditModeButton: UISwitch!

    // Parameter passed in segue
    var gameState: GameState!

    private var logTableData: LogTableData!

    override func viewDidLoad() {
        self.logTableData = LogTableData(gameState: self.gameState)
        self.logTableView.dataSource = self.logTableData
        self.logTableView.delegate = self.logTableData
        self.logTableView.isEditing = false
    }

    override func viewDidAppear(_ animated: Bool) {
        if logTableData.numberOfLogEntries < gameState.numberOfLogEntries {
            while logTableData.numberOfLogEntries < gameState.numberOfLogEntries {
                logTableData.addLog()
            }
            logTableView.reloadData()
        }
    }

    @IBAction func detailLevelChanged(_ sender: Any) {
        let logViewMode: LogViewMode = getDetailLevel()
        self.logTableData!.changeLogViewMode(logViewMode)
        self.logTableView.reloadData()
    }

    @IBAction func emergencyEditModeChanged(_ sender: Any) {
        let logViewMode: LogViewMode =
            self.emergencyEditModeButton.isOn ? .edit : getDetailLevel()

        self.historicalDetailsLabel.isEnabled = logViewMode != .edit
        self.detailLevel.isEnabled = logViewMode != .edit

        self.logTableData.changeLogViewMode(logViewMode)
        self.logTableView.reloadData()

        self.logTableView.isEditing = logViewMode == .edit

        if logViewMode != .edit {
            // Commit any edits
            gameState.save()
        }
    }

    private func getDetailLevel() -> LogViewMode {
        switch self.detailLevel.selectedSegmentIndex {
        case 0:
            return .recent
        case 1:
            return .history
        default:
            return .historyWithDetails
        }
    }

}
