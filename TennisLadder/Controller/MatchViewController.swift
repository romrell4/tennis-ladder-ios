//
//  MatchViewController.swift
//  TennisLadder
//
//  Created by Z Tai on 12/21/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import UIKit

class MatchViewController: UIViewController {
    
    var player1 : Player?
    var player2 : Player?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func reportPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
