//
//  ViewController.swift
//  Sample_FaceID_TouchID
//
//  Created by Massimiliano Bonafede on 11/11/21.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - Outlets

    @IBOutlet weak var usernameTextFiled: UITextField!
    @IBOutlet weak var passwordTextFiled: UITextField!
    @IBOutlet weak var authenticationButton: UIButton!
    
    // MARK: - Properties

    var authManager: AuthenticationManager?
    var keychainManager: KeychainManager<User> = KeychainManager()
    private var user: User?
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authManager = AuthenticationManager()
        usernameTextFiled.text = ""
        passwordTextFiled.text = ""
        do {
            try keychainManager.retrive { user in
                self.user = user
                self.authenticationButton.isEnabled = true
                self.authManager?.requestAccess { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success:
                        self.success()
                    case .error:
                        break
                    case .unavailable:
                        self.unavailable()
                    }
                }
            }
        } catch {
            print(error)
            authenticationButton.isEnabled = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        authManager = nil
    }
    
    // MARK: - Methods

    private func success() {
        let storybord = UIStoryboard(name: "Main", bundle: .main)
        let controller = storybord.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func error() {
        self.present(AlertManager.errorMessage(), animated: true, completion: nil)
    }
    
    private func unavailable() {
        self.present(AlertManager.unavailableMessage(), animated: true, completion: nil)
    }
    
    // MARK: - Actions

    @IBAction func AuthButtonWasPressed(_ sender: UIButton) {
        guard let user = user, user.username == usernameTextFiled.text, user.password == passwordTextFiled.text else {
            view.endEditing(true)
            error()
            return
        }
        success()
    }
    
    @IBAction func registrationButtonWasPressed(_ sender: UIButton) {
        let storybord = UIStoryboard(name: "Main", bundle: .main)
        let controller = storybord.instantiateViewController(withIdentifier: "RegistrationViewController") as! RegistrationViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func deleteAccountButtonWasPressed(_ sender: UIButton) {
        do {
            try keychainManager.delete()
            usernameTextFiled.text = ""
            passwordTextFiled.text = ""
            viewWillAppear(true)
        } catch {
            print(error)
        }
    }
}

