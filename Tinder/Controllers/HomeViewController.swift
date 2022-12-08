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
import FirebaseAuth


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
    var swipes = [String : Int]()
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
        bottomStackView.likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        bottomStackView.dislikeButton.addTarget(self, action: #selector(didTapDislikeButton), for: .touchUpInside)
        stackViewLayout()
        self.fetchSwipes()
    }
    @objc fileprivate func didTapRefreshButton(with button: UIButton) {
        cardsDeckView.subviews.forEach({
            $0.removeFromSuperview()
        })
        fetchUsersFromFirestore()
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
            hud.dismiss()
            guard error == nil else {
                print("error")
                return
            }

            var previousCardView: CardView?
            if let value = snapshot.value as? [String: Any] {
                value.forEach({ documentSnapshot in
                    let userDictionary = documentSnapshot.value
                    let user = User(dictionary: userDictionary as! [String: Any])
                   // self.cardViewModels.append(user.toCardViewModel())
                    let hasNotSwipedBefore = true
                    if hasNotSwipedBefore {
                        let cardView = self.setupCardFromUser(user: user)
                        previousCardView?.nextCardView = cardView
                        previousCardView = cardView
                        if self.topCardView == nil {
                            self.topCardView = cardView
                        }
                    }
                })
            }
        }
    }
    var topCardView: CardView?
    fileprivate func setupCardFromUser(user: User) -> CardView {
        let cardView = CardView(frame: .zero)
        cardView.delegate = self
        cardView.cardViewModel = user.toCardViewModel()
        cardsDeckView.addSubview(cardView)
        cardsDeckView.sendSubviewToBack(cardView)
        cardView.fillSuperview()
        return cardView
    }
    fileprivate func performSwipeAnimation(translation: CGFloat, angle: CGFloat) {
        let translationAnimation = CABasicAnimation(keyPath: "position.x")
        translationAnimation.toValue = translation
        translationAnimation.duration = 0.5
        translationAnimation.fillMode = .forwards
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        translationAnimation.isRemovedOnCompletion = false
        
        let rotationalAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationalAnimation.toValue = angle * CGFloat.pi / 180
        rotationalAnimation.duration = 0.5
        
        let cardView = topCardView
        topCardView = cardView?.nextCardView
        
        CATransaction.setCompletionBlock {
            cardView?.removeFromSuperview()
        }
        cardView?.layer.add(translationAnimation, forKey: "translation")
        cardView?.layer.add(rotationalAnimation, forKey: "rotation")
        CATransaction.commit()
    }
    @objc func didTapLikeButton() {
        saveSwipeToFirebase(didLike: 1)
        performSwipeAnimation(translation: 700, angle: 15)
    }
    @objc func didTapDislikeButton() {
        saveSwipeToFirebase(didLike: 0)
        performSwipeAnimation(translation: -700, angle: -15)
    }
    fileprivate func fetchSwipes() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        self.database.child("swipes").child(uid).getData { error, snapshot in
            if error != nil {
                print("failed")
                return
            }
            guard let data = snapshot.value as? [String: Int] else { return }
            self.swipes = data
            self.fetchUsersFromFirestore()
        }
    }
    fileprivate func saveSwipeToFirebase(didLike: Int) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let cardUID = topCardView?.cardViewModel.uid else { return }
        
        let data = [cardUID: didLike]
        
        self.database.child("swipes").child(uid).getData { error, snapshot in
            if error != nil {
                return
            }
            if snapshot.exists() == true {
                self.database.child("swipes").child(uid).updateChildValues(data) { error, _ in
                    if error != nil {
                        return
                    }
                    if didLike == 1 {
                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                }
            } else {
                self.database.child("swipes").child(uid).setValue(data) { error, _ in
                    if error != nil {
                        return
                    }
                    if didLike == 1 {
                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                }
            }
        }
    }
    fileprivate func checkIfMatchExists(cardUID: String) {
        self.database.child("swipes").child(cardUID).getData { error, snapshot in
            if error != nil {
                print("failed")
                return
            }
            guard let data = snapshot.value as? [String: Any] else { return }
            guard let uid = Auth.auth().currentUser?.uid else { return }

            let hasMatched = data[uid] as? Int == 1
            if hasMatched {
                self.presentMatchView(cardUID: cardUID)
            }
        }
    }
    // Matched screen
    fileprivate func presentMatchView(cardUID: String) {
        let matchedView = MatchedView()
        matchedView.cardUID = cardUID
        view.addSubview(matchedView)
        matchedView.fillSuperview()
    }
    // swiping and delete card delegate method
        func didRemoveCard(cardView: CardView) {
        self.topCardView?.removeFromSuperview()
        self.topCardView = self.topCardView?.nextCardView
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

