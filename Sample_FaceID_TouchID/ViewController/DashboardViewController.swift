//
//  DashboardViewController.swift
//  Sample_FaceID_TouchID
//
//  Created by Massimiliano Bonafede on 11/11/21.
//

import UIKit

class DashboardViewController: UIViewController {

    // MARK: - Properties

    var keychainManager: KeychainManager<User> = KeychainManager()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
        do {
            try keychainManager.retrive { user in
                self.title = "\(user.username) - \(user.password)"
            }
        } catch {
            print(error)
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
