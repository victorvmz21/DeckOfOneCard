//
//  DeckError.swift
//  DeckOfOneCard
//
//  Created by Victor Monteiro on 6/16/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import Foundation

enum DeckError: LocalizedError {
    case invalidURL
    case thrownError(Error)
    case noData
    case unableToDecode
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Internal error. Please update Deck of One Card or contact support."
        case .thrownError(let error):
            return error.localizedDescription
        case .noData:
            return "The server responded with no data."
        case .unableToDecode:
            return "The server responded with bad data."
        }
    }
}
