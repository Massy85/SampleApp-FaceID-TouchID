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

enum AuthType {
    case none(_ isEnrolled: Bool)
    case touchID
    case faceID
    
    var description: String {
        switch self {
        case .none(_):
            return "None"
        case .touchID:
            return "Touch ID"
        case .faceID:
            return "Face ID"
        }
    }
}

class AuthenticationManager {
    private let context = LAContext()
    private var error: NSError?
    private var type: AuthType = .none(false)
    
    func requestAccess(completion: @escaping ((AuthResult) -> Void)) {
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                switch self.context.biometryType {
                case .none:
                    self.type = .none(true)
                case .touchID:
                    self.type = .touchID
                case .faceID:
                    self.type = .faceID
                @unknown default:
                    self.type = .none(false)
                }
                
                DispatchQueue.main.async {
                    if success {
                        completion(.success)
                    } else {
                        completion(.error)
                    }
                }
            }
        } else {
            parseError(error)
            completion(.unavailable)
        }
    }
    
    private func parseError(_ error: NSError?) {
        guard let error = error else { return }
        let code = LAError.Code(rawValue: error.code)
        
        switch code {
        case .authenticationFailed:
            let reason = "---> Authenticator: Authentication was not successful because user failed to provide valid credentials."
            print(reason)
        case .userCancel:
            let reason = "---> Authenticator: Authentication was canceled by user (e.g. tapped Cancel button)."
            print(reason)
        case .userFallback:
            let reason = "---> Authenticator: Authentication was canceled because the user tapped the fallback button (Enter Password)."
            print(reason)
        case .systemCancel:
            let reason = "---> Authenticator: Authentication was canceled by system (e.g. another application went to foreground)."
            print(reason)
        case .passcodeNotSet:
            let reason = "---> Authenticator: Authentication could not start because passcode is not set on the device."
            print(reason)
        case .appCancel:
            let reason = "---> Authenticator: Authentication was canceled by application (e.g. invalidate was called while authentication was in progress)."
            print(reason)
        case .invalidContext:
            let reason = "---> Authenticator: LAContext passed to this call has been previously invalidated."
            print(reason)
        case .biometryNotAvailable:
            type = .none(false)
            let reason = "---> Authenticator: Authentication could not start because biometry is not available on the device."
            print(reason)
        case .biometryNotEnrolled:
            type = .none(false)
            let reason = "---> Authenticator: Authentication could not start because biometry has no enrolled identities."
            print(reason)
        case .biometryLockout:
            let reason = "---> Authenticator: Authentication was not successful because there were too many failed biometry attempts and biometry is now locked. Passcode is required to unlock biometry, e.g. evaluating LAPolicyDeviceOwnerAuthenticationWithBiometrics will ask for passcode as a prerequisite.."
            print(reason)
        case .notInteractive:
            let reason = "---> Authenticator: Authentication failed because it would require showing UI which has been forbidden by using interactionNotAllowed property."
            print(reason)
        default:
            let reason = "---> Authenticator: Deafualt."
            print(reason)
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
