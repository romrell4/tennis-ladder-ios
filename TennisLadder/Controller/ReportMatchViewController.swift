//
//  ReportMatchViewController.swift
//  TennisLadder
//
//  Created by Z Tai on 12/26/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import UIKit
import moa

class ReportMatchViewController: UIViewController {
    //MARK: Public Properties
    var me: Player!
    var opponent: Player!
    
    //MARK: Outlets
    @IBOutlet private weak var set1LoserScoreTextField: UITextField!
    @IBOutlet private weak var set1WinnerScoreTextField: UITextField!
    @IBOutlet private weak var set2LoserScoreTextField: UITextField!
    @IBOutlet private weak var set2WinnerScoreTextField: UITextField!
    @IBOutlet private weak var set3LoserScoreTextField: UITextField!
    @IBOutlet private weak var set3WinnerScoreTextField: UITextField!
    
    @IBOutlet private weak var meImageView: UIImageView!
    @IBOutlet private weak var opponentImageView: UIImageView!
    
    @IBOutlet private weak var meNameLabel: UILabel!
    @IBOutlet private weak var opponentNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //First text field is automatically selected - In the viewDidAppear because the textview isn't drawn by the time it's the first responsder
        set1LoserScoreTextField.becomeFirstResponder()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setUpViews() {
        //TODO: Player objects still aren't being pass through properly. Find out why these are unwrapping nil
        meImageView.moa.url = me.photoUrl
        meNameLabel.text = me.name

        opponentImageView.moa.url = opponent.photoUrl
        opponentNameLabel.text = opponent.name
    }

    @IBAction func reportMatchPressed(_ sender: Any) {
        var match = getMatch()
        let message = generateMessage(match: match)
        
        let reportConfirmAlert = UIAlertController(title: "Confirm", message: message, preferredStyle: UIAlertController.Style.alert)
        
        reportConfirmAlert.addAction(UIAlertAction(title: "Yes", style: .default) { (_) in
            Endpoints.reportMatch(match.ladderId, match).responseSingle { (response: Response<Match>) in
                switch response {
                    case .success(let _):
                        self.dismiss(animated: true)
                    case .failure(let error):
                        self.displayError(error)
                }
            }
            self.dismiss(animated: true)
        })
        
        reportConfirmAlert.addAction(UIAlertAction(title: "No", style: .cancel))
        
        present(reportConfirmAlert, animated: true)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    private func generateMessage(match: Match) -> String {
        let list: [(UITextField, UITextField)] = [
            (set1WinnerScoreTextField, set1LoserScoreTextField),
            (set2WinnerScoreTextField, set2LoserScoreTextField),
            (set3WinnerScoreTextField, set3LoserScoreTextField)
        ]
        
        //Turn textfields into match string
        let playedSets = list.map { ($0.0.text ?? "", $0.1.text ?? "") }
            .filter { $0.0 != "" && $0.1 != "" }
        
        //TODO: Move this logic into the match object
        let lastSet = playedSets.last ?? ("", "")
        
        return "You have reported that you \(Int(lastSet.0) ?? 0 > Int(lastSet.1) ?? 0 ? "won" : "lost") this match:\n\n\(match.scoreDisplay)\n\nIs this correct?"
    }
    
    private func getMatch() -> Match {
        //TODO: Fill in newMatch with proper values
        let newMatch = Match(matchId: nil,
                             ladderId: self.me.ladderId,
                             matchDate: nil,
                             winner: self.me,
                             loser: self.opponent,
                             winnerSet1Score: 0,
                             loserSet1Score: 0,
                             winnerSet2Score: 0,
                             loserSet2Score: 0,
                             winnerSet3Score: nil,
                             loserSet3Score: nil)
        
        return newMatch
    }
}
