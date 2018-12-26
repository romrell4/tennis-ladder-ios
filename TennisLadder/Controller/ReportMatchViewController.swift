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
    var playerOne : Player!
    var playerTwo : Player!
    
    //MARK: Outlets
    @IBOutlet var playerOneImage: UIImageView!
    @IBOutlet var playerOneNameLabel: UILabel!
    
    @IBOutlet var playerTwoImage: UIImageView!
    @IBOutlet var playerTwoNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    func setUpViews() {
        playerOneImage.moa.url = playerOne.photoUrl
        playerTwoImage.moa.url = playerTwo.photoUrl
        
        playerOneNameLabel.text = playerOne.name
        playerTwoNameLabel.text = playerTwo.name
    }
}
