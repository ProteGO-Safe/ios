//
//  MockScanner.swift
//  Anna
//
//  Created by Przemysław Lenart on 29/03/2020.
//  Copyright © 2020 GOV. All rights reserved.
//

import Foundation

class MockScanner : Scanner {
    weak var delegate: ScannerDelegate?
    
    init(delegate: ScannerDelegate) {
        self.delegate = delegate
        let timer = Timer.init(timeInterval: 60, repeats: true) { [weak self] timer in
            self?.delegate?.synchronizedTokenData(data: Data([0xff]), rssi: -80)
        }
        RunLoop.current.add(timer, forMode: .common)
    }
}
