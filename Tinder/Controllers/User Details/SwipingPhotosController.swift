//
//  SwipingPhotosController.swift
//  Tinder
//
//  Created by Kaan Yeyrek on 12/2/22.
//

import UIKit

class SwipingPhotosController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var cardViewModel: CardViewModel! {
        didSet {
            controllers = cardViewModel.imageName.map({ imageName -> UIViewController in
                let photoController = PhotoController(imageURL: imageName)
                return photoController
            })
        }
    }

    var controllers = [UIViewController]()
    fileprivate let barStackView = UIStackView(arrangedSubviews: [])
    fileprivate let barDeselectedColor = UIColor(white: 0, alpha: 0.1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        dataSource = self
        delegate = self
        setupBarViews()
        setupLayout()
       
    
        setViewControllers([controllers.first!], direction: .forward, animated: false)
    }
    fileprivate func setupLayout() {
        view.addSubview(barStackView)
        barStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
        barStackView.arrangedSubviews.first?.backgroundColor = .white        
    }
    fileprivate func setupBarViews() {
        cardViewModel.imageName.forEach { _ in
            let barView = UIView()
            barView.backgroundColor = barDeselectedColor
            barView.layer.cornerRadius = 2
            barStackView.spacing = 4
            barStackView.distribution = .fillEqually
            barStackView.addArrangedSubview(barView)
        }
    }
    // UIPageView
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = self.controllers.firstIndex(where: {$0 == viewController}) ?? 0
        if index == 0 { return nil }
        return controllers[index - 1]
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = self.controllers.firstIndex(where: {$0 == viewController}) ?? 0
        if index == controllers.count - 1 { return nil }
        return controllers[index + 1]
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let currentPhotoController = viewControllers?.first
        if let index = controllers.firstIndex(where: {$0 == currentPhotoController}) {
        barStackView.arrangedSubviews.forEach({ $0.backgroundColor = barDeselectedColor})
            barStackView.arrangedSubviews[index].backgroundColor = .white
    }
    }
}
class PhotoController: UIViewController {
    fileprivate let imageView: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()
    // init
    init(imageURL: String) {
        if let url = URL(string: imageURL) {
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
    }
}
