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
        let text = String(possibleScores[row])
        
        switch pickerView {
            case picker1:
                set1LoserScoreTextField.text = text
            case picker2:
                set1WinnerScoreTextField.text = text
            case picker3:
                set2LoserScoreTextField.text = text
            case picker4:
                set2WinnerScoreTextField.text = text
            case picker5:
                set3LoserScoreTextField.text = text
            case picker6:
                set3WinnerScoreTextField.text = text
            default:
                fatalError("Invalid picker selected.")
        }
   }

    @IBAction func reportMatchPressed(_ sender: Any) {
        let message = generateMessage()
        
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
    
    private func generateMessage() -> String {
        let result = checkMatchOutcome()
    
        let score = "\(set1WinnerScoreTextField.textNN)-\(set1LoserScoreTextField.textNN), \(set2WinnerScoreTextField.textNN)-\(set2LoserScoreTextField.textNN)\(set3WinnerScoreTextField.text != "0" || set2LoserScoreTextField.text != "0" ? ", \(set3WinnerScoreTextField.textNN)-\(set3LoserScoreTextField.textNN)" : "")"
        
        return "You have reported that you \(result ? "won" : "lost") this match:\n\n\(score)\n\nIs this correct?"
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
