//
//  BracketView.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/29/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

private let NUMBER_FORMATTER = NumberFormatter(style: .ordinal)

class BracketView: UIView, UIScrollViewDelegate {
	private struct UI {
		static let roundWidth: CGFloat = UIScreen.main.bounds.width * 0.8
		static let minimumPanAmount = roundWidth / 4
		static let panDuration = 0.3
	}
	
	//MARK: Public outlets
	@IBOutlet weak var spinner: UIActivityIndicatorView!
	
	//MARK: Public properties
	var bracket: Tournament! {
		didSet {
			loadUI()
		}
	}
	
	//MARK: Private outlets
	@IBOutlet private weak var topView: UIView!
	@IBOutlet private weak var roundLabel: UILabel!
	@IBOutlet private weak var pageControl: UIPageControl!
	@IBOutlet private weak var scoreLabel: UILabel!
	@IBOutlet private weak var stackView: UIStackView!
	@IBOutlet private weak var stackViewWidthConstraint: NSLayoutConstraint!
	
	//MARK: Private properties
	private var tournament: Tournament!
	private var roundViews = [RoundView]()
	private var currentPage = 0 {
		didSet {
			//Calculate the zoomLevel for each round - 2^(index - currentPage), unless it's the first page
			roundViews.enumerated().forEach { (index, roundView) in
				roundView.zoomLevel = Int(pow(2.0, Double(currentPage == 0 ? index : index - currentPage + 1)))
			}
			roundLabel.text = getRoundLabel()
			pageControl.currentPage = currentPage
		}
	}
	
	static func initAsSubview(in superview: UIView, tournament: Tournament) -> BracketView {
		let bracketView = UINib(nibName: "BracketView", bundle: nil).instantiate(withOwner: nil).first as! BracketView
		bracketView.translatesAutoresizingMaskIntoConstraints = false
		superview.addSubview(bracketView)
		NSLayoutConstraint.activate([
			bracketView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
			bracketView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
			bracketView.topAnchor.constraint(equalTo: superview.topAnchor),
			bracketView.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
		])
		bracketView.tournament = tournament
		return bracketView
	}
	
	//MARK: UIScrollViewDelegate
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		//Keep all round views in sync (filtering out itself, since it already scrolled)
		roundViews.filter { $0 != scrollView }.forEach {
			$0.contentOffset = scrollView.contentOffset
		}
	}
	
	//MARK: Listeners
	
	@IBAction func panGestureHandler(_ recognizer: UIPanGestureRecognizer) {
		switch recognizer.state {
		case .began:
			//Save the original position as the tag (so that you can base the translation off of it)
			recognizer.view?.tag = Int(recognizer.view?.frame.origin.x ?? 0)
		case .changed:
			let translation = recognizer.translation(in: stackView)
			recognizer.view?.frame.origin.x = CGFloat(recognizer.view?.tag ?? 0) + translation.x
		case .ended:
			//Check the distance moved to determine if we should switch pages
			let translation = recognizer.translation(in: self.stackView).x
			if translation <= -UI.minimumPanAmount && self.currentPage < self.roundViews.count - 1 {
				//We're moving left (and there is another page to our right)
				self.currentPage += 1
			} else if translation >= UI.minimumPanAmount && self.currentPage > 0 {
				//We're moving right (and there is another page to our left)
				self.currentPage -= 1
			}
			
			//Animate the rest of the paging
			UIView.animate(withDuration: UI.panDuration) {
				recognizer.view?.frame.origin.x = 0 - (UI.roundWidth * CGFloat(self.currentPage))
			}
		default: break
		}
	}
	
	//MARK: Private functions
	
	private func loadUI() {
		//Only load the UI if the user's bracket is loaded already (if the master gets loaded, wait until the user's bracket loads
		if let bracket = bracket {
			spinner.stopAnimating()
			
			topView.isHidden = false
			
			//Create a new round view for each round in the bracket
			for i in 0 ..< bracket.rounds.count {
				let roundView = RoundView.initWith(scrollDelegate: self, round: bracket.rounds[i])
				roundView.translatesAutoresizingMaskIntoConstraints = false
				roundViews.append(roundView)
				stackView.addArrangedSubview(roundView)
				
				//The width constraint in the storyboard is just a placeholder. This will actually set the width of the roundView
				roundView.widthAnchor.constraint(equalToConstant: UI.roundWidth).isActive = true
			}
			
			//Allow the stack view enough space to see everything
			stackViewWidthConstraint.constant = UI.roundWidth * CGFloat(bracket.rounds.count)
			
			//This will make sure all of the spacing is correct
			pageControl.numberOfPages = roundViews.count
			currentPage = 0
		}
	}

	private func getRoundLabel() -> String? {
		let current = currentPage + 1
		let max = roundViews.count
		
		if current == max {
			return "Final"
		} else if current == max - 1 {
			return "Semis"
		} else if current == max - 2 {
			return "Quarters"
		} else if let roundPrefix = NUMBER_FORMATTER.string(from: NSNumber(value: current)) {
			return "\(roundPrefix) Round"
		}
		return nil
	}
}
