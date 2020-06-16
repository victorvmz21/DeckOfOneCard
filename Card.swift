//
//  File.swift
//  DeckOfOneCard
//
//  Created by Victor Monteiro on 6/16/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import Foundation

struct TopLevelObject: Codable {

    let cards: [Card]
}

struct Card: Codable {
    
    let image: URL
    let value: String
    let suit: String
}
