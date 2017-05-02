//
//  Barcoder.swift
//  Barcoder
//
//  Created by Taras Kalapun on 1/26/17.
//  Copyright © 2017 Adyen. All rights reserved.
//

import Foundation
import ExternalAccessory

@objc
public protocol BarcoderDelegate {
    func barcodeReceived(_ barcode: Barcode)
}

public class Barcoder: NSObject {
    
    public static let sharedInstance = Barcoder()
    public var delegate: BarcoderDelegate?
    
    public var accessoryConnectedHandler: ((EAAccessory)->Void)?
    public var accessoryDisconnectedHandler: ((Void)->Void)?
    public var logHandler: ((String)->Void)?
    
    public var autoConnect = true
    public var autoOpenDevice = true
    public var debug = false
    
    private let interleaved2Of5 = false
    private let accessoryProtocol = "com.verifone.pmr.barcode"
    private var accessoryStreamer: AccessoryStreamer?
    
    var currentCommand: Barcoder.Cmd?
    
    var opened = false
    var started = false
    
    private override init() {
        super.init()
        configureSimbology()
    }
    
    private func configureSimbology() {
        if interleaved2Of5 {
            mSymbology(.EN_EAN13_JAN13, value: 0)
            mSymbology(.EN_INTER2OF5, value: 1)
            
            mSymbology(.SETLEN_ANY_I2OF5, value: 0)
            mSymbology(.I2OF5_CHECK_DIGIT, value: 0)
            mSymbology(.XMIT_M2OF5_CHK_DIGIT, value: 1)
            mSymbology(.CONV_I2OF5_EAN13, value: 0)
        } else {
            mSymbology(.EN_EAN13_JAN13, value: 1)
            mSymbology(.EN_INTER2OF5, value: 0)
        }
    }
    
    public func run() {
        let accessoryStreamer = AccessoryStreamer(accessoryProtocol: self.accessoryProtocol, autoconnect: self.autoConnect)
        accessoryStreamer.debug = self.debug
        
        accessoryStreamer.logHandler = { line in
            self.log(line)
        }
        
        log("running")
        
        accessoryStreamer.onDataReceived = { data in
            self.parseIncomingData(data)
        }
        
        
        accessoryStreamer.onConnected = { accessory in
            self.log("onConnected \(accessory.description)")
            if let handler = self.accessoryConnectedHandler {
                handler(accessory)
            }
            if self.autoOpenDevice {
                self.openDevice()
            }
        }
        
        accessoryStreamer.onDisconnected = {
            self.log("onDisconnected")
            if let handler = self.accessoryDisconnectedHandler {
                handler()
            }
        }
        
        self.accessoryStreamer = accessoryStreamer
        
        accessoryStreamer.start()
    }
    
    deinit {
        self.accessoryStreamer?.disconnect()
    }
    
    // should be call on coming from BG
    public func reconnect() {
        log("reconnect")
        self.accessoryStreamer?.openSession()
    }
    
    
    // Should be called on going to BG
    public func disconnect() {
        log("disconnect")
        self.accessoryStreamer?.closeSession()
    }
    
    func log(_ line: String) {
        if !self.debug { return }
        if let handler = self.logHandler {
            handler(line)
        }
        //delegate?.barcodelog(AdyenBarcoder: self, log: line)
    }
    
    public func connectToAccessory(_ accessory: EAAccessory) {
        self.accessoryStreamer?.connect(accessory)
    }
    
    func disconnectFromAccessory() {
        self.accessoryStreamer?.disconnect()
    }
    
    /**
     * Initializes the barcode device.
     */
    
    public func openDevice() {
        sendCommand(.BAR_DEV_OPEN)
    }
    
    /**
     * Terminates stream connection to Barcode
     *
     * This method will shut down the connection to the Barcode stream. An initDevice() will need to be executed again to engage a new stream connection.
     */
    public func closeDevice() {
        sendCommand(.BAR_DEV_CLOSE)
    }
    
    /**
     * Powers up the scanner engine.
     *
     * Executing startScan will allow barcode scanning to commence.
     */
    public func startScan() {
        sendCommand(.START_SCAN)
    }
    
    /**
     * Powers down the scanner engine.
     *
     * Executing abortScan will remove power from the scanning engine deactivating barcode scanning.
     */
    public func stopScan() {
        sendCommand(.STOP_SCAN)
    }
    
    func configureDefaults() {
        sendCommand(.EN_CONTINUOUS_RD, parameter: GenPid.CONTINUOUS_READ.rawValue, false)
        
        //level
        sendCommand(.SET_TRIG_MODE, parameter: GenPid.SET_TRIG_MODE.rawValue, 1)
        
        //beep
        sendCommand(.AUTO_BEEP_CONFIG, parameter: GenPid.AUTO_BEEP_MODE.rawValue, 1)
    }

    public func startSoftScan() {
        // Stop recognizing hardware trigger
        stopScan()
        
        // configure soft trigger
        sendCommand(.SET_TRIG_MODE, parameter: GenPid.SET_TRIG_MODE.rawValue, 2)
        
        // Start the soft scan
        startScan()
    }
    
    public func stopSoftScan() {
        stopScan()
        sendCommand(.SET_TRIG_MODE, parameter: GenPid.SET_TRIG_MODE.rawValue, 1)
        startScan()
    }
    
    public func sendCommand(_ cmd: Barcoder.Cmd) {
        log("sendCommand \(cmd.rawValue)")
        self.currentCommand = cmd
        self.accessoryStreamer?.send(packCommand(cmd, data: nil))
    }
    
    public func sendCommand<T>(_ cmd: Barcoder.Cmd, parameter: UInt8, _ value: T) {
        log("sendCommand \(cmd.rawValue) \(parameter) \(value)")
        self.currentCommand = cmd
        self.accessoryStreamer?.send(packCommand(cmd, data: packParam(parameter, value)))
    }
    
    public func mSymbology(_ parameter: Barcoder.SymPid, value: UInt8) {
        sendCommand(.SYMBOLOGY, parameter: parameter.rawValue, value)
    }
    
    func mSymbology(_ parameter: Barcoder.SymPid, data: Data) {
        sendCommand(.SYMBOLOGY, parameter: parameter.rawValue, data)
    }
    
    func parseIncomingData(_ data: Data) {
        let res = parseResponse(data)
        log("res: \(res.result), data: \(res.data?.hexEncodedString() ?? "" )")
        
        if self.currentCommand == .BAR_DEV_OPEN {
            self.opened = res.result
            
            if self.opened {
                configureDefaults()
            }
            
            self.startScan()
        }
        
        if self.currentCommand == .START_SCAN {
            self.started = res.result
        }
    }
    
    func packCommand(_ cmd: Barcoder.Cmd, data: Data?) -> Data {
        
        log("cmd: \(cmd.rawValue), value: \(data?.hexEncodedString() ?? "")")
        
        var dataCmd : Data
        if data == nil {
            dataCmd = pack(">HBB", [4, 1, cmd.rawValue])
        } else {
            dataCmd = pack(">HBB*", [4 + (data?.count)!, 1, cmd.rawValue, data!])
        }
        
        var finalData = Data()
        finalData.append(pack(">II", [dataCmd.count + 8, 1]))
        finalData.append(dataCmd)
        return finalData
    }
    
    func packParam<T>(_ cmd: UInt8, _ value: T) -> Data {
        switch value {
        case is Bool:
            return pack(">BB?", [3, cmd, value])
        case is Int:
            return pack(">BBB", [3, cmd, value])
        case is UInt8:
            return pack(">BBB", [3, cmd, value])
        case is UInt16:
            return pack(">BBH", [4, cmd, value])
        case is [UInt8]:
            let bytes = value as! [UInt8]
            return pack(">BB*", [2 + bytes.count, cmd, Data(bytes: bytes)])
        default:
            return Data()
        }
    }
    
    func parseBarcodeScanData(_ data: Data) -> Barcode? {
        // 0x80000000
        // CodeId AimId SymbolName ScanData
        let format = ">HBB*"
        do {
            let res = try unpack(format, data)
            let scanData = String(data: res[3] as! Data, encoding: .ascii)
            log("parseBarcodeScanData: \(res), barcode: \(scanData ?? "")")
            
            let barcode = Barcode()
            barcode.codeId = CodeId(rawValue: res[2] as! UInt8) ?? .Undefined
            barcode.aimId  = AimId(rawValue: res[1] as! UInt8) ?? .Undefined
            barcode.symbolId = SymId(rawValue: res[0] as! UInt16) ?? .Undefined
            barcode.text = String(data: res[3] as! Data, encoding: .ascii) ?? ""
            
            log("Barcode: \(barcode)")
            self.delegate?.barcodeReceived(barcode)
            return barcode
        } catch {}
        return nil
    }
    
    func parseResponse(_ data: Data) -> (result: Bool, data: Data?) {
        var ok = false
        var resData:Data?
        
        do {
            var format = ">III"  // True or False
            if (data.count == 13) {
                format = ">IIIB" // with Reason
            }
            if (data.count > 13) {
                format = ">III*" // with Data
            }
            
            let res = try unpack(format, data)
            log("res: \(res)")
            
            let status = Barcoder.Resp(rawValue: res[2] as! UInt32)!
            switch status {
            case .ACK:
                ok = true
            case .NAK:
                ok = false
            case .DATA:
                ok = true
                _ = parseBarcodeScanData(res[3] as! Data)
            case .STATUS:
                ok = true
            }
            
            if res.count == 4 {
                if data.count == 13 {
                    log("reason: \(res[3])")
                } else {
                    resData = res[3] as? Data
                    log("data: \(resData?.hexEncodedString() ?? "")")
                }
            }

        } catch {
            log("Can't parse data: \(data.hexEncodedString())")
            ok = false
        }
        return (ok, resData)
    }
}

