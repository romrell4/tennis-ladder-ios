//
//  DetailCell.swift
//  TennisLadder
//
//  Created by Z Tai on 12/21/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import UIKit

class MatchTableViewCell: UITableViewCell {
    @IBOutlet private weak var matchLabel: UILabel!
    @IBOutlet private weak var recordLabel: UILabel!
    
    var match: Match! {
        didSet {
            matchLabel.text = "\(match.matchId)"
            
            if let set3WinnerScore = match.winnerSet3Score, let set3LoserScore = match.loserSet3Score {
                recordLabel.text = "\(match.winnerSet1Score)-\(match.loserSet1Score), \(match.winnerSet2Score)-\(match.loserSet2Score), \(set3WinnerScore)-\(set3LoserScore)"
            } else {
                recordLabel.text = "\(match.winnerSet1Score)-\(match.loserSet1Score), \(match.winnerSet2Score)-\(match.loserSet2Score)"
            }
        }
    }
}
