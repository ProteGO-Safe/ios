//
//  SmsResponse.swift
//  safesafe
//
//  Created by Adam Tokarczyk on 23/06/2021.
//

import Foundation

struct SMSResponse: Codable {
    let number: String
    let text: String
}
