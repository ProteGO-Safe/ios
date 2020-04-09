//
//  ViewModelType.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 09/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import Foundation

protocol ViewModelType {
    // Initialize viewmodel here, it's called on View Controller init()
    func start()
    
    // View Controller Life Cycle Events
    func onViewDidLoad(setupFinished: Bool)
    func onViewWillAppear(layoutFinished: Bool)
    func onViewDidAppear()
    func onViewWillDisappear()
    func onViewDidDisappear()
}

extension ViewModelType {
    func onViewDidLoad(setupFinished: Bool) {}
    func onViewWillAppear(layoutFinished: Bool) {}
    func onViewDidAppear() {}
    func onViewWillDisappear() {}
    func onViewDidDisappear() {}
}
