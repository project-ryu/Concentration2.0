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

// struct ActiveStatusEffect {
//    let effect: StatusEffect
//    let startTime: Date
//    let duration: TimeInterval
//    let imageView: UIImageView
//}

// enum StatusEffect {
//     case burning
//     case frozen
//}

class HealthBarView: UIView {
    var progress: Float = 1.0 {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    let fillView = UIView()
    let fillContainerView = UIView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        fillContainerView.frame = bounds
        fillContainerView.layer.cornerRadius = self.layer.cornerRadius
        fillContainerView.clipsToBounds = true
        addSubview(fillContainerView)
        
        fillView.backgroundColor = .red
        fillContainerView.addSubview(fillView)
        
        fillView.frame = CGRect(
            x: 0,
            y: 0,
            width: CGFloat(progress) * self.bounds.width,
            height: self.bounds.height
        )
    }
}

class ViewController: UIViewController {
    struct GameState {
        var cardViews: [CardView] = []
        var matchedPairs = 0
        var enemyHealth = 100
    }
    
    var selectedCards: [CardView] = []
    var isRevealingCards = false
    private var gameState = GameState()
    
    let healthBar = HealthBarView()
    let currentHealthValue = UILabel()
    var healthRegenTimer: Timer?
    
    var burningImageView: UIImageView?
    var frozenImageView: UIImageView?
    
//    var activeStatusEffects: [ActiveStatusEffect] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImageView = UIImageView(frame: view.bounds)
            backgroundImageView.image = UIImage(named: "tableBackground")
            backgroundImageView.contentMode = .scaleAspectFill
            view.addSubview(backgroundImageView)
            view.sendSubviewToBack(backgroundImageView)
        
        setupGame()
    }
    
    func setupGame() {
        
        
        gameState = GameState()
    
        healthBar.layer.cornerRadius = 20
        healthBar.frame = CGRect(x: 40, y:200, width: view.bounds.width - 80, height: 40)
        healthBar.progress = 1.0
        //.progress is a value between 0.0 and 1.0, like 0% - 100%
        healthBar.backgroundColor = .lightGray
        healthBar.layer.shadowOpacity = 1
        healthBar.layer.shadowRadius = 3
        healthBar.layer.shadowColor = UIColor.black.cgColor
        healthBar.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.addSubview(healthBar)
        
        currentHealthValue.frame = healthBar.frame
        currentHealthValue.text = "100/100"
        currentHealthValue.textAlignment = .center
        currentHealthValue.font = UIFont.boldSystemFont(ofSize: 14)
        currentHealthValue.textColor = UIColor.white
        currentHealthValue.backgroundColor = UIColor.clear
        view.addSubview(currentHealthValue)
        
        let cardFaces: [UIImage] = [
            UIImage(named: "air")!,
            UIImage(named: "air")!,
            UIImage(named: "fire")!,
            UIImage(named: "fire")!,
            UIImage(named: "earth")!,
            UIImage(named: "earth")!,
            UIImage(named: "water")!,
            UIImage(named: "water")!
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
            subview.image = UIImage(named: "elements")
            subview.isUserInteractionEnabled = true
            subview.layer.cornerRadius = 10
            subview.clipsToBounds = true
            subview.layer.shadowOpacity = 1
            subview.layer.shadowRadius = 3
            subview.layer.shadowColor = UIColor.black.cgColor
            subview.layer.shadowOffset = CGSize(width: 0, height: 1)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedCard(_:)))
            subview.addGestureRecognizer(tapGesture)
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
        
        healthRegenTimer?.invalidate()
        //? makes this an optional timer, and invalidate() is only called if healthRegenTimer isn't nil
        healthRegenTimer = Timer.scheduledTimer(
            timeInterval: 5.0,
            target: self,
            selector: #selector(regenerateHealth),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc func regenerateHealth() {
        let regenerationValue = 5
        if gameState.enemyHealth < 100 {
            gameState.enemyHealth = min (100, gameState.enemyHealth + regenerationValue)
            updateHealthBar()
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
    
    func layoutCardGrid() {
        let columns = 4
        let rows = (gameState.cardViews.count + columns - 1) / columns
        let horizontalSpacing: CGFloat = 10
        let verticalSpacing: CGFloat = 15
        let cardWidth = (view.bounds.width - CGFloat(columns + 1) * horizontalSpacing) / CGFloat(columns)
        let cardHeight = cardWidth * 1.43
        
        // Centering
        let totalGridWidth = CGFloat(columns) * cardWidth + CGFloat(columns - 1) * horizontalSpacing
        let totalGridHeight = CGFloat(rows) * cardHeight + CGFloat(rows - 1) * verticalSpacing
        
        let startX = (view.bounds.width - totalGridWidth) / 2
        let startY = (view.bounds.height - totalGridHeight) / 2
        
        // Positioning (loop)
        for (index, cardView) in gameState.cardViews.enumerated() {
            //tuple calls both index (position in array) and value (cardViews)
            let rowNumber = index / columns
            let columnNumber = index % columns
            //row & column numbering beings at 0, not 1
            
            let x = startX + CGFloat(columnNumber) * (cardWidth + horizontalSpacing)
            let y = startY + CGFloat(rowNumber) * (cardHeight + verticalSpacing)
            
            UIView.animate(withDuration: 0.5) {
                cardView.frame = CGRect(x: x, y: y, width: cardWidth, height: cardHeight)
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
                        firstCard.image = UIImage(named: "elements")
                    },
                    completion: nil
                )
                
                UIView.transition(
                    with: secondCard,
                    duration: 0.3,
                    options: .transitionFlipFromRight,
                    animations: {
                        secondCard.image = UIImage(named: "elements")
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
        
        if firstCard.faceImage == UIImage(named: "fire") {
            damageOverTime(damagePerTick: 10, ticks: 5, interval: 1.0)
        } else if firstCard.faceImage == UIImage(named: "water") {
            pauseHealthRegen(for: 5.0)
        } else {
            let damage = damageValue(for: firstCard.faceImage)
            instantDamage(damage)
        }
    }
    
    func damageValue(for faceImage: UIImage?) -> Int {
        switch faceImage {
        case UIImage(named: "water"):
            return 10
        case UIImage(named: "air"):
            return 25
        case UIImage(named: "earth"):
            return 50
        default:
            return 0
        }
    }
    
    func instantDamage(_ damage: Int) {
        gameState.enemyHealth -= damage
        updateHealthBar()
        displayDamageLabel("-\(damage)", at: healthBar.frame)
    }

    func damageOverTime(damagePerTick: Int, ticks: Int, interval: TimeInterval) {
        var remainingTicks = ticks
        burningStatus()
        
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if remainingTicks <= 0 || self.gameState.enemyHealth <= 0 {
            //if and only if one or more are true, returns a boolean
                self.removeBurningStatus()
                timer.invalidate()
                return
            }
            self.gameState.enemyHealth -= damagePerTick
            self.updateHealthBar()
            self.displayDamageLabel("\(damagePerTick)", at: self.healthBar.frame)
            remainingTicks -= 1
        }
    }
    
    func pauseHealthRegen(for duration: TimeInterval) {
        healthRegenTimer?.invalidate()
        displayDamageLabel("FROZEN", at: healthBar.frame)
        frozenStatus()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.startHealthRegen()
            self.removeFrozenStatus()
        }
    }
    
//    func update() {
//        // expire effects
//        let now = Date.now
//        for effect in activeStatusEffects {
//            if now.timeIntervalSince(effect.startTime) > effect.duration {
//              effect.imageView.removeFromSuperview()
//                return false
//            }
//             return true
//        }
//        // apply health regen if needed
//        if !activeStatusEffects.map { $0.effect }.contains(.frozen) {
//          healthRegenTimer?.invalidate()
//          startHealthRegen()
//        } else {
//              healthRegenTimer?.invalidate()
//          }
//
//        // apply effects if needed
//        for active_effect in activeStatusEffects {
//            switch active_effect.effect {
//            case .burning:
//                if now.timeIntervalSince
//                    // burn
//                    lastBurnTime = now
//                }
//
//            }
//        }
//    }
    
    func startHealthRegen() {
        healthRegenTimer?.invalidate()
        healthRegenTimer = Timer.scheduledTimer(
            timeInterval: 5.0,
            target: self,
            selector: #selector(regenerateHealth),
            userInfo: nil,
            repeats: true
        )
    }
    
    func burningStatus() {
//        activeStatusEffects.append(
//            ActiveStatusEffect(
//                effect: .burning,
//                startTime: Date.now,
//                duration: 6.5
//            )
//        )
        
        
        let burningImage = UIImageView(image: UIImage(named: "fire"))
        burningImage.frame = CGRect(
            x: healthBar.frame.midX,
            y: healthBar.frame.maxY + 10,
            width: 20,
            height: 20
        )
        view.addSubview(burningImage)
        burningImageView = burningImage
    }
    
    func removeBurningStatus() {
        burningImageView?.removeFromSuperview()
        burningImageView = nil
    }
    
    func frozenStatus() {
        let frozenImage = UIImageView(image: UIImage(named: "water"))
        frozenImage.frame = CGRect(
            x: healthBar.frame.midX + 25,
            y: healthBar.frame.maxY + 10,
            width: 20,
            height: 20
        )
        view.addSubview(frozenImage)
        frozenImageView = frozenImage
    }
    
    func removeFrozenStatus() {
        frozenImageView?.removeFromSuperview()
        frozenImageView = nil
    }
    
    func displayDamageLabel(_ text: String, at frame: CGRect) {
        let damageLabel = UILabel(frame: CGRect(x: healthBar.frame.width, y: healthBar.frame.minY, width: 100, height: 50))
        damageLabel.text = text
        damageLabel.textAlignment = .center
        damageLabel.textColor = .red
        damageLabel.font = UIFont.boldSystemFont(ofSize: 20)
        damageLabel.sizeToFit()
        view.addSubview(damageLabel)

        UIView.animate(withDuration: 1.0, animations: {
            damageLabel.alpha = 0
            damageLabel.frame.origin.y -= 20
        }) { _ in
            damageLabel.removeFromSuperview()
        }
    }
    
    func updateHealthBar() {
        let progress = max(0, Float(gameState.enemyHealth) / 100)
        //convert integer health value into a float (between 0.0 and 1.0), defining the % of the health bar to update to
        UIView.animate(withDuration: 0.3) {
            self.healthBar.progress = progress
        }
        currentHealthValue.text = "\(max(0, gameState.enemyHealth))/100"
        
        if gameState.enemyHealth <= 0 {
            finishGame()
        }
    }
    
    func finishGame() {
        healthRegenTimer?.invalidate()
        displayDamageLabel("WIN!", at: healthBar.frame)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.setupGame()
        }
    }
}


//Questions for Austin:
//health regen ticks cause health bar to momentarily fill up
//animations for status effects

