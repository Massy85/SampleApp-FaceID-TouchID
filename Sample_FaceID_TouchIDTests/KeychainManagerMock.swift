//
//  KeychainManagerMock.swift
//  Sample_FaceID_TouchIDTests
//
//  Created by Massimiliano Bonafede on 24/11/21.
//

import Foundation
import Security
@testable import Sample_FaceID_TouchID

class KeychainManagerMock<T: Codable>: KeychainAbstraction {
    var account = "keychainManagerAccountTest"
    
    func save(data: T) throws {
        do {
            let encodedData = try JSONEncoder().encode(data)

            let attributes: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: account,
                kSecValueData as String: encodedData,
            ]

            if SecItemAdd(attributes as CFDictionary, nil) == noErr {
                print("User saved successfully in the keychain")
            } else {
                let domain = "Something went wrong trying to save the user in the keychain"
                let error = NSError(domain: domain, code: 01, userInfo: nil)
                throw KeychainError.savingError(error)
            }
        } catch {
            throw KeychainError.savingError(error)
        }

    }

    func retrive(completion: @escaping ((T) -> Void)) throws {
        var item: CFTypeRef?

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
        ]

        if SecItemCopyMatching(query as CFDictionary, &item) == noErr {
            if let existingItem = item as? [String : Any],
                let account = existingItem[kSecAttrAccount as String] as? String,
                account == self.account,
                let data = existingItem[kSecValueData as String] as? Data {

                do {
                    let user = try JSONDecoder().decode(T.self, from: data)
                    completion(user)
                } catch {
                    throw KeychainError.retrivingError(error)
                }
            }
        } else {
            let domain = "Something went wrong trying to find the user in the keychain"
            let error = NSError(domain: domain, code: 02, userInfo: nil)
            throw KeychainError.retrivingError(error)
        }
    }
    
    func update(data: T) throws {
        do {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: account,
            ]
            
            let encodedData = try JSONEncoder().encode(data)
            let attributes: [String: Any] = [kSecValueData as String: encodedData]
            
            if SecItemUpdate(query as CFDictionary, attributes as CFDictionary) == noErr {
                print("Password has changed")
            } else {
                let domain = "Something went wrong trying to update the password"
                let error = NSError(domain: domain, code: 02, userInfo: nil)
                throw KeychainError.updatingError(error)
            }
        } catch {
            throw KeychainError.updatingError(error)
        }
    }
    
    func delete() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
        ]

        if SecItemDelete(query as CFDictionary) == noErr {
            print("User removed successfully from the keychain")
        } else {
            let domain = "Something went wrong trying to remove the user from the keychain"
            let error = NSError(domain: domain, code: 03, userInfo: nil)
            throw KeychainError.deleting(error)
        }
    }
}
