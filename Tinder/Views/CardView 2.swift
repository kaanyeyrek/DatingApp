//
//  CardView.swift
//  Tinder
//
//  Created by Kaan Yeyrek on 11/19/22.
//

import UIKit
import SDWebImage

class CardView: UIView {
    var cardViewModel: CardViewModel! {
        didSet {
            let imageName = cardViewModel.imageName.first ?? ""
            if let url = URL(string: imageName) {
                imageView.sd_setImage(with: url)
            }
            informationLabel.attributedText = cardViewModel.attributedString
            informationLabel.textAlignment = cardViewModel.textAlignment
            
            (0..<cardViewModel.imageName.count).forEach { _ in
                let barView = UIView()
                barView.backgroundColor = barDeselectedColor
                barStackView.addArrangedSubview(barView)
            }
            barStackView.arrangedSubviews.first?.backgroundColor = .white
        }
    }
    fileprivate let imageView = UIImageView(image: UIImage(named: "lady"))
    fileprivate let informationLabel = UILabel()
    fileprivate let gradientLayer = CAGradientLayer()
    // Config ShouldDismissCard
    fileprivate let threshold: CGFloat = 80
    fileprivate var imageIndex = 0
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
    fileprivate func setupLayout() {
        layer.cornerRadius = 10
        layer.masksToBounds = true
        clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        imageView.fillSuperview()
        setupBarsStackView()
        setupGradientLayer()
        //information label
        addSubview(informationLabel)
        informationLabel.anchor(top: nil, leading: self.leadingAnchor, bottom: self.bottomAnchor,
                                trailing: self.trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16))
        informationLabel.textColor = .white
        informationLabel.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        informationLabel.numberOfLines = 0
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

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
            if shouldDismissCard {
                self.layer.frame = CGRect(x: 600 * translationDirection, y: 0, width: self.frame.width, height: self.frame.height)

            } else {
                self.transform = .identity
            }

        }) { _ in
            self.transform = .identity
            if shouldDismissCard {
                self.removeFromSuperview()
            }
        }
    }
    @objc fileprivate func didTapPhoto(_ gesture: UIPanGestureRecognizer) {
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
    @objc fileprivate func handleTap(_ gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: nil)
        let shouldAdvanceNextPhoto = tapLocation.x > frame.width / 2 ? true : false
        if shouldAdvanceNextPhoto {
            imageIndex = min(imageIndex + 1, cardViewModel.imageName.count - 1)
        } else {
            imageIndex = max(0, imageIndex - 1)
        }
        let imageName = cardViewModel.imageName[imageIndex]
        if let url = URL(string: imageName) {
            self.imageView.sd_setImage(with: url)
        }
        barStackView.arrangedSubviews.forEach { v in
            v.backgroundColor = barDeselectedColor
        }
        barStackView.arrangedSubviews[imageIndex].backgroundColor = .white
    
    }
    
}
