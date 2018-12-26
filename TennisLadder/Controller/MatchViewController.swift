//
//  MatchViewController.swift
//  TennisLadder
//
//  Created by Z Tai on 12/21/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import UIKit

class MatchViewController: UIViewController {
    //MARK: Public Propertise
    var playerOne : Player?
    var playerTwo : Player?
    
    //MARK: Outlets
    @IBOutlet var playerOneImage: UIImageView!
    @IBOutlet var playerTwoImage: UIImageView!
    @IBOutlet var playerOneNameLabel: UILabel!
    @IBOutlet var playerTwoNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        
    }
    
    func setUpViews() {
        //TODO: Add image API Calls
        
        
        if let playOne = playerOne {
            playerOneNameLabel.text = playOne.name
        }
        
        if let playTwo = playerTwo {
            playerTwoNameLabel.text = playTwo.name
        }
    }

    @IBAction func reportPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
