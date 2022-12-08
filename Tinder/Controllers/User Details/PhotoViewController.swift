//
//  PhotoViewController.swift
//  Tinder
//
//  Created by Kaan Yeyrek on 12/3/22.
//

import UIKit
import SDWebImage

class PhotoController: UIViewController {
    let imageView = UIImageView(image: #imageLiteral(resourceName: "jane2"))
    // init
    init(imageUrl: String) {
        if let url = URL(string: imageUrl) {
            imageView.sd_setImage(with: url)
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        imageView.fillSuperview()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
}
