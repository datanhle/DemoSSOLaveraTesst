//
//  Untitled.swift
//  DemoGoogleSSOLaveraTest
//
//  Created by DatLeAnh on 8/8/25.
//

import Foundation
import Combine

final class APIService: APIServiceProtocol {
    func request<T: Decodable>(_ request: APIRequest, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: request.url) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers

        // Encode body based on encoding type
        if let body = request.body {
            switch request.encoding {
            case .json:
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

            case .urlEncoded:
                urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                let bodyString = body
                    .map { "\($0.key)=\("\($0.value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
                    .joined(separator: "&")
                urlRequest.httpBody = bodyString.data(using: .utf8)
            }
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func requestRaw(_ request: APIRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: request.url) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers

        // Encode body if exists
        if let body = request.body {
            switch request.encoding {
            case .json:
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

            case .urlEncoded:
                urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                let bodyString = body
                    .map { "\($0.key)=\("\($0.value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
                    .joined(separator: "&")
                urlRequest.httpBody = bodyString.data(using: .utf8)
            }
        }

        URLSession.shared.dataTask(with: urlRequest) { _, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let httpResponse = response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode {
                completion(.success(()))
            } else {
                completion(.failure(URLError(.badServerResponse)))
            }
        }.resume()
    }
}
