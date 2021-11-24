//
//  KeychainManager.swift
//  Sample_FaceID_TouchID
//
//  Created by Massimiliano Bonafede on 23/11/21.
//

import Foundation
import Security

struct User: Codable, Equatable {
    let username: String
    let password: String
    
    static func ==(lhs: User, rhs: User) -> Bool {
        guard lhs.username == rhs.username else { return false }
        guard lhs.password == rhs.password else { return false }
        return true
    }
}

enum KeychainError: Error {
    case savingError(Error)
    case retrivingError(Error)
    case updatingError(Error)
    case deleting(Error)
}

protocol KeychainAbstraction: AnyObject {
    associatedtype DataType: Codable
    var account: String { get }
    func save(data: DataType) throws
    func retrive(completion: @escaping ((DataType) -> Void)) throws
    func update(data: DataType) throws
    func delete() throws
}

class KeychainManager<T: Codable>: KeychainAbstraction {

    var account = Bundle.main.bundleIdentifier ?? "keychainManagerAccount"
        
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

