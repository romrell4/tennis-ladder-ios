
//
//  Extensions.swift
//  Tennis
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

