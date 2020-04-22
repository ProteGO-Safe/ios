//
//  LoginManager.swift
//  safesafe Live
//
//  Created by Rafał Małczyński on 21/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation
import FirebaseAuth

protocol LoginManagerProtocol {
    
    func signIn(_ completion: @escaping (Result<Void, InternalError>) -> Void)
    
}

final class LoginManager: LoginManagerProtocol {
    
    func signIn(_ completion: @escaping (Result<Void, InternalError>) -> Void) {
        guard Auth.auth().currentUser == nil else {
            completion(.success)
            return
        }
        
        Auth.auth().signInAnonymously { authResult, error in
            guard error == nil else {
                completion(.failure(.signInFailed))
                return
            }
            
            completion(.success)
        }
    }
    
}
