//
//  MatchedView.swift
//  Tinder
//
//  Created by Kaan Yeyrek on 12/6/22.
//

import UIKit
import Firebase
import FirebaseDatabase
import SDWebImage

class MatchedView: UIView {
    lazy var views = [currentUserImage, cardUserImage, logoImage, descriptionLabel, sendMessageButton, keepSwipingButton]
    fileprivate var database = Database.database().reference()

    var cardUID: String! {
        didSet {
            // fetch the cardUID information
            self.database.child("Users").child(cardUID).getData { error, snapshot in
                if error != nil {
                    print("failed")
                    return
                }
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                let user = User(dictionary: dictionary)
                guard let url = URL(string: user.imageURL1 ?? "") else { return }
                self.cardUserImage.sd_setImage(with: url)
                self.setupAnimations()
            }
        }
    }
    private let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

    fileprivate let currentUserImage: UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "jane1"))
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.borderWidth = 2
        image.layer.borderColor = UIColor.white.cgColor
        return image
    }()
    fileprivate let cardUserImage: UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "lady2"))
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.borderWidth = 2
        image.layer.borderColor = UIColor.white.cgColor
        return image
    }()
    fileprivate let logoImage: UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "itsamatch"))
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()
    fileprivate let descriptionLabel: UILabel = {
       let label = UILabel()
        label.text = "You and X have Liked\n each other"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 0
        return label
    }()
    fileprivate let sendMessageButton: UIButton = {
        let button = SendMessageButton()
        button.setTitle("SEND MESSAGE", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    fileprivate let keepSwipingButton: UIButton = {
        let button = KeepSwipingButton()
        button.setTitle("Keep Swiping", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBlurView()
        setupLayout()
 
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    fileprivate func setupAnimations() {
        views.forEach({
            $0.alpha = 1
        })
        let angle = 30 * CGFloat.pi / 180
        currentUserImage.transform = CGAffineTransform(rotationAngle: -angle).concatenating(CGAffineTransform(translationX: 200, y: 0))
        cardUserImage.transform = CGAffineTransform(rotationAngle: angle).concatenating(CGAffineTransform(translationX: -200, y: 0))
        sendMessageButton.transform = CGAffineTransform(translationX: -500, y: 0)
        keepSwipingButton.transform = CGAffineTransform(translationX: 500, y: 0)
        UIView.animateKeyframes(withDuration: 1.2, delay: 0, options: .calculationModeCubic) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                self.currentUserImage.transform = CGAffineTransform(rotationAngle: -angle)
                self.cardUserImage.transform = CGAffineTransform(rotationAngle: angle)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
                self.currentUserImage.transform = .identity
                self.cardUserImage.transform = .identity
            }
        }
        UIView.animate(withDuration: 0.4, delay: 0.6 * 1.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseOut) {
            self.sendMessageButton.transform = .identity
            self.keepSwipingButton.transform = .identity
        }
    }
    fileprivate func setupLayout() {
        views.forEach { v in
            addSubview(v)
            v.alpha = 0
        }
        let imageSize: CGFloat = 140
        currentUserImage.anchor(top: nil, leading: nil, bottom: nil, trailing: centerXAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 16), size: .init(width: imageSize, height: imageSize))
        currentUserImage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        currentUserImage.layer.cornerRadius = imageSize / 2
        
        cardUserImage.anchor(top: nil, leading: centerXAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 16, bottom: 0, right: 0), size: .init(width: imageSize, height: imageSize))
        cardUserImage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        cardUserImage.layer.cornerRadius = imageSize / 2
        
        descriptionLabel.anchor(top: nil, leading: self.leadingAnchor, bottom: currentUserImage.topAnchor, trailing: self.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 32, right: 0), size: .init(width: 0, height: 50))
        
        logoImage.anchor(top: nil, leading: nil, bottom: descriptionLabel.topAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 16, right: 0), size: .init(width: 300, height: 80))
        logoImage.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        sendMessageButton.anchor(top: currentUserImage.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 32, left: 48, bottom: 0, right: 48), size: .init(width: 0, height: 60))
        
        keepSwipingButton.anchor(top: sendMessageButton.bottomAnchor, leading: sendMessageButton.leadingAnchor, bottom: nil, trailing: sendMessageButton.trailingAnchor, padding: .init(top: 16, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 60))
    }
    fileprivate func setupBlurView() {
        visualEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
        addSubview(visualEffectView)
        visualEffectView.fillSuperview()
        visualEffectView.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.visualEffectView.alpha = 1
        }) { _ in
        }
    }
    @objc fileprivate func handleTapDismiss() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
}
