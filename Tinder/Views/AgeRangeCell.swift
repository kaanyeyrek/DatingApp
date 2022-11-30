//
//  AgeRangeCell.swift
//  Tinder
//
//  Created by Kaan Yeyrek on 11/28/22.
//

import UIKit
// Custom label
class AgeRangeLabel: UILabel {
    override var intrinsicContentSize: CGSize {
        return .init(width: 80, height: 0)
    }
}

class AgeRangeCell: UITableViewCell {
    
    let minSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 18
        slider.maximumValue = 100
        return slider
    }()
    let maxSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 18
        slider.maximumValue = 100
        return slider
    }()
    let minLabel: UILabel = {
       let label = AgeRangeLabel()
        label.text = "Min 88"
        
        return label
    }()
    let maxLabel: UILabel = {
       let label = AgeRangeLabel()
        label.text = "Max 88"
        return label
    }()
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let overAllStackView = UIStackView(arrangedSubviews: [
         UIStackView(arrangedSubviews: [minLabel, minSlider]),
         UIStackView(arrangedSubviews: [maxLabel, maxSlider])
         ])
        overAllStackView.axis = .vertical
        overAllStackView.spacing = 16
        addSubview(overAllStackView)
        overAllStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 16, left: 16, bottom: 16, right: 16))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}
