//
//  LoginViewModel.swift
//  Tinder
//
//  Created by Kaan Yeyrek on 11/30/22.
//

import Foundation
import Firebase

class LoginViewModel {
    var isLoggingIn = Bindable<Bool>()
    var isFormValid = Bindable<Bool>()
    
    
    var email: String? { didSet { checkFromValid() }}
    var password: String? { didSet { checkFromValid() }}
    
    fileprivate func checkFromValid() {
        let isValid = email?.isEmpty == false && password?.isEmpty == false
            isFormValid.value = isValid
    }
    func performLogin(completion: @escaping (Error?) -> ()) {
        guard let email = email, let password = password else { return }
        isLoggingIn.value = true
        Auth.auth().signIn(withEmail: email, password: password) { data, error in
            completion(error)
        }
    }
    
}
