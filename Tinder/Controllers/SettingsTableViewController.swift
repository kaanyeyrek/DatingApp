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
import FirebaseStorage

class CustomImagePickerController: UIImagePickerController {
    var imageButton: UIButton?
}
// Custom Header Label
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
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItems()
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        fetchCurrentUser()
    }
    // Navigation Settings
    fileprivate func setupNavigationItems() {
        navigationItem.title = "Profile Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave)),
                                              UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogOut))
        ]
    }
    //MARK: - Objc Target Methods
    @objc fileprivate func handleMinAgeChange(slider: UISlider) {
        let indexPath = IndexPath(row: 0, section: 5)
        let ageRangeCell = tableView.cellForRow(at: indexPath) as! AgeRangeCell
        ageRangeCell.minLabel.text = "Min: \(Int(slider.value))"
        self.user?.minSeekingAge = Int(slider.value)
    }
    @objc fileprivate func handleMaxAgeChange(slider: UISlider) {
        let indexPath = IndexPath(row: 0, section: 5)
        let ageRangeCell = tableView.cellForRow(at: indexPath) as! AgeRangeCell
        ageRangeCell.maxLabel.text = "Max: \(Int(slider.value))"
        self.user?.maxSeekingAge = Int(slider.value)
    }
    
    @objc fileprivate func handleNameChange(textfield: UITextField) {
        self.user?.name = textfield.text
    }
    @objc fileprivate func handleProfessionChange(textfield: UITextField) {
        self.user?.profession = textfield.text
    }
    @objc fileprivate func handleAgeChange(textfield: UITextField) {
        self.user?.age = Int(textfield.text ?? "")
    }
    // Fetch data for current user
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
        if let url = user?.imageURL1, let url = URL(string: url) {
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: .none) { image, _, _, _, _, _ in
                self.image1Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        if let url = user?.imageURL2, let url = URL(string: url) {
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: .none) { image, _, _, _, _, _ in
                self.image2Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal )
            }
            
        }
        if let url = user?.imageURL3, let url = URL(string: url) {
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: .none) { image, _, _, _, _, _ in
                self.image3Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal )
            }
        }
    }
    @objc fileprivate func handleCancel() {
        dismiss(animated: true)
    }
    // Private Picker
    @objc fileprivate func handleSelectPhoto(with button: UIButton) {
        let imagePicker = CustomImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.imageButton = button
        present(imagePicker, animated: true)
    }
    @objc fileprivate func handleLogOut() {
        do {
            try Auth.auth().signOut()
        } catch {
        }
        dismiss(animated: true)
        
    }
    // Firebase Save Data
    @objc fileprivate func handleSave() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let docData = ["fullname": user?.name ?? "",
                       "uid": uid,
                       "imageURL1": user?.imageURL1 ?? "",
                       "imageURL2": user?.imageURL2 ?? "",
                       "imageURL3": user?.imageURL3 ?? "",
                       "age": user?.age ?? -1,
                       "profession": user?.profession ?? "",
                       "minSeekingAge": user?.minSeekingAge ?? -1,
                       "maxSeekingAge": user?.maxSeekingAge ?? -1
        ] as [String : Any]
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Saving Settings"
        hud.show(in: view)
        hud.dismiss(afterDelay: 2)
        self.database.child("Users").child(uid).setValue(docData) { error, _ in
            if error != nil {
                print("failed")
                return
            }
            hud.dismiss()
            print("successfully")
        }
    }
    //MARK: - TableView Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SettingsCell(style: .default, reuseIdentifier: nil)
        if indexPath.section == 5 {
            let ageRangeCell = AgeRangeCell(style: .default, reuseIdentifier: nil)
            ageRangeCell.minSlider.addTarget(self, action: #selector(handleMinAgeChange), for: .valueChanged)
            ageRangeCell.maxSlider.addTarget(self, action: #selector(handleMaxAgeChange), for: .valueChanged)
            ageRangeCell.contentView.isUserInteractionEnabled = false
            ageRangeCell.minLabel.text = "Min \(user?.minSeekingAge ?? -1)"
            ageRangeCell.maxLabel.text = "Max \(user?.maxSeekingAge ?? -1)"
            return ageRangeCell
        }
        switch indexPath.section {
        case 1:
            cell.textField.placeholder = "Enter Name"
            cell.textField.text = user?.name
            cell.textField.addTarget(self, action: #selector(handleNameChange), for: .editingChanged)
        case 2:
            cell.textField.placeholder = "Enter Profession"
            cell.textField.text = user?.profession
            cell.textField.addTarget(self, action: #selector(handleProfessionChange), for: .editingChanged)
        case 3:
            cell.textField.placeholder = "Enter Age"
            cell.textField.addTarget(self, action: #selector(handleAgeChange), for: .editingChanged)
            if let age = user?.age {
                cell.textField.text = String(age)
            }
        default:
            cell.textField.placeholder = "Enter Bio"
        }
        cell.contentView.isUserInteractionEnabled = false
        return cell
    }
    // TableView Header
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
        case 4:
            headerLabel.text = "Bio"
        default:
            headerLabel.text = "Seeking Age Range"
        }
        headerLabel.font = UIFont.boldSystemFont(ofSize: 16)
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
        let imageButton = (picker as? CustomImagePickerController)?.imageButton
            imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        let fileName = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images\(fileName)")
        guard let uploadData = selectedImage?.jpegData(compressionQuality: 0.75) else { return }
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Uploading image..."
        hud.show(in: view)
        ref.putData(uploadData, metadata: nil) { (nil, error) in
            if error != nil {
                print("failed")
                return
            }
            ref.downloadURL { (url, error) in
                hud.dismiss()
                if error != nil {
                    print("failed")
                }
                if imageButton == self.image1Button {
                    self.user?.imageURL1 = url?.absoluteString
                } else if imageButton == self.image2Button {
                    self.user?.imageURL2 = url?.absoluteString
                } else {
                    self.user?.imageURL3 = url?.absoluteString
                    
                }
            }
            
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
