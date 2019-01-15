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
	private lazy var textFieldDict: [UITextField: (UITextField?, Int)] = [
		meSet1TextField: (opponentSet1TextField, 1),
		opponentSet1TextField: (meSet2TextField, 1),
		meSet2TextField: (opponentSet2TextField, 1),
		opponentSet2TextField: (meSet3TextField, 1),
		meSet3TextField: (opponentSet3TextField, 2),
		opponentSet3TextField: (nil, 2)
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
		if let info = textFieldDict[textField] {
			if textField.text?.count == info.1 {
				if let nextTextField = info.0 {
					nextTextField.becomeFirstResponder()
				} else {
					textField.resignFirstResponder()
				}
			}
		}
	}
	
	@IBAction func cancelPressed(_ sender: Any) {
		self.dismiss(animated: true)
	}

    @IBAction func submitPressed(_ sender: Any) {
		guard let match = getMatch() else {
			self.displayAlert(title: "Invalid Match", message: "Only winners report matches. Please let \(opponent.user.name) know to report the set scores.")
			return
		}
		let message = "You have reported that you won this match:\n\n\(match.scoreDisplay(forPlayer: me))\n\nIs this correct?"
        
        let reportConfirmAlert = UIAlertController(title: "Confirm", message: message, preferredStyle: UIAlertController.Style.alert)
        
        reportConfirmAlert.addAction(UIAlertAction(title: "Yes", style: .default) { (_) in
            Endpoints.reportMatch(match.ladderId, match).response { (response: Response<Match>) in
                switch response {
                    case .success:
						self.displayAlert(title: "Success", message: "Thank you. Your match has been reported.", alertHandler: { (_) in
							self.performSegue(withIdentifier: "unwind", sender: self)
						})
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
		meImageView.moa.url = me.user.photoUrl
		meNameLabel.text = me.user.name
		
		opponentImageView.moa.url = opponent.user.photoUrl
		opponentNameLabel.text = opponent.user.name
		
		[meSet1TextField, opponentSet1TextField, meSet2TextField, opponentSet2TextField, meSet3TextField, opponentSet3TextField].forEach {
			$0?.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
		}
	}
    
    private func getMatch() -> Match? {
		let playedThirdSet = !(meSet3TextField.text?.isEmpty ?? true) && !(opponentSet3TextField.text?.isEmpty ?? true)
		let lastSetScore = playedThirdSet ? (meSet3TextField.toInt(), opponentSet3TextField.toInt()) : (meSet2TextField.toInt(), opponentSet2TextField.toInt())
		if lastSetScore.0 <= lastSetScore.1 {
			return nil
		}
		
		return Match(
			matchId: nil,
			ladderId: self.me.ladderId,
			matchDate: nil,
			winner: me,
			loser: opponent,
			winnerSet1Score: meSet1TextField.toInt(),
			loserSet1Score: opponentSet1TextField.toInt(),
			winnerSet2Score: meSet2TextField.toInt(),
			loserSet2Score: opponentSet2TextField.toInt(),
			winnerSet3Score: playedThirdSet ? meSet3TextField.toInt() : nil,
			loserSet3Score: playedThirdSet ? opponentSet3TextField.toInt() : nil
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
