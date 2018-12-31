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
    @IBOutlet private weak var meSet1TextField: UITextField!
    @IBOutlet private weak var opponentSet1TextField: UITextField!
    @IBOutlet private weak var meSet2TextField: UITextField!
    @IBOutlet private weak var opponentSet2TextField: UITextField!
    @IBOutlet private weak var meSet3TextField: UITextField!
    @IBOutlet private weak var opponentSet3TextField: UITextField!
    
    @IBOutlet private weak var meImageView: UIImageView!
    @IBOutlet private weak var opponentImageView: UIImageView!
    
    @IBOutlet private weak var meNameLabel: UILabel!
    @IBOutlet private weak var opponentNameLabel: UILabel!
	
	//MARK: Private Properties
	private lazy var thirdSetFields = [meSet3TextField, opponentSet3TextField]
	
	private lazy var textFieldDict: [UITextField: UITextField?] = [
		meSet1TextField: opponentSet1TextField,
		opponentSet1TextField: meSet2TextField,
		meSet2TextField: opponentSet2TextField,
		opponentSet2TextField: meSet3TextField,
		meSet3TextField: opponentSet3TextField,
		opponentSet3TextField: nil
	]
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //First text field is automatically selected - In the viewDidAppear because the textview isn't drawn by the time it's the first responsder
        meSet1TextField.becomeFirstResponder()
    }
	
	//MARK: Listeners
	
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
	
	@objc private func textFieldDidChange(textField: UITextField) {
		if let temp = textFieldDict[textField], let nextTextField = temp {
			var maxDigits = 1
			if thirdSetFields.contains(textField) {
				maxDigits = 2
			}
			if textField.text?.count == maxDigits {
				nextTextField.becomeFirstResponder()
			}
		} else {
			var maxDigits = 2
			if textField.text?.count == maxDigits {
				textField.resignFirstResponder()
			}
		}
	}
	
	@IBAction func cancelPressed(_ sender: Any) {
		self.dismiss(animated: true)
	}

    @IBAction func reportMatchPressed(_ sender: Any) {
        let match = getMatch()
        let message = "You have reported that you \(match.winner == me ? "won" : "lost") this match:\n\n\(match.scoreDisplay)\n\nIs this correct?"
        
        let reportConfirmAlert = UIAlertController(title: "Confirm", message: message, preferredStyle: UIAlertController.Style.alert)
        
        reportConfirmAlert.addAction(UIAlertAction(title: "Yes", style: .default) { (_) in
            Endpoints.reportMatch(match.ladderId, match).responseSingle { (response: Response<Match>) in
                switch response {
                    case .success:
                        self.dismiss(animated: true)
                    case .failure(let error):
                        self.displayError(error)
                }
            }
        })
        
        reportConfirmAlert.addAction(UIAlertAction(title: "No", style: .cancel))
        
        present(reportConfirmAlert, animated: true)
    }
	
	//MARK: Private Functions
	
	private func setUpViews() {
		meImageView.moa.url = me.photoUrl
		meNameLabel.text = me.name
		
		opponentImageView.moa.url = opponent.photoUrl
		opponentNameLabel.text = opponent.name
		
		[meSet1TextField, opponentSet1TextField, meSet2TextField, opponentSet2TextField, meSet3TextField, opponentSet3TextField].forEach {
			
			$0?.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
		}
	}
    
    private func getMatch() -> Match {
		let playedThirdSet = !(meSet3TextField.text?.isEmpty ?? true) && !(opponentSet3TextField.text?.isEmpty ?? true)
		let lastSetScore = playedThirdSet ? (meSet3TextField.toInt(), opponentSet3TextField.toInt()) : (meSet2TextField.toInt(), opponentSet2TextField.toInt())
		let iWon = lastSetScore.0 > lastSetScore.1
		
		return Match(
			matchId: nil,
			ladderId: self.me.ladderId,
			matchDate: nil,
			winner: iWon ? me : opponent,
			loser: iWon ? opponent : me,
			winnerSet1Score: iWon ? meSet1TextField.toInt() : opponentSet1TextField.toInt(),
			loserSet1Score: iWon ? opponentSet1TextField.toInt() : meSet1TextField.toInt(),
			winnerSet2Score: iWon ? meSet2TextField.toInt() : opponentSet2TextField.toInt(),
			loserSet2Score: iWon ? opponentSet2TextField.toInt() : meSet2TextField.toInt(),
			winnerSet3Score: playedThirdSet ? (iWon ? meSet3TextField.toInt() : opponentSet3TextField.toInt()) : nil,
			loserSet3Score: playedThirdSet ? (iWon ? opponentSet3TextField.toInt() : meSet3TextField.toInt()) : nil
		)
    }
}

extension UITextField {
	fileprivate func toInt() -> Int {
		if let text = self.text {
			return Int(text) ?? 0
		}
		
		return 0
	}
}
