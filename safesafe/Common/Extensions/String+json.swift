//
//  String+json.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 23/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation

extension String {
    
    func jsonDecode<T: Codable>(decoder: JSONDecoder? = nil) -> T? {
        let decoder = decoder ?? JSONDecoder()
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        
        do {
            let model = try decoder.decode(T.self, from: data)
            return model
        } catch {
            Logger.DLog(error.localizedDescription)
            return nil
        }
    }
}
