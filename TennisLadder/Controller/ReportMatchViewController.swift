//
//  ReportMatchViewController.swift
//  TennisLadder
//
//  Created by Z Tai on 12/26/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import UIKit
import moa

protocol ReportMatchViewControllerDelegate {
    func passNewMatch(match: Match)
}

class ReportMatchViewController: UIViewController {
    //MARK: Public Properties
    var me: Player!
    var opponent: Player!
    var delegate: ReportMatchViewControllerDelegate!
    
    //MARK: Private Properties
    private var possibleScores = Array(0...7)

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
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setUpViews() {
        meImageView.moa.url = me.photoUrl
        meNameLabel.text = me.name

        opponentImageView.moa.url = opponent.photoUrl
        opponentNameLabel.text = opponent.name
    }

    @IBAction func reportMatchPressed(_ sender: Any) {
        let message = generateMessage()
        
        let reportConfirmAlert = UIAlertController(title: "Confirm", message: message, preferredStyle: UIAlertController.Style.alert)
        
        reportConfirmAlert.addAction(UIAlertAction(title: "Yes", style: .default) { (_) in
//            self.delegate.passNewMatch(match: self.newMatch)
            
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
            Endpoints.reportMatch(newMatch.ladderId, newMatch).responseSingle { (response: Response<Match>) in
                switch response {
                    case .success(let match):
                        //TODO: Unwind Segue
                        print(match)
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
    
    private func generateMessage() -> String {
        let list: [(UITextField, UITextField)] = [
            (set1WinnerScoreTextField, set1LoserScoreTextField),
            (set2WinnerScoreTextField, set2LoserScoreTextField),
            (set3WinnerScoreTextField, set3LoserScoreTextField)
        ]
        
        //Turn textfields into match string
        let matchScore = list.map { ($0.0.textNN, $0.1.textNN) }
            .filter { $0.0 != "0" && $0.1 != "0" }
            .map { "\($0.0)-\($0.1)" }
            .joined(separator: ", ")
        
        return "You have reported that you \(checkMatchOutcome() ? "won" : "lost") this match:\n\n\(matchScore)\n\nIs this correct?"
    }
    
    private func checkMatchOutcome() -> Bool {
        let playedThirdSet = set3WinnerScoreTextField.text != "0" || set3LoserScoreTextField.text != "0"
        let lastSetScores = playedThirdSet ? [set3WinnerScoreTextField.textNN, set3LoserScoreTextField.textNN] : [set2WinnerScoreTextField.textNN, set2LoserScoreTextField.textNN]
        return Int(lastSetScores[0]) ?? 0 > Int(lastSetScores[1]) ?? 0
    }
}

extension UITextField {
    fileprivate var textNN: String {
        return text ?? ""
    }
}
