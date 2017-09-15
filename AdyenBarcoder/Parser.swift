//
//  Parser.swift
//  Pods
//
//  Created by Diego Marcon on 02/05/2017.
//  Copyright © 2017 Adyen. All rights reserved.
//

import Foundation

typealias ParserResponse = (result: Bool, data: Data?, barcode: Barcode?)

class Parser {
    
    private func parseBarcodeScanData(_ data: Data?) -> Barcode? {
        guard let data = data else {
            return nil
        }
        
        let format = ">HBB*"
        
        let res = try? unpack(format, data)
        
        if let res = res, let responseData = res[3] as? Data {
            let scanData = String(data: responseData, encoding: .ascii)
            Logger.trace("parseBarcodeScanData: \(res), barcode: \(scanData ?? "")")
            
            if let textData = res[3] as? Data {
                let barcode = Barcode()
                
                barcode.codeId = Barcoder.CodeId(rawValue: res[2] as? UInt8 ?? 0) ?? .Undefined
                barcode.aimId  = Barcoder.AimId(rawValue: res[1] as? UInt8 ?? 0) ?? .Undefined
                barcode.symbolId = Barcoder.SymId(rawValue: res[0] as? UInt16 ?? 0) ?? .Undefined
                barcode.text = String(data: textData, encoding: .ascii) ?? ""
                
                return barcode
            }
        }
        return nil
    }
    
    func parseResponse(_ data: Data) -> (result: Bool, data: Data?, barcode: Barcode?) {
        var ok = false
        var resData: Data?
        var barcode: Barcode?
        
        do {
            var format = ">III"  // True or False
            if (data.count == 13) {
                format = ">IIIB" // with Reason
            }
            if (data.count > 13) {
                format = ">III*" // with Data
            }
            
            let res = try unpack(format, data)
            Logger.trace("res: \(res)")
            
            if let rawValue = res[2] as? UInt32, let status = Barcoder.Resp(rawValue: rawValue) {
                switch status {
                case .ACK, .STATUS:
                    ok = true
                case .NAK:
                    ok = false
                case .DATA:
                    barcode = parseBarcodeScanData(res[3] as? Data)
                    ok = barcode != nil
                }
            } else {
                Logger.error("Can't parse data: \(data.hexEncodedString())")
                ok = false
            }
            
            if res.count == 4 {
                if data.count == 13 {
                    Logger.trace("reason: \(res[3])")
                } else {
                    resData = res[3] as? Data
                    Logger.trace("data: \(resData?.hexEncodedString() ?? "")")
                }
            }
            
        } catch {
            Logger.error("Can't parse data: \(data.hexEncodedString())")
            ok = false
        }
        return (ok, resData, barcode)
    }
    
}
