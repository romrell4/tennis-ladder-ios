//
//  ViewController.swift
//  Tennis
//
//  Created by Z Tai on 12/12/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    var players = [Player]()
    var matches = [Match]()
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        matches = [Match(pointsScored: 15, pointsGiven: 40), Match(pointsScored: 30, pointsGiven: 40), Match(pointsScored: 30, pointsGiven: 40)]
        players = [Player(name: "Kobe Bryant", ranking: 5, points: 50, wins: 30, losses: 20)]
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath)
        
        if let cell = cell as? PlayerCell {
            let player = players[indexPath.row]
            cell.name.text = player.name
            cell.points.text = String(player.points)
            cell.userImage = UIImageView(image: UIImage(named: "userIcon"))
        }
        
        return cell
    }
}

