
//
//  Extensions.swift
//  TennisLadder
//
//  Created by Z Tai on 12/12/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import UIKit
import Alamofire

extension DateFormatter {
    static func defaultDateFormat(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "US")
        formatter.dateFormat = format
        return formatter
    }
}

extension DataRequest {
	@discardableResult func responseObject<T: Decodable>(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<T>) -> Void ) -> Self {
		
		let responseSerializer = DataResponseSerializer<T> { request, response, data, error in
			if let error = error { return .failure(error) }
			
			let result = DataRequest.serializeResponseData(response: response, data: data, error: error)
			guard case let .success(jsonData) = result else {
				return .failure(result.error!)
			}
			
			guard let responseObject = try? self.decoder.decode(T.self, from: jsonData) else{
				return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
			}
			return .success(responseObject)
		}
		return response(queue: queue, responseSerializer: responseSerializer, completionHandler: completionHandler)
	}
	
	@discardableResult func responseCollection<T: Decodable>(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self {
		
		let responseSerializer = DataResponseSerializer<[T]>{ request, response, data, error in
			if let error = error { return .failure(error) }
			
			let result = DataRequest.serializeResponseData(response: response, data: data, error: error)
			guard case let .success(jsonData) = result else{
				return .failure(result.error!)
			}
			
			guard let responseArray = try? self.decoder.decode([T].self, from: jsonData) else {
				return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
			}
			
			return .success(responseArray)
		}
		return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
	}
	
	private var decoder: JSONDecoder {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		decoder.dateDecodingStrategy = .formatted(DateFormatter.defaultDateFormat("yyyy-MM-dd"))
		return decoder
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
	func displayError(_ error: Error) {
		let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		self.present(alert, animated: true)
	}
}
