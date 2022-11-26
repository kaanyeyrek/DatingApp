//
//  CardViewModel.swift
//  Tinder
//
//  Created by Kaan Yeyrek on 11/20/22.
//

import Foundation
import UIKit

protocol ProducesCardViewModel {
    func toCardViewModel() -> CardViewModel
}

struct CardViewModel {
    let imageName: [String]
    let attributedString: NSAttributedString
    let textAlignment: NSTextAlignment
    
}
