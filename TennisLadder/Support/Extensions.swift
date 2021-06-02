
//
//  Extensions.swift
//  TennisLadder
//
//  Created by Z Tai on 12/12/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import UIKit
import Alamofire
import FirebaseUI
import SafariServices

extension DateFormatter {
    static func defaultDateFormat(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "US")
        formatter.dateFormat = format
        return formatter
    }
	
	func string(fromOptional date: Date?) -> String? {
		if let date = date {
			return string(from: date)
		} else {
			return nil
		}
	}
}

extension JSONDecoder {
	convenience init(dateFormat: String?) {
		self.init()
		keyDecodingStrategy = .convertFromSnakeCase
		if let dateFormat = dateFormat {
			dateDecodingStrategy = .formatted(DateFormatter.defaultDateFormat(dateFormat))
		}
	}
}

extension JSONEncoder {
	convenience init(dateFormat: String?) {
		self.init()
		keyEncodingStrategy = .convertToSnakeCase
		if let dateFormat = dateFormat {
			dateEncodingStrategy = .formatted(DateFormatter.defaultDateFormat(dateFormat))
		}
	}
}

extension Result {
	func toResponse() -> Response<Value> {
		switch self {
		case .success(let value):
			return Response.success(value)
		case .failure(let error):
			return Response.failure(error)
		}
	}
}

extension String {
	func format(_ format: String) -> String {
		return String(format: format, self)
	}
    
    func toInt() -> Int? {
        return Int(self)
    }
}

extension UIColor {
	static var meRowColor: UIColor { return UIColor(named: "MeRowColor")! }
	static var primary: UIColor { return UIColor(named: "Primary")! }
	static var tint: UIColor { return UIColor(named: "Tint")! }
	static var matchWinner: UIColor { return UIColor(named: "MatchWinner")! }
	static var matchLoser: UIColor { return UIColor(named: "MatchLoser")! }
}

extension UIRefreshControl {
	convenience init(title: String, target: Any, action: Selector) {
		self.init()
		attributedTitle = NSAttributedString(string: title, attributes: [.foregroundColor: UIColor.tint])
		tintColor = .tint
		addTarget(target, action: action, for: .valueChanged)
	}
}

extension UITableView {
	func dequeueCell(at indexPath: IndexPath) -> UITableViewCell {
		return dequeueReusableCell(withIdentifier: "cell", for: indexPath)
	}
	
	func deselectSelectedRow() {
		if let row = self.indexPathForSelectedRow {
			self.deselectRow(at: row, animated: true)
		}
	}
	
	func hideEmptyCells() {
		tableFooterView = UIView()
	}
	
	func setEmptyMessage(_ message: String) {
		if let dataSource = dataSource, dataSource.numberOfSections?(in: self) == 0 || dataSource.tableView(self, numberOfRowsInSection: 0) == 0 {
			let view = UIView(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height))
			let messageLabel = UILabel()
			messageLabel.translatesAutoresizingMaskIntoConstraints = false
			messageLabel.text = message
			//TODO: Dark mode issue?
			messageLabel.textColor = .black
			messageLabel.numberOfLines = 0
			messageLabel.textAlignment = .center
			messageLabel.font = UIFont.systemFont(ofSize: 17)
			view.addSubview(messageLabel)
			let padding: CGFloat = 8
			NSLayoutConstraint.activate([
				messageLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: padding),
				messageLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: padding),
				messageLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -padding)
			])
			
			self.backgroundView = view
			self.separatorStyle = .none
		} else {
			self.backgroundView = nil
			self.separatorStyle = .singleLine
		}
	}
}

extension UIViewController {
	func displayError(_ error: Error, alertHandler: ((UIAlertAction?) -> Void)? = nil) {
		//If the error is a ServerError, display the readable error. Otherwise, just use the description
		displayAlert(title: "Error", message: (error as? ServerError)?.error ?? error.localizedDescription, alertHandler: alertHandler)
	}
	
	func displayAlert(title: String, message: String, alertHandler: ((UIAlertAction?) -> Void)? = nil) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: alertHandler))
		self.present(alert, animated: true)
	}
	
	func popBack() {
		navigationController?.popViewController(animated: true)
	}
	
	func presentLoginViewController(loggedInListener: ((User) -> Void)? = nil) {
		if let listener = loggedInListener {
			Auth.auth().addStateDidChangeListener { (_, user) in
				if let user = user {
					listener(user)
				}
			}
		}
		
		guard let authUI = FUIAuth.defaultAuthUI() else { return }
        if #available(iOS 13.0, *) {
            authUI.providers = [
                FUIGoogleAuth(),
                FUIOAuth.appleAuthProvider(),
                FUIEmailAuth()
            ]
        } else {
            authUI.providers = [
                FUIGoogleAuth(),
                FUIEmailAuth()
            ]
        }
		present(authUI.authViewController(), animated: true)
	}
	
	func presentSafariViewController(urlString: String, delegate: SFSafariViewControllerDelegate? = nil) {
		if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
			let svc = SFSafariViewController(url: url)
			svc.delegate = delegate
			//TODO: Dark Mode issue?
			svc.preferredBarTintColor = .primary
			svc.preferredControlTintColor = .white
			
			self.present(svc, animated: true)
		} else {
			displayAlert(title: "Unable to Load Web Page", message: "The app was unable to load this webpage. Please ensure that Safari is installed on your device.", alertHandler: { (_) in
				self.popBack()
			})
		}
	}
}
