//
//  TopNavigationStackView.swift
//  Tinder
//
//  Created by Kaan Yeyrek on 11/19/22.
//

import UIKit

class TopNavigationStackView: UIStackView {
    public let profileButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "top_left_profile")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        heightAnchor.constraint(equalToConstant: 80).isActive = true
        distribution = .fillEqually
        addArrangedSubviews()
        

        let subviews = [#imageLiteral(resourceName: "app_icon"), #imageLiteral(resourceName: "top_right_messages")].map { img -> UIView in
            let button = UIButton(type: .system)
            button.setImage(img.withRenderingMode(.alwaysOriginal), for: .normal)
            return button
        }
        subviews.forEach { v in
            addArrangedSubview(v)
        }
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func addArrangedSubviews() {
        addArrangedSubview(profileButton)
    }
}
