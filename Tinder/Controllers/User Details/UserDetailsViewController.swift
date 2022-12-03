//
//  UserDetailsViewController.swift
//  Tinder
//
//  Created by Kaan Yeyrek on 12/1/22.
//

import UIKit
import SDWebImage

class UserDetailsViewController: UIViewController {
    
    var cardViewModel: CardViewModel! {
        didSet {
            infoLabel.attributedText = cardViewModel.attributedString
            swipingController.cardViewModel = cardViewModel
        }
    }
    let swipingController = SwipingPhotosController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = .clear
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        sv.delegate = self
        return sv
    }()

    fileprivate let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "User name 30\nDoctor\nSome bio text down below"
        label.numberOfLines = 0
        return label
    }()
    fileprivate let dismissButon: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "dismiss_down_arrow")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(didTapDismissButton), for: .touchUpInside)
        return button
    }()
    lazy var dislikeButton = self.createButton(image: #imageLiteral(resourceName: "dismiss_circle"), selector: #selector(didTapDislikeButton))
    lazy var likeButton = self.createButton(image: #imageLiteral(resourceName: "like_circle"), selector: #selector(didTapLikeButton))
    lazy var superLikeButton = self.createButton(image: #imageLiteral(resourceName: "super_like_circle"), selector: #selector(didTapSuperLikeButton))
    // Three bottom controls func
    fileprivate func createButton(image: UIImage, selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.contentMode = .scaleAspectFill
        return button
    }
    fileprivate let extraSwipingHeight: CGFloat = 80
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        autoLayout()
        setupVisualBlurEffectView()
        setupBottomControls()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let imageView = swipingController.view!
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width + extraSwipingHeight)
        
    }
    //Layout
    fileprivate func autoLayout() {
        view.addSubview(scrollView)
        scrollView.fillSuperview()
        
        let imageView = swipingController.view!
        scrollView.addSubview(imageView)
        
        scrollView.addSubview(infoLabel)
        infoLabel.anchor(top: imageView.bottomAnchor, leading: scrollView.leadingAnchor, bottom: nil, trailing: scrollView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
        
        scrollView.addSubview(dismissButon)
        dismissButon.anchor(top: imageView.bottomAnchor, leading: nil, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: -25, left: 0, bottom: 0, right: 24), size: .init(width: 50, height: 50))
    }
    // Top blur effect
    fileprivate func setupVisualBlurEffectView() {
        let blurEffect = UIBlurEffect(style: .regular)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        view.addSubview(visualEffectView)
        visualEffectView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    //Bottom UIStackView
    fileprivate func setupBottomControls() {
        let stackView = UIStackView(arrangedSubviews: [dislikeButton, superLikeButton, likeButton])
        stackView.distribution = .fillEqually
        stackView.spacing = -32
        view.addSubview(stackView)
        stackView.anchor(top: nil, leading: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 300, height: 80))
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    } 
//MARK: - Objc action methods
    @objc fileprivate func didTapDismissButton(with button: UIButton) {
        self.dismiss(animated: true)
    }
    @objc fileprivate func didTapDislikeButton(with button: UIButton) {
        print("tapped")
    }
    @objc fileprivate func didTapLikeButton(with button: UIButton) {
        print("tapped")
    }
    @objc fileprivate func didTapSuperLikeButton(with button: UIButton) {
        print("tapped")
    }

}
//MARK: - UIScrollView Delegate methods
extension UserDetailsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let changeY = -scrollView.contentOffset.y
        var width = view.frame.width + changeY * 2
        width = max(view.frame.width, width)
        let imageView = swipingController.view!
        imageView.frame = CGRect(x: min(0, -changeY), y: min(0 ,-changeY), width: width, height: width + extraSwipingHeight)
    }
}
