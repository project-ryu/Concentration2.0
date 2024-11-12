//
//  ViewController.swift
//  Concentration2.0
//
//  Created by Benjamin Ryu on 10/20/24.
//

import UIKit

class CardView: UIImageView {
    var faceImage: UIImage?
}

class ViewController: UIViewController {
    struct GameState {
        var cardViews: [CardView] = []
        var matchedPairs = 0
    }
    
    var selectedCards: [CardView] = []
    
    var isRevealingCards = false
    
    private var gameState = GameState()
    
    let background = UIImageView(image: UIImage(named: "Card-Mahjong")!)
    //rename to puzzleCard 

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let aspect_ratio = background.bounds.height / background.bounds.width
        
        let width = view.bounds.width * 0.9
        let height = aspect_ratio * width

        background.bounds.size.width = width
        background.bounds.size.height = height
        
        background.center.x = view.bounds.width / 2
        background.center.y = view.bounds.height / 2

       // view.insertSubview(background, at: 0)
        view.addSubview(background)
        // view.sendSubviewToBack(background)
        
        setupGame()
    }
    
    func setupGame() {
        gameState = GameState()
        
        let cardFaces: [UIImage] = [
            UIImage(named: "clubs")!,
            UIImage(named: "clubs")!,
            UIImage(named: "hearts")!,
            UIImage(named: "hearts")!,
            UIImage(named: "spades")!,
            UIImage(named: "spades")!,
            UIImage(named: "diamonds")!,
            UIImage(named: "diamonds")!
        ].shuffled()
        
        for faceImage in cardFaces {
            let image_width = view.bounds.width * 0.15
            let image_height = image_width * 1.43
            let subview = CardView(frame: CGRect(x: 0, y: 0, width: image_width, height: image_height))
            subview.faceImage = faceImage
            subview.center.x = view.bounds.width * 0.5
            subview.center.y = view.bounds.width * -0.15
            // same relative distance for any device
            // change point values to percentages for relative scaling, example: 70/width of iphone17 * width of view.bounds
            subview.image = UIImage(named: "suits")
            subview.isUserInteractionEnabled = true
            
            subview.layer.cornerRadius = 10
            subview.layer.shadowOpacity = 1
            subview.layer.shadowRadius = 3
            subview.layer.shadowColor = UIColor.black.cgColor
            subview.layer.shadowOffset = CGSize(width: 0, height: 1)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedCard(_:)))
            subview.addGestureRecognizer(tapGesture)
            
            
            // eventually change out code to be mathematically centered, or construct the grid from scratch
            view.addSubview(subview)
            gameState.cardViews.append(subview)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(
                withDuration: 0.5,
                animations: {
                    self.layoutCardGrid()
                }
            )
        }
    }
    func shuffleCards () {
        gameState.cardViews = gameState.cardViews.shuffled()
        layoutCardGrid()
    }
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        UIView.animate(
            withDuration: 0.5,
            animations: {
                self.shuffleCards()
            }
        )
    }
    
    func layoutCardGrid () {
        var y = CGFloat(310)
        var x = CGFloat(100)
        
        for index in 1...gameState.cardViews.count {
            let cardView = gameState.cardViews[index - 1]
            cardView.frame.origin.x = x
            cardView.frame.origin.y = y
            if index % 2 == 0 {
                x = 100
                y += 110
            }
            else {
                x += 120
            }
        }
    }
    @objc func tappedCard(_ sender: UITapGestureRecognizer) {
        guard !isRevealingCards else { return }
        guard let tappedCard = sender.view as? CardView else { return }

        UIView.transition(
            with: tappedCard,
            duration: 0.3,
            options: .transitionFlipFromLeft,
            animations: {
                tappedCard.image = tappedCard.faceImage
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

// change code for card views and positioning to be true center, or at least mathematically centered
// add animation of cards being distributed
    // func layoutCards --> go thru cards in order and JUST lays out a grid
    //
// next add animate shuffling cards during setupGame
