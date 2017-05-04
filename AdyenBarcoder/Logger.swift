//
//  Logger.swift
//  Pods
//
//  Created by Diego Marcon on 02/05/2017.
//  Copyright © 2017 Adyen. All rights reserved.
//

import Foundation

@objc public enum LogLevel: Int {
    case none, error, info, debug, trace
}

class Logger {
    static var level: LogLevel = .info
    static var handler: ((String)->Void)?
    
    class func error(_ line: String) {
        log(.error, line: line)
    }
    
    class func info(_ line: String) {
        log(.info, line: line)
    }
    
    class func debug(_ line: String) {
        log(.debug, line: line)
    }
    
    class func trace(_ line: String, data: Data? = nil) {
        log(.trace, line: line, data: data)
    }
    
    private class func log(_ messageLevel: LogLevel, line: String, data: Data? = nil) {
        guard messageLevel.rawValue <= level.rawValue else { return }
        
        let logline = (data == nil) ? line : line + " " + (data?.hexEncodedString())!
        handler?(logline)
    }
}
