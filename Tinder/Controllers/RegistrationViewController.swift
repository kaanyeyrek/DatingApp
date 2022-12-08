//
//  RegistrationViewController.swift
//  Tinder
//
//  Created by Kaan Yeyrek on 11/22/22.
//

import UIKit
import Firebase
import JGProgressHUD



class RegistrationViewController: UIViewController {
    // UI Components
    fileprivate let selectPhotoButton: UIButton = {
        let button = UIButton()
        button.setTitle("Select Photo", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 275).isActive = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapPhoto), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        return button
    }()
    fileprivate let fullNameTextField: CustomTextField = {
        let textField = CustomTextField(padding: 24, height: 50)
        textField.placeholder = "Enter full name"
        textField.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return textField
    }()
    fileprivate let emailTextfield: CustomTextField = {
        let textField = CustomTextField(padding: 24, height: 50)
        textField.placeholder = "Enter email"
        textField.keyboardType = .emailAddress
        textField.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return textField
    }()
    fileprivate let passwordTextfield: CustomTextField = {
        let textField = CustomTextField(padding: 24, height: 50)
        textField.placeholder = "Enter password"
        textField.isSecureTextEntry = true
        textField.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return textField
    }()
    fileprivate let registerButton: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 25
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .lightGray
        button.setTitleColor(.gray, for: .disabled)
        button.isEnabled = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
        return button
    }()
    fileprivate let goToLoginButton: UIButton = {
       let button = UIButton()
        button.setTitle("Go to Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        return button
    }()
    let registeringHUD = JGProgressHUD(style: .dark)
    let gradientLayer = CAGradientLayer()
    let registrationViewModel = RegistrationViewModel()
    // Custom textfield

//MARK: - LifeCycle
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        setupGradientLayer()
        setTapGesture()
        setLayout()
        setupRegistrationViewModelObserver()
     
    }
    fileprivate func setupRegistrationViewModelObserver() {
        registrationViewModel.bindableIsFormValid.bind { [unowned self] isFormValid in
            guard let isFormValid = isFormValid else { return }
            self.registerButton.isEnabled = isFormValid
            self.registerButton.backgroundColor = isFormValid ? #colorLiteral(red: 0.8235294118, green: 0, blue: 0.3254901961, alpha: 1) : .lightGray
            self.registerButton.setTitleColor(isFormValid ? .white : .gray, for: .normal)
        }
            registrationViewModel.bindableImage.bind { [unowned self] image in
                self.selectPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        registrationViewModel.bindableIsRegistering.bind { [unowned self] isRegistering in
            if isRegistering == true {
                self.registeringHUD.textLabel.text = "Register"
                self.registeringHUD.show(in: view)
                
            } else {
                self.registeringHUD.dismiss()
            }
        }
            
     
    }
    
    fileprivate func setLayout() {
        lazy var stackView = UIStackView(arrangedSubviews: [selectPhotoButton, fullNameTextField, emailTextfield, passwordTextfield, registerButton])
        view.addSubview(stackView)
        view.addSubview(goToLoginButton)
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 0, right: 50))
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        goToLoginButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
    }
    fileprivate func setTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapDismiss)))
    }
    @objc fileprivate func didTapLoginButton(with button: UIButton) {
        let loginController = LoginViewController()
        navigationController?.pushViewController(loginController, animated: true)
    }
    // Register
    @objc fileprivate func didTapRegisterButton() {
        self.resignFirstResponder()
        registrationViewModel.performRegistration { error in
            if let error = error {
                self.showHUDWithError(error: error)
                return
            }
            self.dismiss(animated: true)
        }
    }
    // JGProgressHUD
    fileprivate func showHUDWithError(error: Error) {
        registeringHUD.dismiss()
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Failed Registration"
        hud.detailTextLabel.text = error.localizedDescription
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 3)
    }
    @objc fileprivate func tapDismiss() {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.5) {
            self.view.transform = .identity
        }
    }
    @objc fileprivate func handleTextChange(textField: UITextField) {
        if textField == fullNameTextField {
            registrationViewModel.fullName = textField.text
        } else if textField == emailTextfield {
            registrationViewModel.email = textField.text
        } else {
            registrationViewModel.password = textField.text
        }
   
    }
    @objc fileprivate func didTapPhoto(button: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true)
        
    }
    fileprivate func setupGradientLayer() {
        let topColor = #colorLiteral(red: 1, green: 0, blue: 0.4287317395, alpha: 1)
        let bottomColor = #colorLiteral(red: 1, green: 0, blue: 0.1079617217, alpha: 1)
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0, 1]
        view.layer.addSublayer(gradientLayer)
    }
}
//MARK: - UIImagePicker Methods
extension RegistrationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        let image = info[.originalImage] as? UIImage
        registrationViewModel.bindableImage.value = image
        registrationViewModel.checkFormValidity()
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
}
