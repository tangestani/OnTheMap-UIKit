//
//  Request.swift
//  OnTheMap-UIKit
//
//  Created by Mohammed Tangestani on 10/16/20.
//

import Foundation

struct LoginRequest: Codable {
    struct Credential: Codable {
        let username: String
        let password: String
    }
    let udacity: Credential
    
    init(username: String, password: String) {
        udacity = .init(username: username, password: password)
    }
}

struct PostLocationRequest: Encodable {
    let uniqueKey: String  // Ignore this. Student IDs returned from the server are randomized.
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
}

