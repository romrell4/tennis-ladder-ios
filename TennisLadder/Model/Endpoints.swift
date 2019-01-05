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
	static let BASE_URL = "https://lxlwvoenil.execute-api.us-west-2.amazonaws.com/prod"
	static var TOKEN: String?
	
	case getLadders()
	case getPlayers(Int)
	case getMatches(Int, String)
	case reportMatch(Int, Match)
	
	private var method: HTTPMethod {
		switch self {
		case .getLadders, .getPlayers, .getMatches: return .get
		case .reportMatch: return .post
		}
	}
	
	private func getBody() throws -> [String: Any]? {
		switch self {
		case .getLadders, .getPlayers, .getMatches: return nil
		case .reportMatch(_, let match): return try JSONSerialization.jsonObject(with: try JSONEncoder(dateFormat: dateFormat).encode(match)) as? [String: Any]
		}
	}
	
	private var path: String {
		switch self {
		case .getLadders: return "ladders"
		case .getPlayers(let ladderId): return "ladders/\(ladderId)/players"
		case .getMatches(let ladderId, let userId): return "ladders/\(ladderId)/players/\(userId)/matches"
		case .reportMatch(let ladderId, _): return "ladders/\(ladderId)/matches"
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
		var url = try Endpoints.BASE_URL.asURL()
		url.appendPathComponent(path)
		
		var urlRequest = try URLRequest(url: url, method: method)
		if let token = Endpoints.TOKEN {
			urlRequest.addValue(token, forHTTPHeaderField: "X-Firebase-Token")
		}
		
		return try JSONEncoding.default.encode(urlRequest, with: getBody())
	}
	
	func response<T: Decodable>(_ callback: @escaping (Response<[T]>) -> Void) {
		authenticate {
			Alamofire.request(self).response(dateFormat: self.dateFormat) { (response: DataResponse<[T]>) in
				callback(response.result.toResponse())
			}
		}
	}
	
	func response<T: Decodable>(_ callback: @escaping (Response<T>) -> Void) {
		authenticate {
			Alamofire.request(self).response(dateFormat: self.dateFormat) { (response: DataResponse<T>) in
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
