//
//  PhoneManager.swift
//  safesafe Live
//
//  Created by Rafał Małczyński on 20/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation
import FirebaseAuth

protocol PhoneManagerProtocol {
    
    func verifyPhoneNumber(_ number: String, completion: @escaping (Result<String, InternalError>) -> Void)
    func verifyOTP(_ otp: String, withVerificationID id: String, completion: @escaping (Result<Void, InternalError>) -> Void)
    
}

final class PhoneManager: PhoneManagerProtocol {
    
    /**
     Starts phone number verification process.
     
     Returns following errors:
     * `InternalError.phoneVerificationFailed`
     
     - Parameters:
        - number: User's phone number. Parameter is expected to be verified before being passed to the method.
        - completion: Results in **verficationID** on success
     */
    func verifyPhoneNumber(_ number: String, completion: @escaping (Result<String, InternalError>) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(number, uiDelegate: nil) { verificationID, error in
            guard
                error == nil,
                let verificationID = verificationID
            else {
                completion(.failure(.phoneVerificationFailed))
                return
            }
            
            completion(.success(verificationID))
        }
    }
    
    /**
     Completes phone number verification process.
     
     Returns following errors:
     * `InternalError.otpVerificationFailed`
     
     - Parameters:
        - otp: OTP code received from Firebase. Parameter is expected to be verified before being passed to the method.
        - code: User's verification code provided by `verifyPhoneNumber(_: completion:)` method
        - completion: Results in **Void** on success
     */
    func verifyOTP(_ otp: String, withVerificationID id: String, completion: @escaping (Result<Void, InternalError>) -> Void) {
        let credentials = PhoneAuthProvider.provider().credential(
            withVerificationID: id,
            verificationCode: otp
        )
        
        Auth.auth().signIn(with: credentials) { _, error in // I omit `AuthDataResult` here. Do we need it?
            guard error == nil else {
                completion(.failure(.otpVerificationFailed))
                return
            }
            
            // Guys from OpenTrace were doing an additional handshake here. Check if we need any additional actions (by now we are  succesfully registered)
            completion(.success(()))
        }
    }
    
}
