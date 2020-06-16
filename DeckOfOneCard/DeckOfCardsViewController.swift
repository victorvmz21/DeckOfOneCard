//
//  DeckOfCardsViewController.swift
//  DeckOfOneCard
//
//  Created by Victor Monteiro on 6/16/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import UIKit

class DeckOfCardsViewController: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var cardLabel: UILabel!
    
    //MARK: - Variables
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - IBActions
    @IBAction func drawCardButtonTapped(_ sender: UIButton) {
        
        CardController.fetchCard { result in
            switch result {
            case .success(let card):
                self.fetchImageAndUpdateViews(for: card)
            case .failure(let error):
                DispatchQueue.main.async {
                     self.presentErrorToUser(localizedError: error)
                }
            }
        }
    }
    
    //MARK: Methods
    func fetchImageAndUpdateViews(for card: Card) {
        
        CardController.fetchImage(card: card) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self.cardImageView.image = image
                    self.cardLabel.text = "\(card.value) \(card.suit)"
                case .failure(let error):
                    self.presentErrorToUser(localizedError: error)
                }
            }
        }
    }
}
