//
//  NPOKit+Episodes.swift
//  NPO
//
//  Created by Jeroen Wesbeek on 31/10/2017.
//  Copyright © 2017 Jeroen Wesbeek. All rights reserved.
//

import Foundation

public extension NPOKit {
    
    // MARK: Episodes
    
    func getEpisodePaginator(for item: Item,
                             successHandler: @escaping Paginator<Episode>.SuccessHandler,
                             failureHandler: Paginator<Episode>.FailureHandler? = nil) -> Paginator<Episode> {
        // define how to fetch paginated data
        let fetchHandler: Paginator<Item>.FetchHandler = { [weak self] (paginator, page, pageSize) in
            self?.getEpisodes(
                forEndPoint: "media/series/\(item.id)/episodes?page=\(page)",
                page: page,
                pageSize: pageSize,
                success: { (episodes, numberOfPages) in paginator.success(results: episodes, numberOfPages: numberOfPages, filters: nil) },
                failure: { paginator.failure() })
        }
        
        // initialize the paginator
        return Paginator(ofType: Episode.self, pageSize: 20, fetchHandler: fetchHandler, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    // MARK: Generic fetcher
    
    private func getEpisodes(forEndPoint endPoint: String,
                             page: Int,
                             pageSize: Int,
                             success: @escaping (_ programs: [Episode], _ numberOfPages: Int) -> Void,
                             failure: @escaping () -> Void) {
        // define data task completion handler
        let completionHandler: (Data?, URLResponse?, Error?) -> Void = { [weak self] (data, response, error) in
            guard error == nil, let httpResponse = response as? HTTPURLResponse, (httpResponse.statusCode == 200), let responseData = data else {
                self?.log?.error("Request failed... (\(String(describing: error?.localizedDescription))) \(String(describing: response))")
                failure()
                return
            }
            
            let decoder = JSONDecoder()
            if #available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                decoder.dateDecodingStrategy = .iso8601
            }
            
            guard let componentData = try? decoder.decode(ComponentData.self, from: responseData) else {
                self?.log?.error("Could not decode JSON")
                failure()
                return
            }
            
            // determine the number of pages
            let totalResults = componentData.total
            let numberOfPages = Int(ceil(Double(totalResults) / Double(pageSize)))
            
            // success handler
            success(componentData.items, numberOfPages)
        }
        
        // create task
        guard let task = dataTask(forEndpoint: endPoint, postData: nil, completionHandler: completionHandler) else {
            log?.error("Could not create data task...")
            failure()
            return
        }
        
        // execute task
        task.resume()
    }
}
