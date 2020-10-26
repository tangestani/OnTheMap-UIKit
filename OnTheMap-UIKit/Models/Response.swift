//
//  Response.swift
//  OnTheMap-UIKit
//
//  Created by Mohammed Tangestani on 10/16/20.
//

import Foundation
import MapKit

struct OTMResponse: Codable, LocalizedError {
    let status: Int
    let error: String
    
    var errorDescription: String? {
        return error
    }
}

struct LoginResponse: Codable {
    struct Account: Codable {
        let registered: Bool
        let key: String
    }
    struct Session: Codable {
        let id: String
        let expiration: String
    }
    
    let account: Account
    let session: Session
}

struct StudentLocationsResponse: Codable {
    let results: [StudentLocation]
}

struct PostLocationResponse: Codable {
    let createdAt: String
    let objectId: String
}

struct PutLocationResponse: Codable {
    let updatedAt: String
}

struct UserData: Codable {
    let firstName: String
    let lastName: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
    }
}
