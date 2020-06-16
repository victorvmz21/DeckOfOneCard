//
//  DeckController.swift
//  DeckOfOneCard
//
//  Created by Victor Monteiro on 6/16/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import UIKit

class CardController {
    
    static func fetchDeck(completion: @escaping (Result<Card, DeckError>) -> Void) {
        
        //Setting Up URL
        guard let baseURL = URL(string: "https://deckofcardsapi.com/api/deck/new") else { return completion(.failure(.invalidURL))}
        let url = baseURL.appendingPathComponent("draw")
        var component = URLComponents(url: url, resolvingAgainstBaseURL: true)
        component?.queryItems = [URLQueryItem(name: "count", value: "1")]
        guard let finalURL = component?.url else { return completion(.failure(.invalidURL))}
        
        print(finalURL)
        
        URLSession.shared.dataTask(with: finalURL) { (data, _, error) in
            
            if let error = error {
                return completion(.failure(.thrownError(error)))
            }
            
            guard let data = data else { return completion(.failure(.noData))}
            
            do {
                let decoder = JSONDecoder()
                let cards = try  decoder.decode(Card.self, from: data)
                return completion(.success(cards))
            } catch let error {
                return completion(.failure(.thrownError(error)))
            }
        }.resume()
        
    }
    
    static func fetchImage(card: Card, completion: @escaping (Result<UIImage, DeckError>) -> Void ) {
        
        let finalURL = card.image
        URLSession.shared.dataTask(with: finalURL) { (data, _, error) in
            if let error = error {
               
                return completion(.failure(.thrownError(error)))
            }
            
            guard let data = data else { return completion(.failure(.noData))}
            guard let image = UIImage(data: data) else {return completion(.failure(.unableToDecode))}
            return completion(.success(image))
        }
        
    }
}
