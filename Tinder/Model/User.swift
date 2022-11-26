//
//  User.swift
//  Tinder
//
//  Created by Kaan Yeyrek on 11/19/22.
//
import UIKit
import Foundation

struct User: ProducesCardViewModel {
    let name: String?
    let age: Int?
    let profession: String?
    let imageURL1: String?
    let uid: String?
    
    
    init(dictionary: [String: Any]) {
        self.name = dictionary["fullName"] as? String ?? ""
        self.age = dictionary["age"] as? Int
        self.profession = dictionary["profession"] as? String
        self.imageURL1 = dictionary["imageURL1"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
       
    }

    func toCardViewModel() -> CardViewModel {
        let attributedText = NSMutableAttributedString(string: name ?? "", attributes: [.font: UIFont.systemFont(ofSize: 32, weight: .heavy)])
        let ageString = age != nil ? "\(age!)" : "N/A"
        attributedText.append(NSAttributedString(string: "  \(ageString)", attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .regular)]))
        let professionString = profession != nil ? profession! : "Not available"
        attributedText.append(NSAttributedString(string: "\n\(professionString)", attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .regular)]))
        return CardViewModel(imageName: [imageURL1 ?? ""], attributedString: attributedText, textAlignment: .left)
    }

}

