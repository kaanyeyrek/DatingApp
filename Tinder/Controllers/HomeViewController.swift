//
//  ViewController.swift
//  Tinder
//
//  Created by Kaan Yeyrek on 11/19/22.
//

import UIKit
import Firebase
import FirebaseDatabase
import JGProgressHUD


class HomeViewController: UIViewController {
    
    let topStackView = TopNavigationStackView()
    let bottomStackView = HomeBottomStackView()
    let cardsDeckView = UIView()
    var database = Database.database().reference()
    
//    let cardViewModels: [CardViewModel] = {
//        let producers = [User(name: "Kelly", age: 22, profession: "iOS developer", imageName: ["lady"]),
//                         User(name: "Jane", age: 20, profession: "Math Teacher", imageName: ["lady2"]),
//                         User(name: "Victoria", age: 20, profession: "Pyhton developer", imageName: ["jane1", "jane2", "jane3"]),
//                         Advertiser(title: "Slide Out Menu", brandName: "Kaan", posterPhotoName: "slide")
//        ] as [ProducesCardViewModel]
//        let viewModels = producers.map { $0.toCardViewModel() }
//        return viewModels
//    }()
    var cardViewModels = [CardViewModel]()
    //MARK: - LifeCycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser == nil {
            let loginViewController = LoginViewController()
            let nav = UINavigationController(rootViewController: loginViewController)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        topStackView.profileButton.addTarget(self, action: #selector(didTapProfileButton), for: .touchUpInside)
        bottomStackView.refreshButton.addTarget(self, action: #selector(didTapRefreshButton), for: .touchUpInside)
        stackViewLayout()
        fetchUsersFromFirestore()
    }
    @objc fileprivate func didTapRefreshButton(with button: UIButton) {
        didTapRefreshQuery()
    }
    // Firebase fetch user
    fileprivate func fetchUsersFromFirestore() {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Loading"
        hud.show(in: view)
        cardsDeckView.subviews.forEach({
            $0.removeFromSuperview()
        })
        let data = self.database.child("Users")
        data.getData { error, snapshot in
            guard error == nil else {
                print("error")
                return
            }
            hud.dismiss()
            if let value = snapshot.value as? [String: Any] {
                value.forEach({ documentSnapshot in
                    let userDictionary = documentSnapshot.value
                    let user = User(dictionary: userDictionary as! [String: Any])
                    self.cardViewModels.append(user.toCardViewModel())
                    if user.uid != Auth.auth().currentUser?.uid {
                        self.setupCardFromUser(user: user)
                    }
                })
            }
        }
    }
    // Firebase fetch query
    fileprivate func didTapRefreshQuery() {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Refreshing..."
        hud.show(in: view)
        let query = self.database.child("Users").queryOrderedByKey().queryLimited(toFirst: .random(in: 1...5))
        query.getData { error, snapshot in
            guard error == nil else {
                print("error")
                return
            }
            hud.dismiss()
            if let value = snapshot.value as? [String: Any] {
                value.forEach({ documentSnapshot in
                    let userDictionary = documentSnapshot.value
                    let user = User(dictionary: userDictionary as! [String: Any])
                    self.cardViewModels.append(user.toCardViewModel())
                    self.setupCardFromUser(user: user)
                })
            }
        }
    }

    fileprivate func setupCardFromUser(user: User) {
        let cardView = CardView(frame: .zero)
        cardView.delegate = self
        cardView.cardViewModel = user.toCardViewModel()
        cardsDeckView.addSubview(cardView)
        cardsDeckView.sendSubviewToBack(cardView)
        cardView.fillSuperview()
    }
    @objc fileprivate func didTapProfileButton() {
        let settingsVC = SettingsTableViewController()
        let nav = UINavigationController(rootViewController: settingsVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    fileprivate func stackViewLayout() {
        view.backgroundColor = .white
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, bottomStackView])
        overallStackView.axis = .vertical
        view.addSubview(overallStackView)
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        overallStackView.bringSubviewToFront(cardsDeckView)
    }
    }
//MARK: - CardViewDelegate
extension HomeViewController: CardViewDelegate {
    func didTapMoreInfo(cardViewModel: CardViewModel) {
        let vc = UserDetailsViewController()
        vc.cardViewModel = cardViewModel
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

