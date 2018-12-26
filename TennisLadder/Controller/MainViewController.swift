//
//  HomeViewController.swift
//  Tennis
//
//  Created by Z Tai on 12/12/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import Foundation
import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //MARK: Private Properties
    private var ladders = [Ladder]()
    
    //MARK: Outlets
    @IBOutlet private weak var tableView: UITableView!
	@IBOutlet private weak var spinner: UIActivityIndicatorView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		//Make the extra empty rows disappear
		tableView.tableFooterView = UIView()
		
		//Make a request to get the ladders and reload the UI when the response comes back
		Endpoints.getLadders().response { (response: Response<[Ladder]>) in
			self.spinner.stopAnimating()
			switch response {
			case .success(let ladders):
				self.ladders = ladders
				self.tableView.reloadData()
			case .failure(let error):
				self.displayError(error)
			}
		}
    }
	
	override func viewWillAppear(_ animated: Bool) {
		tableView.deselectSelectedRow()
	}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "player", let vc = segue.destination as? PlayerViewController, let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
			//Pass the ladder they click on to the next view controller
			vc.ladder = ladders[indexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ladders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueCell(at: indexPath)
        
        if let cell = cell as? LadderTableViewCell {
			//Initialize the cell with the ladder at that index path
            cell.ladder = ladders[indexPath.row]
        }
        
        return cell
    }
}
