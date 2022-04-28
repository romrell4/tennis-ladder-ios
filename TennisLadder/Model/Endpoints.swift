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
	
	case getUser(String)
	case updateUser(String, TLUser)
	case getLadders
	case getPlayers(Int)
    case updatePlayer(ladderId: Int, userId: String, player: Player)
	case getMatches(Int, String)
	case reportMatch(Int, Match)
    case updateMatchScores(Int, Int, Match)
    case deleteMatch(ladderId: Int, matchId: Int)
	case addUserToLadder(Int, String)
    case updatePlayerOrder(ladderId: Int, players: [Player], generateBorrowedPoints: Bool)
	
	private var method: HTTPMethod {
		switch self {
		case .getUser, .getLadders, .getPlayers, .getMatches: return .get
        case .updateUser, .updatePlayer, .updateMatchScores, .updatePlayerOrder: return .put
		case .reportMatch, .addUserToLadder: return .post
        case .deleteMatch: return .delete
		}
	}
	
	private func getBody() throws -> Any? {
        func createBodyPayload<T: Encodable>(_ value: T) throws -> Any? {
            let encoder = JSONEncoder(dateFormat: dateFormat)
            return try JSONSerialization.jsonObject(with: try encoder.encode(value))
        }
        
		switch self {
        case .getUser, .getLadders, .getPlayers, .getMatches, .addUserToLadder, .deleteMatch: return nil
		case .updateUser(_, let user): return try createBodyPayload(user)
        case .updatePlayerOrder(_, let players, _): return try createBodyPayload(players)
        case .updatePlayer(_, _, let player): return try createBodyPayload(player)
        case .reportMatch(_, let match), .updateMatchScores(_, _, let match): return try createBodyPayload(match)
		}
	}
	
	private var path: [String] {
		switch self {
		case .getUser(let userId), .updateUser(let userId, _): return ["users", userId]
		case .getLadders: return ["ladders"]
		case .getPlayers(let ladderId), .addUserToLadder(let ladderId, _): return ["ladders", String(ladderId), "players"]
        case .updatePlayer(let ladderId, let userId, _): return ["ladders", String(ladderId), "players", userId]
        case .updatePlayerOrder(let ladderId, _, _): return ["ladders", String(ladderId), "players"]
		case .getMatches(let ladderId, let userId): return ["ladders", String(ladderId), "players", userId, "matches"]
		case .reportMatch(let ladderId, _): return ["ladders", String(ladderId), "matches"]
        case .updateMatchScores(let ladderId, let matchId, _): return ["ladders", String(ladderId), "matches", String(matchId)]
        case .deleteMatch(let ladderId, let matchId): return ["ladders", String(ladderId), "matches", String(matchId)]
		}
	}
	
	private var queryParams: [(String, String)]? {
		switch self {
		case .addUserToLadder(_, let code): return [("code", code)]
        case .updatePlayerOrder(_, _, let generateBorrowedPoints): return [("generate_borrowed_points", String(generateBorrowedPoints))]
		default: return nil
		}
	}
	
	private var dateFormat: String? {
		switch self {
		case .getLadders: return "yyyy-MM-dd"
        case .getMatches, .reportMatch, .updateMatchScores: return "yyyy-MM-dd'T'HH:mm:ssX"
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
        
        if let body = try? getBody() {
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        return urlRequest
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
#if DEBUG
                print("Token: \(token ?? "")")
#endif
				makeRequest()
			})
		} else {
            // Clear the statically cached token
            Endpoints.TOKEN = nil
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
#if DEBUG
        self.log(request: request, response: response, data: data, error: error)
#endif
		
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
