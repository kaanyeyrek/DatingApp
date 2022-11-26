//
//  SettingsCell.swift
//  Tinder
//
//  Created by Kaan Yeyrek on 11/25/22.
//

import UIKit

class SettingsTextField: UITextField {
    override var intrinsicContentSize: CGSize {
        return .init(width: 0, height: 44)
    }
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 24, dy: 0)
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 24, dy: 0)
    }
    
}
class SettingsCell: UITableViewCell {
        let textField: SettingsTextField = {
        let field = SettingsTextField()
        field.placeholder = "Enter name"
        return field
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(textField)
        textField.fillSuperview()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
