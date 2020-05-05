//
//  Result+Void.swift
//  safesafe Live
//
//  Created by Rafał Małczyński on 22/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation

extension Result where Success == Void {
    
    static var success: Result {
        return .success(())
    }
    
}
