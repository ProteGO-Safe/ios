//
//  ViewController.swift
//  safesafe
//
//  Created by Lukasz szyszkowski on 09/04/2020.
//  Copyright © 2020 Lukasz szyszkowski. All rights reserved.
//

import UIKit

class ViewController<T: ViewModelType>: UIViewController, ViewControllerType {
    var viewModel: T
    required init(viewModel: T) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        start()
        viewModel.start()
    }
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.onViewDidLoad(setupFinished: false)
        setup()
        viewModel.onViewDidLoad(setupFinished: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.onViewWillAppear(layoutFinished: false)
        layout()
        viewModel.onViewWillAppear(layoutFinished: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.onViewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.onViewWillDisappear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewModel.onViewDidDisappear()
    }
    
    func start() {
        fatalError("This method is called after super.init(nibName: nil, bundle: nil) and before viewModel.start(). Please use it for vc initialising job like assignig delegate for view model etc")
    }
    
    func setup() {
        fatalError("This method is called when views are loaded and available. Please use it for setup your views")
    }
    
    func layout() {
        fatalError("This method is called after setup() method. Please use it arrange your views with constraints, frames etc")
    }
    
    func add(subview: UIView, translatesAutoresizingMask: Bool = false) {
        subview.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMask
        view.addSubview(subview)
    }
}
