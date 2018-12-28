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
    var me: Player!
    var opponent: Player!
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
    private var newMatch: Match!

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
    
    @IBOutlet private weak var bottomToolBar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newMatch = Match(matchId: nil,
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
        
        setUpViews()
        
        let pickers = [picker1, picker2, picker3, picker4, picker5, picker6]
        setUpPickers(pickers)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setUpViews() {
        bottomToolBar.isHidden = false
        //Hide Report Match if the player is the user
        if opponent.userId == me.userId {
            bottomToolBar.isHidden = true
        }
        
        meImageView.moa.url = me.photoUrl
        meNameLabel.text = me.name

        opponentImageView.moa.url = opponent.photoUrl
        opponentNameLabel.text = opponent.name
    }
    
    private func setUpPickers(_ pickers: [UIPickerView]) {
        for (_, picker) in pickers.enumerated() {
            picker.delegate = self
            picker.dataSource = self
        }
        
        set1LoserScoreTextField.inputView = picker1
        set1WinnerScoreTextField.inputView = picker2
        set2LoserScoreTextField.inputView = picker3
        set2WinnerScoreTextField.inputView = picker4
        set3LoserScoreTextField.inputView = picker5
        set3WinnerScoreTextField.inputView = picker6
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
        switch pickerView {
            case picker1:
                scores[0] = possibleScores[row]
                set1LoserScoreTextField.text = String(scores[0])
            case picker2:
                scores[1] = possibleScores[row]
                set1WinnerScoreTextField.text = String(scores[1])
            case picker3:
                scores[2] = possibleScores[row]
                set2LoserScoreTextField.text = String(scores[2])
            case picker4:
                scores[3] = possibleScores[row]
                set2WinnerScoreTextField.text = String(scores[3])
            case picker5:
                scores[4] = possibleScores[row]
                set3LoserScoreTextField.text = String(scores[4])
            case picker6:
                scores[5] = possibleScores[row]
                set3WinnerScoreTextField.text = String(scores[5])
            default:
                fatalError("Invalid picker selected.")
        }
   }

    @IBAction func reportMatchPressed(_ sender: Any) {
        let outcome = checkMatchOutcome(scores)
        let message = generateMessage(outcome, scores)
        
        let reportConfirmAlert = UIAlertController(title: "Confirm", message: message, preferredStyle: UIAlertController.Style.alert)
        
        reportConfirmAlert.addAction(UIAlertAction(title: "Yes", style: .default) { (_) in
//            self.delegate.passNewMatch(match: self.newMatch)
            self.dismiss(animated: true)
        })
        
        reportConfirmAlert.addAction(UIAlertAction(title: "No", style: .cancel))
        
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
    
    private func generateMessage(_ result: Bool, _ scores: [Int]) -> String {
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
