//
//  ViewController.swift
//  PlayingCArd
//
//  Created by Игорь on 16.01.2021.
//

import UIKit

class ViewController: UIViewController {
    private var deck = PlayingCardDeck()
    
    private var faceUpCardViews: [PlayingCardView] {
        return cardViews.filter {
            $0.isFaceUp && 
                !$0.isHidden && 
                $0.transform != CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0) &&
                $0.alpha == 1
        }
    }
    
    private var faceUpCardViewsMatch: Bool {
        return faceUpCardViews.count == 2 && 
            faceUpCardViews[0].rank == faceUpCardViews[1].rank &&
            faceUpCardViews[0].suit == faceUpCardViews[1].suit
    }
    
    private var lastChosenCardView: PlayingCardView?
    
    // MARK: - Outlets
    @IBOutlet private var cardViews: [PlayingCardView]!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        var cards = [PlayingCard]()
        for _ in 1...((cardViews.count + 1) / 2) {
            if let card = deck.draw() {
                cards += [card, card]
            }
        }
        for cardView in cardViews {
            cardView.isFaceUp = false
            let card = cards.remove(at: cards.count.arc4random)
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue
            cardView.addGestureRecognizer(UITapGestureRecognizer(
                target: self, 
                action: #selector(flipCard)
            ))           
        }
    }
    
    @objc private func flipCard(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            guard let chosenCardView = recognizer.view as? PlayingCardView,
                  faceUpCardViews.count < 2 
            else { return }
            lastChosenCardView = chosenCardView
            UIView.transition(
                with: chosenCardView, 
                duration: 0.6, 
                options: [.transitionFlipFromLeft], 
                animations: { 
                    chosenCardView.isFaceUp = !chosenCardView.isFaceUp
                }, 
                completion: { finished in
                    let cardsToAnimate = self.faceUpCardViews
                    if self.faceUpCardViewsMatch {
                        UIViewPropertyAnimator.runningPropertyAnimator(
                            withDuration: 0.3, 
                            delay: 0, 
                            options: [], 
                            animations: {
                                cardsToAnimate.forEach { cardView in
                                    cardView.transform = CGAffineTransform.identity
                                        .scaledBy(x: 3.0, y: 3.0)
                                }
                            },
                            completion: { position in
                                UIViewPropertyAnimator.runningPropertyAnimator(
                                    withDuration: 0.3, 
                                    delay: 0, 
                                    options: [], 
                                    animations: {
                                        cardsToAnimate.forEach { cardView in
                                            cardView.transform = CGAffineTransform.identity
                                                .scaledBy(x: 0.1, y: 0.1)
                                            cardView.alpha = 0
                                        }
                                    }, 
                                    completion: { position in
                                        cardsToAnimate.forEach { cardView in
                                            cardView.isHidden = true
                                            cardView.alpha = 1
                                            cardView.transform = .identity
                                        }
                                    }
                                )
                            } // completion
                        ) // .runningPropertyAnimator
                    } else if cardsToAnimate.count == 2 {
                        if chosenCardView == self.lastChosenCardView {
                            cardsToAnimate.forEach { cardView in
                                UIView.transition(
                                    with: cardView, 
                                    duration: 0.8, 
                                    options: .transitionFlipFromLeft, 
                                    animations: {
                                        cardView.isFaceUp = false
                                    }
                                ) // .transition()
                            } // forEach {}
                        }
                    }
                } // completion
            ) // .transition()
        default:
            break
        }
    }
}

extension CGFloat {
    var arc4random: CGFloat {
        if self > 0 {
            return CGFloat(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -CGFloat(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}
