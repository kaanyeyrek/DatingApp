//
//  SettingsTableViewController.swift
//  Tinder
//
//  Created by Kaan Yeyrek on 11/25/22.
//

import UIKit
import JGProgressHUD
import SDWebImage
import Firebase
import FirebaseDatabase
import FirebaseAuth

class CustomImagePickerController: UIImagePickerController {
    var imageButton: UIButton?
}

class HeaderLabel: UILabel {
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.insetBy(dx: 16, dy: 0))
    }
}

class SettingsTableViewController: UITableViewController {
    lazy var image1Button = createButton(selector: #selector(handleSelectPhoto))
    lazy var image2Button = createButton(selector: #selector(handleSelectPhoto))
    lazy var image3Button = createButton(selector: #selector(handleSelectPhoto))
    var database = Database.database().reference()
    var user: User?

    func createButton(selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.backgroundColor = .white
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }
    lazy var header: UIView = {
        let header = UIView()
        header.addSubview(image1Button)
        let padding: CGFloat = 16
        image1Button.anchor(top: header.topAnchor, leading: header.leadingAnchor, bottom: header.bottomAnchor, trailing: nil, padding: .init(top: padding, left: padding, bottom: padding, right: 0))
        image1Button.widthAnchor.constraint(equalTo: header.widthAnchor, multiplier: 0.45).isActive = true
        let stackView = UIStackView(arrangedSubviews: [image2Button, image3Button])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = padding
        header.addSubview(stackView)
        stackView.anchor(top: header.topAnchor, leading: image1Button.trailingAnchor, bottom: header.bottomAnchor, trailing: header.trailingAnchor, padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        return header
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItems()
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        fetchCurrentUser()
    }
    @objc fileprivate func fetchCurrentUser() {
        let data = self.database.child("Users")
        data.getData { error, snapshot in
            guard error == nil else {
                print("error")
                return
            }
            if let value = snapshot.value as? [String: Any] {
                value.forEach({ documentSnapshot in
                    let userDictionary = documentSnapshot.value
                    self.user = User(dictionary: userDictionary as! [String: Any])
                    self.loadUserPhoto()
                    self.tableView.reloadData()

                })
            }
        }
    }
    fileprivate func loadUserPhoto() {
        guard let url = user?.imageURL1, let url = URL(string: url) else { return }
        SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: .none) { image, _, _, _, _, _ in
            self.image1Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal )
        }
    }
    
    @objc fileprivate func handleCancel() {
        dismiss(animated: true)
    }
    @objc fileprivate func handleSelectPhoto(with button: UIButton) {
        let imagePicker = CustomImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.imageButton = button
        present(imagePicker, animated: true)
    }
    fileprivate func setupNavigationItems() {
        navigationItem.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave)),
                                              UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogOut))
        ]
    }
    @objc fileprivate func handleLogOut() {
        
        
    }
    @objc fileprivate func handleSave() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let docData = ["fullname": user?.name ?? "", "uid": uid, "imageURL1": user?.imageURL1 ?? "", "age": 60, "profession": "Bank Robber"] as [String : Any]
        self.database.child("Users").child(uid).setValue(docData) { error, _ in
            if error != nil {
                print("failed")
                return
            }
            print("successfully")
        }
    
    }
    //MARK: - TableView Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SettingsCell(style: .default, reuseIdentifier: nil)
        switch indexPath.section {
        case 1:
            cell.textField.placeholder = "Enter Name"
            cell.textField.text = user?.name
        case 2:
            cell.textField.placeholder = "Enter Profession"
            cell.textField.text = user?.profession
        case 3:
            cell.textField.placeholder = "Enter Age"
            if let age = user?.age {
                cell.textField.text = String(age)
            }
        default:
            cell.textField.placeholder = "Enter Bio"
        }
        cell.contentView.isUserInteractionEnabled = false
        return cell
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return header
        }
        let headerLabel = HeaderLabel()
        switch section {
        case 1:
            headerLabel.text = "Name"
        case 2:
            headerLabel.text = "Profession"
        case 3:
            headerLabel.text = "Age"
        default:
            headerLabel.text = "Bio"
        }
        return headerLabel
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 300
        }
        return 40
    }
}
    // MARK: - Picker Delegate Methods
extension SettingsTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        dismiss(animated: true)
        let selectedImage = info[.originalImage] as? UIImage
        (picker as? CustomImagePickerController)?.imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
