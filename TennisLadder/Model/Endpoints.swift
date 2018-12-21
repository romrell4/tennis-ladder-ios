//
//  Client.swift
//  TennisLadder
//
//  Created by Eric Romrell on 12/19/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import Foundation
import Alamofire

enum Endpoints: URLRequestConvertible {
	static let BASE_URL = "https://lxlwvoenil.execute-api.us-west-2.amazonaws.com/prod"
	
	case getLadders()
	case getPlayers(Int)
	case getMatches(Int, Int)
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
		case .reportMatch(_, let match): return try JSONSerialization.jsonObject(with: try JSONEncoder().encode(match)) as? [String: Any]
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
	
	func asURLRequest() throws -> URLRequest {
		var url = try Endpoints.BASE_URL.asURL()
		url.appendPathComponent(path)
		
		//TODO: Add X-Firebase-Token
		
		let urlRequest = try URLRequest(url: url, method: method)
		return try JSONEncoding.default.encode(urlRequest, with: getBody())
	}
	
	func response<T: Decodable>(_ callback: @escaping (Response<[T]>) -> Void) {
		Alamofire.request(self).responseCollection { (response: DataResponse<[T]>) in
			callback(response.result.toResponse())
		}
	}
}

enum Response<T> {
	case success(T)
	case failure(Error)
}
