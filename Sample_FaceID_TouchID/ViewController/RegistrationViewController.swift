//
//  RegistrationViewController.swift
//  Sample_FaceID_TouchID
//
//  Created by Massimiliano Bonafede on 24/11/21.
//

import UIKit

class RegistrationViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Properties

    var keychainManager: KeychainManager<User> = KeychainManager()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func registrationButtonWasPressed(_ sender: UIButton) {
        let user = User(username: usernameTextField.text ?? "USER", password: passwordTextField.text ?? "PASSWORD")
        do {
            try keychainManager.save(data: user)
            navigationController?.popViewController(animated: true)
        } catch {
            print(error)
        }
        
    }
    
}
