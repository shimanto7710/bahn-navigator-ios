//
//  APIError.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 9/5/26.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case decodingFailed(Error)
}
