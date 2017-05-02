//
//  Logger.swift
//  Pods
//
//  Created by Diego Marcon on 02/05/2017.
//  Copyright © 2017 Adyen. All rights reserved.
//

import Foundation

class Logger {
    static var debug = false
    static var handler: ((String)->Void)?
    
    class func log(_ line: String, data: Data? = nil) {
        guard debug else { return }
        
        let logline = (data == nil) ? line : line + " " + (data?.hexEncodedString())!
        handler?(logline)
    }
}
