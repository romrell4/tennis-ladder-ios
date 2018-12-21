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
		
		players = [Player(
            userId: "abcdef",
            ladderId: 1,
            name: "Kobe Bryant",
            photoUrl: nil,
            score: 50,
            ranking: 5,
            wins: 30,
            losses: 20)]
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "detail", sender: indexPath)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedPath = sender as? IndexPath else {
            return
        }
        if segue.identifier == "detail", let vc = segue.destination as? DetailViewController {
            let selectedRow = selectedPath.row
            vc.image = UIImageView(image: UIImage(named: "userIcon"))
            vc.currentRanking = players[selectedRow].ranking
            vc.wins = players[selectedRow].wins
            vc.losses = players[selectedRow].losses
        }
    }
}




//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
////        guard let selectedPath = self.tableView.indexPathForSelectedRow else { return }
////        let selectedRow = selectedPath.row
////
////        if segue.identifier == "detail", let vc = segue.destination as? DetailViewController {
////            vc.playerImage = UIImageView(image: UIImage(named: "userIcon"))
////            vc.currentRankingLabel.text = String(players[selectedRow].ranking)
////            vc.scoreLabel.text = String("\(players[selectedRow].wins) - \(players[selectedRow].losses)")
////        }
//        let selectedPath = self.tableView.indexPath(for: sender as! UITableViewCell)!
////        guard let selectedRow = sender as? Int else { return }
//
//        if segue.identifier == "detail", let vc = segue.destination as? DetailViewController {
//            vc.playerImage = UIImageView(image: UIImage(named: "userIcon"))
//            vc.currentRankingLabel.text = String(players[selectedRow].ranking)
//            vc.scoreLabel.text = String("\(players[selectedRow].wins) - \(players[selectedRow].losses)")
//        }
//    }
