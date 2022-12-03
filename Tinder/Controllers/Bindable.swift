//
//  Bindable.swift
//  Tinder
//
//  Created by Kaan Yeyrek on 11/23/22.
//

import Foundation

class Bindable<T> {
    var value: T? {
        didSet {
            observer?(value)
        }
    }

    var observer: ((T?)->())?
        func bind(observer: @escaping (T?) -> ()) {
            self.observer = observer
        }
}
