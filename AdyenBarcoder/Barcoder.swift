//
//  Barcoder.swift
//  Barcoder
//
//  Created by Taras Kalapun on 1/26/17.
//  Copyright © 2017 Adyen. All rights reserved.
//

import Foundation
import ExternalAccessory

private enum ScanMode: Int {
    case Hard = 1
    case Soft = 2
}

public class Barcoder: NSObject {
    private var autoConnect = true
    private var autoOpenDevice = true
    private let interleaved2Of5 = false
    private let accessoryProtocol = "com.verifone.pmr.barcode"
    private var accessoryStreamer: AccessoryStreamer?
    private var currentCommand: Barcoder.Cmd?
    private var accessoryConnectionId = -1
    
    public static let sharedInstance = Barcoder()
    
    public var scanHandler: ((Barcode)->Void)?
    
    public static var logHandler: ((String)->Void)? {
        didSet {
            Logger.handler = logHandler
        }
    }
    
    public static var debug = false {
        didSet {
            Logger.debug = debug
        }
    }
    
    private override init() {
        super.init()
        configureSimbology()
        registerForNotifications()
        run()
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
    
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(forName: .UIApplicationDidEnterBackground, object: nil, queue: .main) { [weak self] (notification) in
            self?.disconnect()
        }

        NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: .main) { [weak self] (notification) in
            self?.reconnect()
        }
    }
    
    private func run() {
        let accessoryStreamer = AccessoryStreamer(accessoryProtocol: accessoryProtocol, autoconnect: autoConnect)

        Logger.log("running")
        
        accessoryStreamer.onDataReceived = { [weak self] data in
            self?.parseIncomingData(data)
        }
        
        accessoryStreamer.onAccessoryConnected = { [weak self] accessory in
            if accessory.connectionID != self?.accessoryConnectionId {
                self?.accessoryConnectionId = accessory.connectionID
                self?.openDevice()
            }
        }
        
        self.accessoryStreamer = accessoryStreamer
        
        accessoryStreamer.start()
    }
    
    deinit {
        accessoryStreamer?.disconnect()
    }
    
    private func reconnect() {
        Logger.log("reconnect")
        accessoryStreamer?.openSession()
    }

    private func disconnect() {
        Logger.log("disconnect")
        accessoryStreamer?.closeSession()
    }
    
    private func openDevice() {
        sendCommand(.BAR_DEV_OPEN)
    }
    
    private func closeDevice() {
        sendCommand(.BAR_DEV_CLOSE)
    }
    
    private func configureDefaults() {
        sendCommand(.EN_CONTINUOUS_RD, parameter: GenPid.CONTINUOUS_READ.rawValue, false)
        sendCommand(.AUTO_BEEP_CONFIG, parameter: GenPid.AUTO_BEEP_MODE.rawValue, 1) //beep
    }

    public func startSoftScan() {
        startScan(mode: .Soft)
    }
    
    public func stopSoftScan() {
        startScan(mode: .Hard)
    }
    
    private func startScan(mode: ScanMode) {
        sendCommand(.STOP_SCAN)
        sendCommand(.SET_TRIG_MODE, parameter: GenPid.SET_TRIG_MODE.rawValue, mode.rawValue)
        sendCommand(.START_SCAN)
    }
    
    public func sendCommand(_ cmd: Barcoder.Cmd) {
        Logger.log("sendCommand \(cmd.rawValue)")
        currentCommand = cmd
        accessoryStreamer?.send(packCommand(cmd, data: nil))
    }
    
    public func sendCommand<T>(_ cmd: Barcoder.Cmd, parameter: UInt8, _ value: T) {
        Logger.log("sendCommand \(cmd.rawValue) \(parameter) \(value)")
        currentCommand = cmd
        accessoryStreamer?.send(packCommand(cmd, data: packParam(parameter, value)))
    }
    
    private func mSymbology(_ parameter: Barcoder.SymPid, value: UInt8) {
        sendCommand(.SYMBOLOGY, parameter: parameter.rawValue, value)
    }
    
    private func mSymbology(_ parameter: Barcoder.SymPid, data: Data) {
        sendCommand(.SYMBOLOGY, parameter: parameter.rawValue, data)
    }
    
    private func parseIncomingData(_ data: Data) {
        let res = Parser().parseResponse(data)
        Logger.log("res: \(res.result), data: \(res.data?.hexEncodedString() ?? "" )")
        
        if let barcode = res.barcode {
            self.scanHandler?(barcode)
        }
        
        if currentCommand == .BAR_DEV_OPEN {
            let opened = res.result
            
            if opened {
                configureDefaults()
            }
            
            startScan(mode: .Hard)
        }
    }
    
    private func packCommand(_ cmd: Barcoder.Cmd, data: Data?) -> Data {
        
        Logger.log("cmd: \(cmd.rawValue), value: \(data?.hexEncodedString() ?? "")")
        
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
    
    private func packParam<T>(_ cmd: UInt8, _ value: T) -> Data {
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
}

