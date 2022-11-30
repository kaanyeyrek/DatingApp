//
//  LoginViewController.swift
//  Tinder
//
//  Created by Kaan Yeyrek on 11/30/22.
//

import UIKit
import Firebase
import JGProgressHUD

class LoginViewController: UIViewController {
    fileprivate let emailTextField: CustomTextField = {
       let field = CustomTextField(padding: 24, height: 50)
        field.placeholder = "Enter email"
        field.keyboardType = .emailAddress
        field.returnKeyType = .done
        field.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return field
    }()
    fileprivate let passwordTextField: CustomTextField = {
       let field = CustomTextField(padding: 24, height: 50)
        field.placeholder = "Enter password"
        field.isSecureTextEntry = true
        field.returnKeyType = .done
        field.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return field
    }()
    fileprivate let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.gray, for: .disabled)
        button.isEnabled = false
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 22
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    fileprivate let backToRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Go to Register", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleBackRegister), for: .touchUpInside)
        return button
    }()
    lazy var verticalStackView: UIStackView = {
       let sv = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        sv.axis = .vertical
        sv.spacing = 8
        return sv
    }()
    fileprivate let loginViewModel = LoginViewModel()
    fileprivate let logInHud = JGProgressHUD(style: .dark)
    fileprivate let gradientLayer = CAGradientLayer()
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientLayer()
        setupLayout()
        setupBindables()

    }
    fileprivate func setupBindables() {
        loginViewModel.isFormValid.bind { [unowned self] isFormValid in
            guard let isFormValid = isFormValid else { return }
            self.loginButton.isEnabled = isFormValid
            self.loginButton.backgroundColor = isFormValid ? #colorLiteral(red: 1, green: 0, blue: 0.4287317395, alpha: 1) : .lightGray
            self.loginButton.setTitleColor(isFormValid ? .white : .gray, for: .normal)
        }
        loginViewModel.isLoggingIn.bind { [unowned self] isLoggingIn in
            if isLoggingIn == true {
                self.logInHud.textLabel.text = "Register"
                self.logInHud.show(in: view)
            }
            else {
                self.logInHud.dismiss()
            }
        }
    }
    //MARK: - Objc Actions
    @objc fileprivate func handleTextChange(textField: UITextField) {
        if textField == emailTextField {
            loginViewModel.email = textField.text
        } else {
            loginViewModel.password = textField.text
        }
    }
    @objc fileprivate func handleLogin() {
        loginViewModel.performLogin { error in
            if error != nil {
                self.logInHud.textLabel.text = "Sign In Failed!"
                self.logInHud.show(in: self.view)
                self.logInHud.dismiss(afterDelay: 2)
                return
            }
            self.dismiss(animated: true)
        }
    }
    @objc fileprivate func handleBackRegister() {
        let vc = RegistrationViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    fileprivate func setupLayout() {
        view.addSubview(verticalStackView)
        view.addSubview(backToRegisterButton)
        verticalStackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 0, right: 50))
        verticalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        backToRegisterButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        
    }
    fileprivate func setupGradientLayer() {
        let topColor = #colorLiteral(red: 1, green: 0, blue: 0.4287317395, alpha: 1)
        let bottomColor = #colorLiteral(red: 1, green: 0, blue: 0.1079617217, alpha: 1)
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0, 1]
        view.layer.addSublayer(gradientLayer)
        gradientLayer.frame = view.bounds
    }

}
