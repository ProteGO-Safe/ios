//
//  PWAViewModel.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 09/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation

protocol PWAViewModelDelegate: class {
    func load(url: URL)
}

final class PWAViewModel: ViewModelType {
    
    private enum Constants {
        #if DEV
        static let url = URL(string: "https://safesafe.thecoders.io")!
        #elseif LIVE
        static let url = URL(string: "https://safesafe.app")!
        #endif
    }
    
    weak var delegate: PWAViewModelDelegate?
    
    func start() {
        
    }
}

// VC Life Cycle
extension PWAViewModel {
    func onViewWillAppear(layoutFinished: Bool) {
        guard layoutFinished else {
            return
        }
        
        delegate?.load(url: Constants.url)
    }
}
