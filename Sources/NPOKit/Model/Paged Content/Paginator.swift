//
//  Paginator.swift
//  NPO
//
//  Created by Jeroen Wesbeek on 29/10/2017.
//  Copyright © 2017 Jeroen Wesbeek. All rights reserved.
//

import Foundation

public class Paginator<T> where T: Pageable {
    public typealias FetchHandler = (_ paginator: Paginator<T>, _ page: Int, _ pageSize: Int) -> Void
    public typealias SuccessHandler = (Paginator, [T]) -> Void
    public typealias FailureHandler = (Paginator) -> Void
    
    private enum PaginatorRequestStatus {
        case none, inProgress, done
    }
    private var requestStatus: PaginatorRequestStatus = .none
    
    private var fetchHandler: FetchHandler
    private var successHandler: SuccessHandler
    private var failureHandler: FailureHandler?
    
    public private(set) var page: Int = 0
    public private(set) var pageSize: Int = 20
    public private(set) var numberOfPages = 100000
    public private(set) var filters: [Filter]?
    
    init<T>(ofType: T.Type,
            pageSize: Int,
            fetchHandler: @escaping FetchHandler,
            successHandler: @escaping SuccessHandler,
            failureHandler: FailureHandler? = nil) where T: Pageable {
        self.pageSize = pageSize
        self.fetchHandler = fetchHandler
        self.successHandler = successHandler
        self.failureHandler = failureHandler
    }
    
    public func success(results: [T], numberOfPages: Int?, filters: [Filter]?) {
        requestStatus = .done
        self.page += 1
        if let numberOfPages = numberOfPages {
            self.numberOfPages = numberOfPages
        }
        if let filters = filters {
            self.filters = filters
        }
        successHandler(self, results)
    }
    
    public func failure() {
        requestStatus = .done
        failureHandler?(self)
    }
    
    public func next() {
        guard page < numberOfPages && requestStatus != .inProgress else { return }
        requestStatus = .inProgress
        fetchHandler(self, page + 1, pageSize)
    }
    
    public func reset() {
        page = 0
    }
}
