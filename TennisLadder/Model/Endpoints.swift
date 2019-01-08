//
//  Client.swift
//  TennisLadder
//
//  Created by Eric Romrell on 12/19/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import Foundation
import FirebaseAuth
import Alamofire

enum Endpoints: URLRequestConvertible {
	static let BASE_URL = "https://lxlwvoenil.execute-api.us-west-2.amazonaws.com/prod/"
	static var TOKEN: String?
	
	case getLadders()
	case getPlayers(Int)
	case getMatches(Int, String)
	case reportMatch(Int, Match)
	case addUserToLadder(Int, String)
	
	private var method: HTTPMethod {
		switch self {
		case .getLadders, .getPlayers, .getMatches: return .get
		case .reportMatch, .addUserToLadder: return .post
		}
	}
	
	private func getBody() throws -> [String: Any]? {
		switch self {
		case .getLadders, .getPlayers, .getMatches, .addUserToLadder: return nil
		case .reportMatch(_, let match): return try JSONSerialization.jsonObject(with: try JSONEncoder(dateFormat: dateFormat).encode(match)) as? [String: Any]
		}
	}
	
	private var path: [String] {
		switch self {
		case .getLadders: return ["ladders"]
		case .getPlayers(let ladderId), .addUserToLadder(let ladderId, _): return ["ladders", String(ladderId), "players"]
		case .getMatches(let ladderId, let userId): return ["ladders", String(ladderId), "players", userId, "matches"]
		case .reportMatch(let ladderId, _): return ["ladders", String(ladderId), "matches"]
		}
	}
	
	private var queryParams: [(String, String)]? {
		switch self {
		case .addUserToLadder(_, let code): return [("code", code)]
		default: return nil
		}
	}
	
	private var dateFormat: String? {
		switch self {
		case .getLadders: return "yyyy-MM-dd"
		case .getMatches, .reportMatch: return "yyyy-MM-dd'T'HH:mm:ss"
		default: return nil
		}
	}
	
	func asURLRequest() throws -> URLRequest {
		let urlString = Endpoints.BASE_URL + path.joined(separator: "/")
		var urlComps = URLComponents(string: urlString)!
		urlComps.queryItems = queryParams?.map { URLQueryItem(name: $0.0, value: $0.1) }
		
		var urlRequest = try URLRequest(url: urlComps.asURL(), method: method)
		if let token = Endpoints.TOKEN {
			urlRequest.addValue(token, forHTTPHeaderField: "X-Firebase-Token")
		}
		
		return try JSONEncoding.default.encode(urlRequest, with: getBody())
	}
	
	func response<T: Decodable>(_ callback: @escaping (Response<[T]>) -> Void) {
		authenticate {
			Alamofire.request(self).response(jsonDecoder: JSONDecoder(dateFormat: self.dateFormat)) { (response: DataResponse<[T]>) in
				callback(response.result.toResponse())
			}
		}
	}
	
	func response<T: Decodable>(_ callback: @escaping (Response<T>) -> Void) {
		authenticate {
			Alamofire.request(self).response(jsonDecoder: JSONDecoder(dateFormat: self.dateFormat)) { (response: DataResponse<T>) in
				callback(response.result.toResponse())
			}
		}
	}
    
    func response(_ callback: @escaping (Response<Void>) -> Void) {
		authenticate {
			Alamofire.request(self).response { (response: DefaultDataResponse) in
				if 200...299 ~= response.response?.statusCode ?? 500 {
					callback(Response.success(Void()))
				} else {
					callback(Response.failure(response.error ?? NSError()))
				}
			}
		}
    }
	
	private func authenticate(then makeRequest: @escaping (() -> Void)) {
		if let user = Auth.auth().currentUser {
			user.getIDToken(completion: { (token, _) in
				Endpoints.TOKEN = token
				if DEBUG_MODE {
					print("Token: \(token ?? "")")
				}
				makeRequest()
				Endpoints.TOKEN = nil
			})
		} else {
			makeRequest()
		}
	}
}

enum Response<T> {
	case success(T)
	case failure(Error)
}

private extension DataRequest {
	@discardableResult func response<T: Decodable>(jsonDecoder: JSONDecoder, completionHandler: @escaping (DataResponse<T>) -> Void ) -> Self {
		let responseSerializer = DataResponseSerializer<T> { request, response, data, error in
			do {
				let jsonData = try self.getSuccessData(request: request, response: response, data: data, error: error)
			
				guard let result = try? jsonDecoder.decode(T.self, from: jsonData) else {
					guard let serverError = try? jsonDecoder.decode(ServerError.self, from: jsonData) else {
						return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
					}
					return .failure(serverError)
				}

				return .success(result)
			} catch {
				return .failure(error)
			}
		}
		return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
	}
	
	@discardableResult func response<T: Decodable>(jsonDecoder: JSONDecoder, completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self {
		let responseSerializer = DataResponseSerializer<[T]> { request, response, data, error in
			do {
				let jsonData = try self.getSuccessData(request: request, response: response, data: data, error: error)
				guard let result = try? jsonDecoder.decode([T].self, from: jsonData) else {
					guard let serverError = try? jsonDecoder.decode(ServerError.self, from: jsonData) else {
						return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
					}
					return .failure(serverError)
				}
				
				return .success(result)
			} catch {
				return .failure(error)
			}
		}
		return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
	}
	
	private func getSuccessData(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> Data {
		if DEBUG_MODE {
			self.log(request: request, response: response, data: data, error: error)
		}
		
		if let error = error {
			throw error
		}
		
		let result = DataRequest.serializeResponseData(response: response, data: data, error: error)
		guard case let .success(jsonData) = result else {
			throw result.error!
		}
		return jsonData
	}
	
	private func log(request: URLRequest?, response: URLResponse?, data: Data?, error: Error?) {
		if let request = request, let url = request.url?.absoluteString, let method = request.httpMethod {
			print("\nRequest: \(method) - \(url)")
			if let data = request.httpBody, let body = String(data: data, encoding: .utf8) {
				print(body)
			}
		}
		if let response = response as? HTTPURLResponse {
			print("Response: \(response.statusCode)")
			if let data = data, let body = String(data: data, encoding: .utf8) {
				print(body)
			}
		}
	}
}
