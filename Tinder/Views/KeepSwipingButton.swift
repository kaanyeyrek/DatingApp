//
//  KeepSwipingButton.swift
//  Tinder
//
//  Created by Kaan Yeyrek on 12/7/22.
//

import UIKit

class KeepSwipingButton: UIButton {
    let gradientLayer = CAGradientLayer()
    let maskLayer = CAShapeLayer()
    let maskPath = CGMutablePath()
   
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let cornerRadius = rect.height / 2
        let leftColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        let rightColor = #colorLiteral(red: 0.9372549057, green: 0.2486794807, blue: 0.1921568662, alpha: 1)
        gradientLayer.colors = [leftColor.cgColor, rightColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        
        maskPath.addPath(UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath)
        maskLayer.path = maskPath
        
        maskPath.addPath(UIBezierPath(roundedRect: rect.insetBy(dx: 2, dy: 2), cornerRadius: cornerRadius).cgPath)
        maskLayer.path = maskPath
        maskLayer.fillRule = .evenOdd
        gradientLayer.mask = maskLayer
        
        
        self.layer.addSublayer(gradientLayer)
        self.layer.insertSublayer(gradientLayer, at: 0)
        self.layer.cornerRadius = rect.height / 2
        clipsToBounds = true
        gradientLayer.frame = rect
    }
   

}
 
