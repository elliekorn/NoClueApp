//
//  KnownInformationCell.swift
//  No Clue
//
//  Created by Leif Kornstaedt on 12/26/19.
//  Copyright © 2019 Leif Kornstaedt. All rights reserved.
//

import UIKit

class KnownInformationTableViewCell: UITableViewCell {

    private let cardNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .left
        return label
    }()

    var cardName: String? {
        didSet {
            cardNameLabel.text = cardName
        }
    }

    private let stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [UIView]())
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 2
        return stackView
    }()

    var numberOfPlayers: Int? {
        didSet {
            if numberOfPlayers == nil {
                numberOfPlayers = 0
            }

            while stackView.arrangedSubviews.count > numberOfPlayers! {
                stackView.removeArrangedSubview(stackView.arrangedSubviews[numberOfPlayers!])
            }
            while stackView.arrangedSubviews.count < numberOfPlayers! {
                let label = UILabel()
                label.textColor = .label
                label.font = UIFont.systemFont(ofSize: 16)
                label.textAlignment = .center
                stackView.insertArrangedSubview(label, at: stackView.arrangedSubviews.count)
            }
        }
    }

    // Use as header row
    func setPlayerNames(_ playerNames: [String]) {
        backgroundColor = .systemBlue
        cardNameLabel.textColor = .white
        if let numberOfPlayers = numberOfPlayers {
            var i = 0
            while i < numberOfPlayers {
                let label = stackView.arrangedSubviews[i] as! UILabel
                label.textColor = .white
                label.backgroundColor = .systemBlue
                label.text = playerNames[i]
                i += 1
            }
        }
    }

    // Use as information row
    func setCardKnowledge(_ cardKnowledge: [CardKnowledge], isMurderCard: Bool) {
        backgroundColor = .none
        cardNameLabel.textColor = .label
        if let numberOfPlayers = numberOfPlayers {
            var i = 0
            while i < numberOfPlayers {
                let label = stackView.arrangedSubviews[i] as! UILabel
                label.textColor = .label
                switch i < cardKnowledge.count ? cardKnowledge[i] : .unknown {
                case .unknown:
                    label.backgroundColor = isMurderCard ? .systemTeal : .gray
                    label.text = "u"
                case .yes:
                    label.backgroundColor = .systemGreen
                    label.text = "y"
                case .no:
                    label.backgroundColor = isMurderCard ? .systemTeal : .systemRed
                    label.text = "n"
                case .maybe:
                    label.backgroundColor = .systemGreen
                    label.text = "m"
                }
                i += 1
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubview(cardNameLabel)
        addSubview(stackView)
        
        cardNameLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 0, width: 128, height: 0, enableInsets: false)
        stackView.anchor(top: topAnchor, left: cardNameLabel.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 1, paddingLeft: 1, paddingBottom: 1, paddingRight: 1, width: 0, height: 0, enableInsets: false)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
