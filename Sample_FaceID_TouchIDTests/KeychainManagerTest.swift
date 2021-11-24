//
//  KeychainManagerTest.swift
//  Sample_FaceID_TouchIDTests
//
//  Created by Massimiliano Bonafede on 24/11/21.
//

import XCTest
@testable import Sample_FaceID_TouchID

class KeychainManagerTest: XCTestCase {
 
    func test_KeyChainManager_SaveWithNoError() throws {
        let sut = TestingKeychainWithOrder()
        
        do {
            try sut.initTesting()
        } catch {
            XCTFail()
        }
    }
}

class TestingKeychainWithOrder {
    private var keychainManager: KeychainManagerMock<User> = KeychainManagerMock()
    private let user = User(username: "Username", password: "Password")
    private let newUser = User(username: "NewUsername", password: "NewPassword")
    private let group = DispatchGroup()
    
    func initTesting() throws {
        try keychainManager.save(data: user)
        group.enter()
        try keychainManager.retrive { _ in self.group.leave() }
        try keychainManager.update(data: newUser)
        try keychainManager.delete()
    }
}
