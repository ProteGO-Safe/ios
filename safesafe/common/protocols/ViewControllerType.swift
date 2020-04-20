//
//  ViewControllerType.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 09/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import UIKit

protocol ViewControllerType: UIViewController {
    associatedtype T: ViewModelType
    var viewModel: T { get }
    func start()
    init(viewModel: T)
}
