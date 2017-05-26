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
    
    private func parseBarcodeScanData(_ data: Data) -> Barcode? {
        // 0x80000000
        // CodeId AimId SymbolName ScanData
        let format = ">HBB*"
        do {
            let res = try unpack(format, data)
            let scanData = String(data: res[3] as! Data, encoding: .ascii)
            Logger.trace("parseBarcodeScanData: \(res), barcode: \(scanData ?? "")")
            
            let barcode = Barcode()
            barcode.codeId = Barcoder.CodeId(rawValue: res[2] as! UInt8) ?? .Undefined
            barcode.aimId  = Barcoder.AimId(rawValue: res[1] as! UInt8) ?? .Undefined
            barcode.symbolId = Barcoder.SymId(rawValue: res[0] as! UInt16) ?? .Undefined
            barcode.text = String(data: res[3] as! Data, encoding: .ascii) ?? ""
            
            return barcode
        } catch {}
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
            
            let status = Barcoder.Resp(rawValue: res[2] as! UInt32)!
            switch status {
            case .ACK:
                ok = true
            case .NAK:
                ok = false
            case .DATA:
                ok = true
                barcode = parseBarcodeScanData(res[3] as! Data)
            case .STATUS:
                ok = true
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
