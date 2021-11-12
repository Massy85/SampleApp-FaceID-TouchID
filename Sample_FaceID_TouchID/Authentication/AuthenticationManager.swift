//
//  AuthenticationManager.swift
//  Sample_FaceID_TouchID
//
//  Created by Massimiliano Bonafede on 11/11/21.
//

import Foundation
import LocalAuthentication
import UIKit

enum AuthResult {
    case success
    case error
    case unavailable
}

class AuthenticationManager {
    let context = LAContext()
    var error: NSError?
    
    func requestAccess(completion: @escaping ((AuthResult) -> Void)) {
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authError in
                
                DispatchQueue.main.async {
                    if success {
                        completion(.success)
                    } else {
                        completion(.error)
                    }
                }
            }
        } else {
            completion(.unavailable)
        }
    }
}


class AlertManager {
    static func errorMessage() -> UIAlertController {
        let controller = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        controller.addAction(action)
        return controller
    }
    
    static func unavailableMessage() -> UIAlertController {
        let controller = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        controller.addAction(action)
        return controller
    }
}
