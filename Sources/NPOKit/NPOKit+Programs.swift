//
//  NPOKit+Programs.swift
//  NPO
//
//  Created by Jeroen Wesbeek on 28/06/2017.
//  Copyright © 2017 Jeroen Wesbeek. All rights reserved.
//

import Foundation

internal enum Genre: String {
    case none = ""
    case documentary = "documentaire"
    case movie = "film"
    case youth = "jeugd"
    case series = "serie"
    case sport
    case music = "muziek"
    case amusement
    case informative = "informatief"
    
    static func all() -> [Genre] {
        return [.documentary, .movie, .youth, .series, .sport, .music, .amusement, .informative]
    }
}

public extension NPOKit {

    // MARK: Program paginator
    
    func getProgramPaginator(successHandler: @escaping Paginator<Program>.SuccessHandler,
                             failureHandler: Paginator<Program>.FailureHandler? = nil) -> Paginator<Program> {
        return getProgramPaginator(using: nil, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    func getProgramPaginator(using programFilters: [ProgramFilter]?,
                             successHandler: @escaping Paginator<Program>.SuccessHandler,
                             failureHandler: Paginator<Program>.FailureHandler? = nil) -> Paginator<Program> {
        // define how to fetch paginated data
        let fetchHandler: Paginator<Program>.FetchHandler = { [weak self] (paginator, page, pageSize) in
            let endpoint = self?.getEndpoint(for: "page/catalogue", page: page, using: programFilters) ?? "page/catalogue?page=\(page)"
            
            self?.getPrograms(
                forEndpoint: endpoint,
                page: page,
                pageSize: pageSize,
                success: { (programs, numberOfPages, filters) in paginator.success(results: programs, numberOfPages: numberOfPages, filters: filters) },
                failure: { paginator.failure() })
        }
        
        // initialize the paginator
        return Paginator(ofType: Program.self, pageSize: 20, fetchHandler: fetchHandler, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    private func getEndpoint(for base: String, page: Int, using programFilters: [ProgramFilter]?) -> String {
        var endpoint = "\(base)?page=\(page)"
        
        guard let programFilters = programFilters else { return endpoint }
        
        for programFilter in programFilters {
            guard let value = programFilter.option.value else { continue }
            endpoint += "&\(programFilter.filter.argumentName)=\(value)"
            
            // when the current filter is a date filter and we're trying
            // to filter for a particular day we should also send dateTo
            if programFilter.filter.argumentName == "dateFrom" && !programFilter.option.title.contains("Afgelopen") {
                endpoint += "&dateTo=\(value)"
            }
        }
        
        return endpoint
    }
    
    private func getPrograms(forEndpoint endpoint: String,
                             page: Int,
                             pageSize: Int,
                             success: @escaping (_ programs: [Program], _ numberOfPages: Int, _ filters: [Filter]?) -> Void,
                             failure: @escaping () -> Void) {
        // define data task completion handler
        let completionHandler: (Data?, URLResponse?, Error?) -> Void = { [weak self] (data, response, error) in
            guard error == nil, let httpResponse = response as? HTTPURLResponse, (httpResponse.statusCode == 200), let data = data else {
                self?.log?.error("Request failed... (\(String(describing: error?.localizedDescription))) \(String(describing: response))")
                failure()
                return
            }
            
            let decoder = JSONDecoder()
            if #available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                decoder.dateDecodingStrategy = .iso8601
            }
            
//            guard let pagedItems = try? decoder.decode(PagedItems.self, from: data) else {
//                DDLogError("Could not decode JSON")
//                failure()
//                return
//            }

            let pagedItems: PagedItems
            do {
                pagedItems = try decoder.decode(PagedItems.self, from: data)
            } catch {
                // see https://developer.apple.com/documentation/swift/decodingerror
                self?.log?.error("Could not decode JSON (\(error)))")
                failure()
                return
            }
            
            // get the program data
            guard let itemData = pagedItems.components?.filter({ $0.type == .grid }).first?.data else {
                self?.log?.error("Could not get program data, end of pagination?")
                failure()
                return
            }
            
            // determine the number of pages
            let totalResults = itemData.total
            let numberOfPages = Int(ceil(Double(totalResults) / Double(pageSize)))
            
            // get the filters
            let filters = pagedItems.components?.filter({ $0.type == .filter }).first?.filters
            
            // success handler
            success(itemData.items, numberOfPages, filters)
        }
        
        // create task
        guard let task = dataTask(forEndpoint: endpoint, postData: nil, completionHandler: completionHandler) else {
            log?.error("Could not create data task...")
            failure()
            return
        }

        // execute task
        task.resume()
    }
}
