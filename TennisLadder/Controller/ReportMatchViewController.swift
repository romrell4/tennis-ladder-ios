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

class ReportMatchViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    //MARK: Public Properties
    var playerOne: Player!
    var matches: [Match]!
    var playerTwo: Player!
    var delegate: ReportMatchViewControllerDelegate!
    
    //MARK: Private Properties
    private var possibleScores = Array(0...7)
    private var scores = [0, 0, 0, 0, 0, 0, 0]
    
    //MARK: Outlets
    @IBOutlet private weak var playerOneImage: UIImageView!
    @IBOutlet private weak var playerOneNameLabel: UILabel!
    
    @IBOutlet private weak var playerTwoImage: UIImageView!
    @IBOutlet private weak var playerTwoNameLabel: UILabel!
    
    @IBOutlet private weak var matchOneFirst: UIPickerView!
    @IBOutlet private weak var matchOneSecond: UIPickerView!
    @IBOutlet private weak var matchTwoFirst: UIPickerView!
    @IBOutlet private weak var matchTwoSecond: UIPickerView!
    @IBOutlet private weak var matchThreeFirst: UIPickerView!
    @IBOutlet private weak var matchThreeSecond: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }

    func setUpViews() {
        if let playOne = playerOne {
            playerOneImage.moa.url = playOne.photoUrl
            playerTwoImage.moa.url = playOne.photoUrl
        }
        
        if let playTwo = playerTwo {
            playerOneNameLabel.text = playTwo.name
            playerTwoNameLabel.text = playTwo.name
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return possibleScores.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(possibleScores[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == matchOneFirst {
            scores[0] = possibleScores[row]
        } else if pickerView == matchOneSecond {
            scores[1] = possibleScores[row]
        } else if pickerView == matchTwoFirst {
            scores[2] = possibleScores[row]
        } else if pickerView == matchTwoSecond {
            scores[3] = possibleScores[row]
        } else if pickerView == matchThreeFirst {
            scores[4] = possibleScores[row]
        } else if pickerView == matchThreeSecond {
            scores[5] = possibleScores[row]
        }
   }
    
    @IBAction func reportPressed(_ sender: Any) {
        let outcome = checkMatchOutcome(scores)
        let message = generateMessage(outcome, scores)
        
        let reportConfirmAlert = UIAlertController(title: "Confirm", message: message, preferredStyle: UIAlertController.Style.alert)
        
        reportConfirmAlert.addAction(UIAlertAction(title: "Yes", style: .default) { (_) in
            //TODO: Create Match object and encode JSON
            var newMatch = Match(matchId: 0,
                 ladderId: 0,
                 matchDate: Date(),
                 winner: self.playerOne,
                 loser: self.playerTwo,
                 winnerSet1Score: self.scores[1],
                 loserSet1Score: self.scores[0],
                 winnerSet2Score: self.scores[3],
                 loserSet2Score: self.scores[2],
                 winnerSet3Score: self.scores[4],
                 loserSet3Score: self.scores[5])
            
            self.delegate.passNewMatch(match: newMatch)
            self.presentingViewController?.dismiss(animated: true)
        })
        
        reportConfirmAlert.addAction(UIAlertAction(title: "No", style: .cancel) { (_) in })
        
        present(reportConfirmAlert, animated: true)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }

    private func checkMatchOutcome(_ scores: [Int]) -> Bool {
        var userWin = 0;
        
        if scores[0] > scores[1] {
            userWin += 1;
        }
        if scores[2] > scores[3] {
            userWin += 1;
        }
        if scores[5] > scores[4] {
            userWin += 1;
        }
        
        return userWin > 1
    }
    
    private func generateMessage(_ result: Bool, _ scores: [Int]) ->String {
        var message = ""
        var score = ""
        let outcome = result ? "won" : "lost" 
    
        if scores[5] == 0 && scores[4] == 0 {
            score = String("\(scores[0])-\(scores[1]), \(scores[2])-\(scores[3])")
        } else {
            score = String("\(scores[0])-\(scores[1]), \(scores[2])-\(scores[3]), \(scores[4])-\(scores[5])")
        }
        
        message = "You have reported that you " + outcome + " this match: \n\n" + score + "\n\n" + "Is this correct?"
        
        return message
    }
}
