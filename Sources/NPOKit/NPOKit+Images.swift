//
//  NPOKit+Images.swift
//  NPO
//
//  Created by Jeroen Wesbeek on 28/10/2017.
//  Copyright © 2017 Jeroen Wesbeek. All rights reserved.
//

import Foundation

public extension NPOKit {
    
    // MARK: Private methods
    
    private func fetchImage(url: URL, completionHandler: @escaping (UXImage?, URLSessionDataTask?, Error?) -> Void) -> URLSessionDataTask? {
        return fetchImage(url: url, cachePolicy: .returnCacheDataElseLoad, completionHandler: completionHandler)
    }
    
    private func fetchImage(url: URL, cachePolicy: URLRequest.CachePolicy, completionHandler: @escaping (UXImage?, URLSessionDataTask?, Error?) -> Void) -> URLSessionDataTask? {
        guard let cacheInterval = TimeInterval(exactly: 600) else {
            return nil
        }
        
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: cacheInterval)
        let session = URLSession.shared
        var task: URLSessionDataTask!
        task = session.dataTask(with: request) { (data, _, error) in
            DispatchQueue.main.sync {
                var image: UXImage?
                
                if let data = data, let uxImage = UXImage(data: data) {
                    image = uxImage
                }
                
                completionHandler(image, task, error)
            }
        }
        
        // execute task
        task.resume()
        
        return task
    }
    
    // MARK: Public API
    
    func fetchCollectionImage(for item: Item, completionHandler completed: @escaping (UXImage?, URLSessionDataTask?, Error?) -> Void) -> URLSessionDataTask? {
        guard let url = item.collectionImageURL else { return nil }
        return fetchImage(url: url, completionHandler: completed)
    }
    
    func fetchHeaderImage(for item: Item, completionHandler: @escaping (UXImage?, URLSessionDataTask?, Error?) -> Void) -> URLSessionDataTask? {
        guard let url = item.headerImageURL else { return nil }
        return fetchImage(url: url, completionHandler: completionHandler)
    }
}
