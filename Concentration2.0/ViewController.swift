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
        UIImage(named: "clubs")!,
        UIImage(named: "clubs")!,
        UIImage(named: "hearts")!,
        UIImage(named: "hearts")!,
        UIImage(named: "spades")!,
        UIImage(named: "spades")!,
        UIImage(named: "diamonds")!,
        UIImage(named: "diamonds")!
    ]
    
    var selectedCards: [UIImageView] = []
    
    var isRevealingCards = false
    
    private var gameState = GameState()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let background = UIImageView(frame: UIScreen.main.bounds)
        background.image = UIImage(named: "Card-Mahjong")
        background.contentMode = .scaleAspectFill
        view.addSubview(background)
        view.sendSubviewToBack(background)
        
        setupGame()
    }
    
    func setupGame() {
        gameState = GameState()

        cardFaces.shuffle()
        
        var y = CGFloat(310)
        var x = CGFloat(100)
        
        for index in 1...cardFaces.count {
            let subview = UIImageView(frame: CGRect(x: x, y: y, width: 70, height: 100))
            subview.image = UIImage(named: "suits")
            subview.isUserInteractionEnabled = true
            
            subview.layer.cornerRadius = 10
            subview.layer.shadowOpacity = 1
            subview.layer.shadowRadius = 3
            subview.layer.shadowColor = UIColor.black.cgColor
            subview.layer.shadowOffset = CGSize(width: 0, height: 1)

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedCard(_:)))
            subview.addGestureRecognizer(tapGesture)
            
            if index % 2 == 0 {
                x = 100
                y += 110
            }
            else {
                x += 120
            }
            
            view.addSubview(subview)
            gameState.cardViews.append(subview)
        }
    }
    
    @objc func tappedCard(_ sender: UITapGestureRecognizer) {
        guard !isRevealingCards else { return }
        guard let tappedCard = sender.view as? UIImageView else { return }

        if let index = gameState.cardViews.firstIndex(of: tappedCard) {
            UIView.transition(
                with: tappedCard,
                duration: 0.3,
                options: .transitionFlipFromLeft,
                animations: {
                    tappedCard.image = self.cardFaces[index]
                },
                completion: nil
            )
            
            selectedCards.append(tappedCard)
            
            if selectedCards.count == 2 {
                isRevealingCards = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.matchCheck()
                    self.isRevealingCards = false
                }
            }
        }
    }

    func matchCheck() {
        let firstCard = selectedCards[0]
        let secondCard = selectedCards[1]
        
        selectedCards.removeAll()
        
        if firstCard.image != secondCard.image {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UIView.transition(
                    with: firstCard,
                    duration: 0.3,
                    options: .transitionFlipFromRight,
                    animations: {
                        firstCard.image = UIImage(named: "suits")
                    },
                    completion: nil
                )
                
                UIView.transition(
                    with: secondCard,
                    duration: 0.3,
                    options: .transitionFlipFromRight,
                    animations: {
                        secondCard.image = UIImage(named: "suits")
                    },
                    completion: nil
                )
            }
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 0.5, animations: {
                firstCard.frame.origin.y -= self.view.bounds.height
                secondCard.frame.origin.y -= self.view.bounds.height
            }) { _ in
                //underscore is a bool placeholder when no value is defined
                firstCard.removeFromSuperview()
                secondCard.removeFromSuperview()
            }
        }
        
        gameState.matchedPairs += 1
        
        if gameState.matchedPairs == 4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.setupGame()
            }
        }
    }
}


// add animation of cards being distributed
// next add animate shuffling cards during setupGame
