//
//  CardViewModel.swift
//  Tinder
//
//  Created by Kaan Yeyrek on 11/20/22.
//

import UIKit

protocol ProducesCardViewModel {
    func toCardViewModel() -> CardViewModel
}

class CardViewModel {
    
    let imageURL: [String]
    let attributedString: NSAttributedString
    let textAlignment: NSTextAlignment
    let uid: String
    
    init(uid: String, imageNames: [String], attributedString: NSAttributedString, textAlignment: NSTextAlignment) {
        self.imageURL = imageNames
        self.attributedString = attributedString
        self.textAlignment = textAlignment
        self.uid = uid
    }
    fileprivate var imageIndex = 0 {
        didSet {
            let imageUrl = imageURL[imageIndex]
            imageIndexObserver?(imageIndex, imageUrl)
        }
    }
    // react method
    var imageIndexObserver: ((Int, String?) -> ())?
    
    func advanceToNextPhoto() {
        imageIndex = min(imageIndex + 1, imageURL.count - 1)
    }
    
    func goToPreviousPhoto() {
        imageIndex = max(0, imageIndex - 1)
    }
}
    

