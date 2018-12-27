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
    var currentPlayer: Player!
    var opponentPlayer: Player!
    var matches: [Match]!

    var delegate: ReportMatchViewControllerDelegate!
    
    //MARK: Private Properties
    private var possibleScores = Array(0...7)
    private var scores = [0, 0, 0, 0, 0, 0, 0]
    private var picker1 = UIPickerView()
    private var picker2 = UIPickerView()
    private var picker3 = UIPickerView()
    private var picker4 = UIPickerView()
    private var picker5 = UIPickerView()
    private var picker6 = UIPickerView()
    
    //MARK: Outlets
    @IBOutlet private weak var match1LoserScoreTextField: UITextField!
    @IBOutlet private weak var match1WinnerScoreTextField: UITextField!
    @IBOutlet private weak var match2LoserScoreTextField: UITextField!
    @IBOutlet private weak var match2WinnerScoreTextField: UITextField!
    @IBOutlet private weak var match3LoserScoreTextField: UITextField!
    @IBOutlet private weak var match3WinnerScoreTextField: UITextField!
    
    @IBOutlet private weak var opponentImage: UIImageView!
    @IBOutlet private weak var currentPlayerImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        
        let pickers = [picker1, picker2, picker3, picker4, picker5, picker6]
        setUpPickers(pickers)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    private func setUpViews() {
//        if let currentPlay = playerOne {
//            playerOneImage.moa.url = playOne.photoUrl
//            playerTwoImage.moa.url = playOne.photoUrl
//        }
//
//        if let playTwo = playerTwo {
//            playerOneNameLabel.text = playTwo.name
//            playerTwoNameLabel.text = playTwo.name
//        }
    }
    
    private func setUpPickers(_ pickers: [UIPickerView]) {
        for (_, picker) in pickers.enumerated() {
            picker.delegate = self
            picker.dataSource = self
        }
        
        match1LoserScoreTextField.inputView = picker1
        match1WinnerScoreTextField.inputView = picker2
        match2LoserScoreTextField.inputView = picker3
        match2WinnerScoreTextField.inputView = picker4
        match3LoserScoreTextField.inputView = picker5
        match3WinnerScoreTextField.inputView = picker6
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
        if pickerView == picker1 {
            scores[0] = possibleScores[row]
            match1LoserScoreTextField.text = String(scores[0])
        } else if pickerView == picker2 {
            scores[1] = possibleScores[row]
            match1WinnerScoreTextField.text = String(scores[1])
        } else if pickerView == picker3 {
            scores[2] = possibleScores[row]
            match2LoserScoreTextField.text = String(scores[2])
        } else if pickerView == picker4 {
            scores[3] = possibleScores[row]
            match2WinnerScoreTextField.text = String(scores[3])
        } else if pickerView == picker5 {
            scores[4] = possibleScores[row]
            match3LoserScoreTextField.text = String(scores[4])
        } else if pickerView == picker6 {
            scores[5] = possibleScores[row]
            match3WinnerScoreTextField.text = String(scores[5])
        }
   }
    
    @IBAction func reportPressed(_ sender: Any) {
        let outcome = checkMatchOutcome(scores)
        let message = generateMessage(outcome, scores)
        
        let reportConfirmAlert = UIAlertController(title: "Confirm", message: message, preferredStyle: UIAlertController.Style.alert)
        
        reportConfirmAlert.addAction(UIAlertAction(title: "Yes", style: .default) { (_) in
            //TODO: Create Match object and encode JSON
//            var newMatch = Match(matchId: 0,
//                 ladderId: 0,
//                 matchDate: Date(),
//                 winner: self.playerOne,
//                 loser: self.playerTwo,
//                 winnerSet1Score: self.scores[1],
//                 loserSet1Score: self.scores[0],
//                 winnerSet2Score: self.scores[3],
//                 loserSet2Score: self.scores[2],
//                 winnerSet3Score: self.scores[4],
//                 loserSet3Score: self.scores[5])
            
//            self.delegate.passNewMatch(match: newMatch)
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
