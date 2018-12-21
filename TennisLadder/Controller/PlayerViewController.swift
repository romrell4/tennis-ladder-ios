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
		
		players = [Player(userId: "abcdef", ladderId: 1, name: "Kobe Bryant", photoUrl: nil, score: 50, ranking: 5, wins: 30, losses: 20)]
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath)
        
        if let cell = cell as? PlayerCell {
            let player = players[indexPath.row]
            cell.name.text = player.name
            cell.points.text = String(player.score)
            cell.userImage = UIImageView(image: UIImage(named: "userIcon"))
        }
        
        return cell
    }
}

