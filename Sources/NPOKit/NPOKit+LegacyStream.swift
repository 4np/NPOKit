//
//  NPOKit+LegacyStream.swift
//  NPO
//
//  Created by Jeroen Wesbeek on 07/12/2017.
//  Copyright © 2017 Jeroen Wesbeek. All rights reserved.
//

import Foundation

public extension NPOKit {
    func legacyPlaylist(for item: Item, completionHandler: @escaping (LegacyPlaylist?, Error?) -> Void) {
        legacyStream(for: item) { [weak self] (stream, error) in
            guard let url = stream?.hlsItem()?.url else {
                completionHandler(nil, error ?? NSError(domain: "eu.osx.tvos.NPO.error", code: -2, userInfo: nil))
                return
            }
            
            // fetch playlist
            self?.fetchModel(ofType: LegacyPlaylist.self, forURL: url, postData: nil, completionHandler: completionHandler)
        }
    }
    
    func legacyStream(for item: Item, completionHandler: @escaping (LegacyStream?, Error?) -> Void) {
        getToken { [weak self] (token, error) in
            guard let token = token else {
                completionHandler(nil, error ?? NSError(domain: "eu.osx.tvos.NPO.error", code: -1, userInfo: nil))
                return
            }

            // fetch stream
            self?.fetchModel(ofType: LegacyStream.self, forLegacyEndpoint: "/app.php/\(item.id)?adaptive=yes&token=\(token.value)", postData: nil, completionHandler: completionHandler)
        }
    }
    
    private func getToken(completionHandler: @escaping (Token?, Error?) -> Void) {
        // use cached token?
        if let token = self.legacyToken, !token.hasExpired {
            completionHandler(token, nil)
            return
        }
        
        // fetch new token
        fetchModel(ofType: Token.self, forLegacyEndpoint: "/app.php/auth", postData: nil, completionHandler: completionHandler)
    }
}
