//
//  CardView.swift
//  Tinder
//
//  Created by Kaan Yeyrek on 11/19/22.
//

import UIKit
import SDWebImage

protocol CardViewDelegate {
    func didTapMoreInfo(cardViewModel: CardViewModel)
    func didRemoveCard(cardView: CardView)
}
class CardView: UIView {
    var cardViewModel: CardViewModel! {
        didSet {
            swipingPhotosController.cardViewModel = self.cardViewModel
            informationLabel.attributedText = cardViewModel.attributedString
            informationLabel.textAlignment = cardViewModel.textAlignment
            
            (0..<cardViewModel.imageURL.count).forEach { _ in
                let barView = UIView()
                barView.backgroundColor = barDeselectedColor
                barStackView.addArrangedSubview(barView)
            }
            barStackView.arrangedSubviews.first?.backgroundColor = .white
            setupImageIndexObserver()
        }
    }
    var delegate: CardViewDelegate?
    var nextCardView: CardView?
    fileprivate let swipingPhotosController = SwipingPhotosController(transitionStyle: .scroll, navigationOrientation: .vertical)
    fileprivate let informationLabel = UILabel()
    fileprivate let moreInfoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "info_icon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(didTapMoreInfoButton), for: .touchUpInside)
        return button
    }()
    fileprivate let gradientLayer = CAGradientLayer()
    // Config ShouldDismissCard
    fileprivate let threshold: CGFloat = 80
    fileprivate let barStackView = UIStackView()
    fileprivate let barDeselectedColor = UIColor(white: 0, alpha: 0.1)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        // gesture
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didTapPhoto)))
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.frame
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    fileprivate func setupImageIndexObserver() {
        cardViewModel.imageIndexObserver = { [weak self] (idx, imageUrl) in
            self?.barStackView.arrangedSubviews.forEach({ (v) in
                v.backgroundColor = self?.barDeselectedColor
            })
            self?.barStackView.arrangedSubviews[idx].backgroundColor = .white
        }
    }
    fileprivate func setupLayout() {
        layer.cornerRadius = 10
        clipsToBounds = true
        
        let swipingPhotosView = swipingPhotosController.view!
        addSubview(swipingPhotosView)
        swipingPhotosView.fillSuperview()
        
        //setupBarsStackView()
        setupGradientLayer()
        //information label
        addSubview(informationLabel)
        informationLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor,
                                trailing: trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16))
        informationLabel.textColor = .white
        informationLabel.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        informationLabel.numberOfLines = 0
        
        addSubview(moreInfoButton)
        moreInfoButton.anchor(top: nil, leading: nil, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 20, right: 20), size: .init(width: 44, height: 44))
    }
    fileprivate func setupGradientLayer() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.5, 1.8]
        layer.addSublayer(gradientLayer)
    }
    fileprivate func setupBarsStackView() {
        addSubview(barStackView)
        barStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
        barStackView.spacing = 4
        barStackView.distribution = .fillEqually
    }
    @objc fileprivate func didTapPhoto(with gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            superview?.subviews.forEach({ subview in
                subview.layer.removeAllAnimations()
            })
        case .changed:
            handleChanged(gesture)
        case .ended:
            handleEnded(gesture)
        default:
            ()
        }
    }
    fileprivate func handleChanged(_ gesture: UIPanGestureRecognizer) {
        // Rotation
        let translation = gesture.translation(in: nil)
        let degrees: CGFloat = translation.x / 20
        let angle = degrees * .pi / 180

        let rotationalTransformation = CGAffineTransform(rotationAngle: angle)
        self.transform = rotationalTransformation.translatedBy(x: translation.x, y: translation.y)
    }
    fileprivate func handleEnded(_ gesture: UIPanGestureRecognizer) {
        let translationDirection: CGFloat = gesture.translation(in: nil).x > 0 ? 1 : -1
        let shouldDismissCard = abs(gesture.translation(in: nil).x) > threshold

        if shouldDismissCard {
            guard let homeController = self.delegate as? HomeViewController else { return }
            if translationDirection == 1 {
                homeController.didTapLikeButton()
            } else {
                homeController.didTapDislikeButton()
            }
        } else {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1) {
                self.transform = .identity
            }
        }
    }
    @objc fileprivate func handleTap(_ gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: nil)
        let shouldAdvanceNextPhoto = tapLocation.x > frame.width / 2 ? true : false
        if shouldAdvanceNextPhoto {
            cardViewModel.advanceToNextPhoto()
        } else {
            cardViewModel.goToPreviousPhoto()
        }
    }
    @objc fileprivate func didTapMoreInfoButton(with button: UIButton) {
        delegate?.didTapMoreInfo(cardViewModel: self.cardViewModel)
    }
    
}
