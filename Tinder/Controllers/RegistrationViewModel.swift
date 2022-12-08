//
//  RegistrationViewModel.swift
//  Tinder
//
//  Created by Kaan Yeyrek on 11/23/22.
//
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage


class RegistrationViewModel {
    var bindableIsRegistering = Bindable<Bool>()
    var bindableImage = Bindable<UIImage>()
    var bindableIsFormValid = Bindable<Bool>()
    var database = Database.database().reference()
    var storage = Storage.storage().reference()
    
    
    var fullName: String? { didSet { checkFormValidity() }}
    var email: String? { didSet { checkFormValidity() }}
    var password: String? { didSet { checkFormValidity() }}
    
    public func checkFormValidity() {
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false && bindableImage.value != nil
        bindableIsFormValid.value = isFormValid
        
    }
    public func performRegistration(completion: @escaping (Error?) -> ()) {
        guard let email = email, let password = password else { return }
        self.bindableIsRegistering.value = true
        Auth.auth().createUser(withEmail: email, password: password) { response, error in
            if let error = error {
                completion(error)
                return
            }
            self.saveImageToFirebase(completion: completion)
        }
    }
    fileprivate func saveImageToFirebase(completion: @escaping (Error?) -> Void) {
        let filename = UUID().uuidString
        let ref = self.storage.child("/images/\(filename)")
        let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
        ref.putData(imageData, metadata: nil, completion: { _, err in

            if let err = err {
                completion(err)
                return
            }
            ref.downloadURL(completion: { url, err in
                if let err = err {
                    completion(err)
                    return
                }
                self.bindableIsRegistering.value = false
                let imageURL = url?.absoluteString ?? ""
                self.saveInfoToFirestore(with: imageURL, completion: completion)
            })
        })
    }
    fileprivate func saveInfoToFirestore(with url: String, completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let docData = ["fullName": fullName ?? "", "uid": uid, "imageURL1": url]
        self.database.child("Users").child(uid).setValue(docData) { error, _ in
            if let error = error {
                completion(error)
            }
            completion(nil)
        }
    }
}
