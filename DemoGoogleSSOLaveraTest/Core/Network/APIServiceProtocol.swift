//
//  APIServiceProtocol.swift
//  DemoGoogleSSOLaveraTest
//
//  Created by DatLeAnh on 8/8/25.
//

import Combine
import Foundation

protocol APIServiceProtocol {
    func request<T: Decodable>(
        _ request: APIRequest,
        completion: @escaping (Result<T, Error>) -> Void
    )
    func requestRaw(_ request: APIRequest, completion: @escaping (Result<Void, Error>) -> Void)

}
