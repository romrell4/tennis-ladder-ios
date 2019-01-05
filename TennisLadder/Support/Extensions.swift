
//
//  Extensions.swift
//  TennisLadder
//
//  Created by Z Tai on 12/12/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import UIKit
import Alamofire
import SafariServices

extension DateFormatter {
    static func defaultDateFormat(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "US")
        formatter.dateFormat = format
        return formatter
    }
}

extension DataRequest {
	@discardableResult func response<T: Decodable>(dateFormat: String? = nil, completionHandler: @escaping (DataResponse<T>) -> Void ) -> Self {
		let responseSerializer = DataResponseSerializer<T> { request, response, data, error in
			if DEBUG_MODE {
				self.log(request: request, response: response, data: data, error: error)
			}
			
			if let error = error { return .failure(error) }
			
			let result = DataRequest.serializeResponseData(response: response, data: data, error: error)
			guard case let .success(jsonData) = result else {
				return .failure(result.error!)
			}
			
			guard let responseObject = try? JSONDecoder(dateFormat: dateFormat).decode(T.self, from: jsonData) else {
				return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
			}
			return .success(responseObject)
		}
		return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
	}
	
	@discardableResult func response<T: Decodable>(dateFormat: String? = nil, completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self {
		let responseSerializer = DataResponseSerializer<[T]> { request, response, data, error in
			if DEBUG_MODE {
				self.log(request: request, response: response, data: data, error: error)
			}
			
			if let error = error { return .failure(error) }
			
			let result = DataRequest.serializeResponseData(response: response, data: data, error: error)
			guard case let .success(jsonData) = result else {
				return .failure(result.error!)
			}
			
			guard let responseArray = try? JSONDecoder(dateFormat: dateFormat).decode([T].self, from: jsonData) else {
				return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
			}
			
			return .success(responseArray)
		}
		return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
	}
	
	private func log(request: URLRequest?, response: URLResponse?, data: Data?, error: Error?) {
		if let request = request, let url = request.url?.absoluteString, let data = request.httpBody, let body = String(data: data, encoding: .utf8) { print("\n\nRequest: \(url)\n\(body)") }
		if let response = response, let data = data, let body = String(data: data, encoding: .utf8) { print("\n\nResponse: \(response)\n\(body)") }
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
}

extension UIColor {
    static var meRowColor: UIColor {
        return UIColor(red: 1, green: 249/255, blue: 195/255, alpha: 1)
    }
	
	static var primary: UIColor {
		return UIColor(named: "Primary")!
	}
}

extension UIRefreshControl {
	convenience init(title: String, target: Any, action: Selector) {
		self.init()
		attributedTitle = NSAttributedString(string: title)
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
		print(error)
		displayAlert(title: "Error", message: error.localizedDescription, alertHandler: alertHandler)
	}
	
	func displayAlert(title: String, message: String, alertHandler: ((UIAlertAction?) -> Void)? = nil) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: alertHandler))
		self.present(alert, animated: true)
	}
	
	func popBack() {
		navigationController?.popViewController(animated: true)
	}
	
	func presentSafariViewController(urlString: String, delegate: SFSafariViewControllerDelegate? = nil) {
		if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
			let svc = SFSafariViewController(url: url)
			svc.delegate = delegate
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
