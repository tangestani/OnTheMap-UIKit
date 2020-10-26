//
//  OTMClient.swift
//  OnTheMap-UIKit
//
//  Created by Mohammed Tangestani on 10/16/20.
//

import Foundation

struct OTMClient {
    
    struct User {
        static var uniqueKey: String = ""
        static var firstName: String = "Elron"
        static var lastName: String = "Munsk"
    }

    enum Endpoint {
        static let baseURL = "https://onthemap-api.udacity.com/v1"
        
        case session
        case getStudentLocations
        case postStudentLocation
        case putStudentLocation(String)
        case getUserData
        
        var stringValue: String {
            switch self {
            case .session: return Endpoint.baseURL + "/session"
            case .getStudentLocations: return Endpoint.baseURL + "/StudentLocation?order=-updatedAt&limit=100"
            case .postStudentLocation: return Endpoint.baseURL + "/StudentLocation"
            case .putStudentLocation(let objectId): return Endpoint.baseURL + "/StudentLocation/" + objectId
            case .getUserData: return Endpoint.baseURL + "/users/" + User.uniqueKey
            }
        }
        
        var url: URL {
            URL(string: stringValue)!
        }
    }
    
    static func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (Result<ResponseType, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard var data = data, data.count > 5 else {
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                } else if let response = response as? HTTPURLResponse {
                    switch response.statusCode {
                    case 200..<300: break
                    default:
                        let message = HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
                        let error = NSError(domain: "HTTP", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                }
                return
            }
            // Ignore first 5 bytes if endpoint is for a Udacity service
            if url.pathComponents[2] == "session" || url.pathComponents[2] == "users" {
                data = data.subdata(in: 5..<data.count)
            }
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(responseObject))
                }
            } catch {
                do {
                    let responseObject = try decoder.decode(OTMResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(.failure(responseObject))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
        task.resume()
    }
    
    static func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, body: RequestType, responseType: ResponseType.Type, completion: @escaping (Result<ResponseType, Error>) -> Void) {
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard var data = data, data.count > 5 else {
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                } else if let response = response as? HTTPURLResponse {
                    switch response.statusCode {
                    case 200..<300: break
                    default:
                        let message = HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
                        let error = NSError(domain: "HTTP", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                }
                return
            }
            // Ignore first 5 bytes if endpoint is for a Udacity service
            if url.pathComponents[2] == "session" || url.pathComponents[2] == "users" {
                data = data.subdata(in: 5..<data.count)
            }
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(responseObject))
                }
            } catch {
                do {
                    let responseObject = try decoder.decode(OTMResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(.failure(responseObject))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
        task.resume()
    }
    
    static func login(username: String, password: String, completion: @escaping (Error?) -> Void) {
        let request = LoginRequest(username: username, password: password)
        taskForPOSTRequest(url: Endpoint.session.url, body: request, responseType: LoginResponse.self) { result in
            switch result {
            case .success(let response):
                User.uniqueKey = response.account.key
                taskForGETRequest(url: Endpoint.getUserData.url, responseType: UserData.self) { result in
                    switch result {
                    case .success(let userData):
                        User.firstName = userData.firstName
                        User.lastName = userData.lastName
                        completion(nil)
                    case .failure(let error):
                        completion(error)
                    }
                }
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    static func logout(completion: @escaping (Error?) -> Void) {
        var request = URLRequest(url: Endpoint.session.url)
        request.httpMethod = "DELETE"
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                DispatchQueue.main.async {
                    completion(error)
                }
            }
            let range = 5..<data!.count
            let newData = data?.subdata(in: range) /* subset response data! */
            print(String(data: newData!, encoding: .utf8)!)
            DispatchQueue.main.async {
                completion(nil)                
            }
        }
        task.resume()
    }
    
    static func getStudentLocations(completion: @escaping (Result<[StudentLocation], Error>) -> Void) {
        taskForGETRequest(url: Endpoint.getStudentLocations.url, responseType: StudentLocationsResponse.self) { result in
            completion(result.map { $0.results })
        }
    }
    
    static func postStudentLocation(mapString: String, mediaURL: String, latitude: Double, longitude: Double, completion: @escaping (Result<PostLocationResponse, Error>) -> Void) {
        let request = PostLocationRequest(uniqueKey: User.uniqueKey, firstName: User.firstName, lastName: User.lastName, mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude)
        taskForPOSTRequest(url: Endpoint.postStudentLocation.url, body: request, responseType: PostLocationResponse.self) { result in
            completion(result)
        }
    }
}

