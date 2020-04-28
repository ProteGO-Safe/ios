//
//  EncounterMessageManager+AuthSetup.swift
//  safesafe

import Foundation
import FirebaseFunctions

extension EncounterMessageManager {
    
    func authSetup() {
        LoginManager().signIn { result in
            switch result {
            case .success:
                EncounterMessageManager.shared.functions = Functions.functions(region: FirebaseConfig.functionsRegion)
                EncounterMessageManager.shared.setup()
                
            case .failure(let error):
                console(error)
            }
        }
    }
    
}
