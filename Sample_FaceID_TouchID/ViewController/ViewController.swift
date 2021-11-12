//
//  ViewController.swift
//  Sample_FaceID_TouchID
//
//  Created by Massimiliano Bonafede on 11/11/21.
//

import UIKit

class ViewController: UIViewController {
    
    var authManager: AuthenticationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authManager = AuthenticationManager()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        authManager = nil
    }
    
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
    
    @IBAction func AuthButtonWasPressed(_ sender: UIButton) {
        authManager?.requestAccess { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.success()
            case .error:
                self.error()
            case .unavailable:
                self.unavailable()
            }
        }
    }
}

