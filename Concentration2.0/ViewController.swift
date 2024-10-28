//
//  ViewController.swift
//  Concentration2.0
//
//  Created by Benjamin Ryu on 10/20/24.
//

import UIKit

let x = ViewController.GameState()

class ViewController: UIViewController {
    struct GameState {
        var cardViews: [UIImageView] = []
        var matchedPairs = 0
    }

    
    var cardFaces: [UIImage] = [
        UIImage(named: "cat-1")!,
        UIImage(named: "cat-1")!,
        UIImage(named: "tesla-1")!,
        UIImage(named: "tesla-1")!,
        UIImage(named: "fool-1")!,
        UIImage(named: "fool-1")!
    ]
    // changed from array of color pairs to image assets
    
    var selectedCards: [UIImageView] = []
    
    // added counter for matched pairs for game reset
    
    var isRevealingCards = false
    
    private var gameState = GameState()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGame()
        
        view.backgroundColor = UIColor(red: 0, green: 0.5, blue: 0, alpha: 1)
    }
    
    func setupGame() {
        gameState = GameState()

        cardFaces.shuffle()
        
        var y = CGFloat(300)
        var x = CGFloat(20)
        
        for index in 1...cardFaces.count {
            let subview = UIImageView(frame: CGRect(x: x, y: y, width: 90, height: 120))
            subview.backgroundColor = .white
            subview.isUserInteractionEnabled = true
            
            subview.layer.cornerRadius = 10
            subview.layer.shadowOpacity = 1
            subview.layer.shadowRadius = 3
            subview.layer.shadowColor = UIColor.black.cgColor
            subview.layer.shadowOffset = CGSize(width: 0, height: 1)
            
            // added to enable tapping on images
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedCard(_:)))
            subview.addGestureRecognizer(tapGesture)
            
            if index % 3 == 0 {
                x = 20
                y += 150
            }
            else {
                x += 130
            }
            
            view.addSubview(subview)
            gameState.cardViews.append(subview)
        }
    }
    
    @objc func tappedCard(_ sender: UITapGestureRecognizer) {
        guard !isRevealingCards else { return }
        
        guard let tappedCard = sender.view as? UIImageView else {
            // as? will return nil if sender.view isn't a UIImageView
            return
        }
        
        if let index = gameState.cardViews.firstIndex(of: tappedCard) {
            tappedCard.image = cardFaces[index]
            // changed .backgroundColor to .image
            selectedCards.append(tappedCard)
            // "if let index" checks if tappedCard exists in cardViews then assigns a color from cardFaces
            
            if selectedCards.count == 2 {
                //once 2 cards have been tapped, check for match
                matchCheck()
            }
        }
    }
    func matchCheck() {
        let firstCard = selectedCards[0]
        let secondCard = selectedCards[1]
        
        selectedCards.removeAll()
        
        if firstCard.image != secondCard.image {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                firstCard.image = nil
                secondCard.image = nil
                firstCard.backgroundColor = .white
                secondCard.backgroundColor = .white
            }
            return
        }
        
        // changed .backgroundColor to .image
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // gray background still remaining
            firstCard.removeFromSuperview()
            secondCard.removeFromSuperview()
        }
        
        gameState.matchedPairs += 1
        
        if gameState.matchedPairs == 3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.setupGame()
                // added max counter to automatically reset game with a slightly longer delay
            }
        }
    }
}

// had bug with non-matched pairs not "flipping back", realized had functions within other functions and moving around resolved it but not sure exactly which part

