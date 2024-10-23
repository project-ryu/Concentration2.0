//
//  ViewController.swift
//  Concentration2.0
//
//  Created by Benjamin Ryu on 10/20/24.
//

import UIKit

class ViewController: UIViewController {
    
    var cardViews: [UIView] = []
    
    // array to track colors of cards
    var cardColors: [UIColor] = [.red, .blue, .green, .red, .blue, .green]
    
    // array for selected cards and their assigned colors
    var selectedCards: [UIView] = []
    
    var isRevealingCards = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGame()
    }
    
    func setupGame() {
        
        cardColors.shuffle()
        
        var y = CGFloat(150)
        var x = CGFloat(0)
        
        for index in 1...cardColors.count {
            let subview = UIView(frame: CGRect(x: x, y: y, width: 100, height: 100))
            subview.backgroundColor = .gray
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedCard(_:)))
            subview.addGestureRecognizer(tapGesture)
            //
            
            if index % 3 == 0 {
                x = 0
                y += 150
            }
            else {
                x += 150
            }
            
            view.addSubview(subview)
            cardViews.append(subview)
        }
    }
    
    @objc func tappedCard(_ sender: UITapGestureRecognizer) {
        guard !isRevealingCards else { return }
        
        guard let tappedCard = sender.view else {
            return
        }
        
        //Not fully understanding the syntax here (guard)
        
        if let index = cardViews.firstIndex(of: tappedCard) {
            tappedCard.backgroundColor = cardColors[index]
            selectedCards.append(tappedCard)
            // "if let index" checks if tappedCard exists in cardViews then assigns a color from cardColors
            
            if selectedCards.count == 2 {
                //once 2 cards have been tapped, check for match
                matchCheck()
            }
        }
        
        func matchCheck() {
            let firstCard = selectedCards[0]
            let secondCard = selectedCards[1]
            
            selectedCards.removeAll()
            
            if firstCard.backgroundColor == secondCard.backgroundColor {
                firstCard.removeFromSuperview()
                secondCard.removeFromSuperview()
            } else {
                firstCard.backgroundColor = .gray
                secondCard.backgroundColor = .gray
                //set firstCard and secondCard to the first and second tapped cards stored in selectedCards
                //thinking comparing the index entry of the first tapped card to the second tapped card, if = then match
                
            }
        }
    }
}
