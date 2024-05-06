//
//  TargetType.swift
//  BuyOrNot
//
//  Created by ungQ on 4/14/24.
//

import Foundation
import Alamofire

protocol TargetType: URLRequestConvertible {
	var baseURL: String { get }
	var method: HTTPMethod { get }
	var path: String { get }
	var header: [String: String] { get }
	var parameters: String? { get }
	var queryItems: [URLQueryItem]? { get }
	var body: Data? { get }
}

extension TargetType {

	func asURLRequest() throws -> URLRequest {
		guard let base = URL(string: baseURL) else {
			throw URLError(.badURL)
		}
		let url = base.appendingPathComponent(path)

		var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
		components?.queryItems = queryItems

		guard let finalURL = components?.url else {
			throw URLError(.badURL)
		}

		var urlRequest = URLRequest(url: finalURL)
		urlRequest.httpMethod = method.rawValue
		urlRequest.allHTTPHeaderFields = header
		if let parameters = parameters {
			urlRequest.httpBody = parameters.data(using: .utf8)
		} else {
			urlRequest.httpBody = body
		}
		return urlRequest
	}
}
