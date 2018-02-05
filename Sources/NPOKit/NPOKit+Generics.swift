//
//  NPOKit+Generics.swift
//  NPO
//
//  Created by Jeroen Wesbeek on 08/12/2017.
//  Copyright © 2017 Jeroen Wesbeek. All rights reserved.
//

import Foundation

public extension NPOKit {
    
    // MARK: Fetch model
    
    internal func fetchModel<T: Codable>(ofType type: T.Type, forEndpoint endPoint: String, postData: Data?, completionHandler: @escaping (T?, Error?) -> Void) {
        //swiftlint:disable:next force_unwrapping
        let url = URL(string: endPoint, relativeTo: apiURL)!
        fetchModel(ofType: type, forURL: url, postData: postData, completionHandler: completionHandler)
    }
    
    internal func fetchModel<T: Codable>(ofType type: T.Type, forLegacyEndpoint endPoint: String, postData: Data?, completionHandler: @escaping (T?, Error?) -> Void) {
        //swiftlint:disable:next force_unwrapping
        let url = URL(string: endPoint, relativeTo: legacyAPIURL)!
        fetchModel(ofType: type, forURL: url, postData: postData, completionHandler: completionHandler)
    }
    
    internal func fetchModel<T: Codable>(ofType type: T.Type, forURL url: URL, postData: Data?, completionHandler: @escaping (T?, Error?) -> Void) {
        let task = dataTask(forUrl: url, postData: postData, cachePolicy: .reloadIgnoringLocalCacheData) { (data, response, error) in
            let decoder = JSONDecoder()
            if #available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                decoder.dateDecodingStrategy = .iso8601
            }
            
            guard error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data, let element = try? decoder.decode(type, from: data) else {
                completionHandler(nil, error)
                return
            }
            
            completionHandler(element, nil)
        }
        task.resume()
    }
    
    // MARK: Data Task
    
    internal func dataTask(forEndpoint endPoint: String, postData: Data?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask? {
        //swiftlint:disable:next force_unwrapping
        let url = URL(string: endPoint, relativeTo: apiURL)!
        return dataTask(forUrl: url, postData: postData, cachePolicy: .returnCacheDataElseLoad, completionHandler: completionHandler)
    }
    
    internal func legacyDataTask(forEndpoint endPoint: String, postData: Data?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask? {
        //swiftlint:disable:next force_unwrapping
        let url = URL(string: endPoint, relativeTo: legacyAPIURL)!
        return dataTask(forUrl: url, postData: postData, cachePolicy: .reloadIgnoringLocalCacheData, completionHandler: completionHandler)
    }
    
    internal func dataTask(forUrl url: URL, postData: Data?, cachePolicy: URLRequest.CachePolicy, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        // create request
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: cacheInterval)
        request.addValue(getUserAgent(), forHTTPHeaderField: "User-Agent")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // add token if this is the 2.0 API
        if let apiString = apiURL?.absoluteString, url.absoluteString.starts(with: apiString), let key = apiKey.deobfuscated {
            request.addValue(key, forHTTPHeaderField: "ApiKey")
            request.addValue("tv", forHTTPHeaderField: "X-Npo-Platform")
        }
        
        // add post data if needed
        if let data = postData {
            request.httpMethod = "POST"
            request.httpBody = data
            log?.verbose("POST: \(request)")
        } else {
            log?.verbose("GET : \(request)")
        }
        
        // create task
        return URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            // on the main queue as this generally involves UI
            DispatchQueue.main.sync {
                completionHandler(data, response, error)
            }
        })
    }
    
    // MARK: User Agent
    
    private func getUserAgent() -> String {
        // Pretend we're a Samsung TV
        return "Mozilla/5.0 (SMART-TV; Linux; Tizen 2.3) AppleWebkit/538.1 (KHTML, like Gecko) SamsungBrowser/1.0 TV Safari/538.1"
    }
}
