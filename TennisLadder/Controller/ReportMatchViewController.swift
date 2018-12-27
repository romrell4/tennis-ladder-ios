//
//  ReportMatchViewController.swift
//  TennisLadder
//
//  Created by Z Tai on 12/26/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import UIKit
import moa

class ReportMatchViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    //MARK: Public Properties
    var playerOne : Player!
    var playerTwo : Player!
    
    //MARK: Private Properties
    private var possibleScores = [0, 1, 2, 3, 4, 5, 6, 7]
    private var scores = [0, 0, 0, 0, 0, 0, 0]
    
    //MARK: Outlets
    @IBOutlet var playerOneImage: UIImageView!
    @IBOutlet var playerOneNameLabel: UILabel!
    
    @IBOutlet var playerTwoImage: UIImageView!
    @IBOutlet var playerTwoNameLabel: UILabel!
    
    @IBOutlet var matchOneFirst: UIPickerView!
    @IBOutlet var matchOneSecond: UIPickerView!
    @IBOutlet var matchTwoFirst: UIPickerView!
    @IBOutlet var matchTwoSecond: UIPickerView!
    @IBOutlet var matchThreeFirst: UIPickerView!
    @IBOutlet var matchThreeSecond: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var player = playerOne
        var pickers = [
            matchOneFirst,
            matchOneSecond,
            matchTwoFirst,
            matchTwoSecond,
            matchThreeFirst,
            matchThreeSecond,
            ]
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
    
    func numberOfComponents(in matchOnePV: UIPickerView) -> Int {
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
        }
        else if pickerView == matchOneSecond {
            scores[1] = possibleScores[row]
        }
        else if pickerView == matchTwoFirst {
            scores[2] = possibleScores[row]
        }
        else if pickerView == matchTwoSecond {
            scores[3] = possibleScores[row]
        }
        else if pickerView == matchThreeFirst {
            scores[4] = possibleScores[row]
        }
        else if pickerView == matchThreeSecond {
            scores[5] = possibleScores[row]
        }
   }
    
    @IBAction func reportPressed(_ sender: Any) {
        var outcome = checkMatchOutcome(scores)
        
        //TODO: figure out the victory and losing message
        let message = generateMessage(outcome, scores)
        
        let reportConfirmAlert = UIAlertController(title: "Confirm", message: message, preferredStyle: UIAlertController.Style.alert)
        
        reportConfirmAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action: UIAlertAction!) in
            //TODO: Create Match object and encode JSON
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }))
        
        reportConfirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        
        present(reportConfirmAlert, animated: true, completion: nil)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension UIViewController {
    func checkMatchOutcome(_ scores: [Int]) -> Bool{
        var userWin = 0;
        
        if (scores[0] > scores[1]) {
            userWin += 1;
        }
        if (scores[2] > scores[3]) {
            userWin += 1;
        }
        
        return (userWin > 1) ? true : false
    }
    
    func generateMessage(_ result: Bool, _ scores: [Int]) ->String {
        var message = ""
        var outcome = ""
        var score = ""
        
        if result == true {
            outcome = "won"
        }
        else {
            outcome = "lost"
        }
    
        if scores[5] == 0 && scores[4] == 0 {
            score = String("\(scores[0])-\(scores[1]), \(scores[2])-\(scores[3])")
        }
        else {
            score = String("\(scores[0])-\(scores[1]), \(scores[2])-\(scores[3]), \(scores[4])-\(scores[5])")
        }
        
        message = "You have reported that you " + outcome + " this match: \n\n" + score + "\n\n" + "Is this correct?"
        
        return message
    }
}
