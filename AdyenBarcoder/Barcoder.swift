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
    case hard = 1
    case soft = 2
}

@objc public enum DeviceStatus: Int {
    case unknown, connecting, connected
    
    var description: String {
        get {
            switch self {
            case .connecting: return "Connecting"
            case .connected: return "Connected"
            case .unknown: return "Unknown"
            }
        }
    }
}

@objc public protocol BarcoderDelegate {
    func didScanBarcode(barcode: Barcode)
    @objc optional func didReceiveNewLogMessage(_ message: String)
    @objc optional func didChangeDeviceStatus(_ status: DeviceStatus)
}

public class Barcoder: NSObject {
    private let interleaved2Of5 = false
    private let accessoryProtocol = "com.verifone.pmr.barcode"
    private var accessoryStreamer: AccessoryStreamer?
    private var currentCommand: Barcoder.Cmd?
    private var accessoryConnectionId = -1
    private var isInitialized = false
    
    public static let instance = Barcoder()
    
    public var delegate: BarcoderDelegate? {
        didSet {
            if !isInitialized {
                setup()
                isInitialized = true
            }
        }
    }
    
    public var deviceStatus: DeviceStatus {
        return accessoryStreamer?.deviceStatus ?? .unknown
    }
    
    public var logLevel: LogLevel = .info {
        didSet {
            Logger.level = logLevel
        }
    }
    
    private override init() {
        super.init()
        Logger.handler = { [weak self] message in
            self?.delegate?.didReceiveNewLogMessage?(message)
        }
    }
    
    private func setup() {
        Logger.info("Initializing Barcoder")
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
        let accessoryStreamer = AccessoryStreamer(accessoryProtocol: accessoryProtocol)

        accessoryStreamer.onDataReceived = { [weak self] data in
            self?.parseIncomingData(data)
        }
        
        accessoryStreamer.onAccessoryConnected = { [weak self] accessory in
            if accessory.connectionID != self?.accessoryConnectionId {
                self?.accessoryConnectionId = accessory.connectionID
                self?.openDevice()
            }
        }
        
        accessoryStreamer.onDeviceStatusChange = { [weak self] status in
            Logger.info("Device status changed: \(status.description)")
            self?.delegate?.didChangeDeviceStatus?(status)
        }
        
        self.accessoryStreamer = accessoryStreamer
        
        accessoryStreamer.start()
    }
    
    deinit {
        accessoryStreamer?.disconnect()
    }
    
    private func reconnect() {
        Logger.info("Application will enter foreground. Reconnecting Barcoder")
        accessoryStreamer?.openSession()
    }

    private func disconnect() {
        Logger.info("Application will enter background. Disconnecting Barcoder")
        accessoryStreamer?.closeSession()
    }
    
    private func openDevice() {
        Logger.debug("Will send open device command")
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
        Logger.debug("Starting soft scan")
        startScan(mode: .soft)
    }
    
    public func stopSoftScan() {
        startScan(mode: .hard)
        Logger.debug("Stopped soft scan")
    }
    
    private func startScan(mode: ScanMode) {
        sendCommand(.STOP_SCAN)
        sendCommand(.SET_TRIG_MODE, parameter: GenPid.SET_TRIG_MODE.rawValue, mode.rawValue)
        sendCommand(.START_SCAN)
    }
    
    public func sendCommand(_ cmd: Barcoder.Cmd) {
        Logger.trace("Will send command: \(cmd.rawValue)")
        currentCommand = cmd
        accessoryStreamer?.send(packCommand(cmd, data: nil))
    }
    
    public func sendCommand<T>(_ cmd: Barcoder.Cmd, parameter: UInt8, _ value: T) {
        Logger.trace("Will send command: \(cmd.rawValue) \(parameter) \(value)")
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
        Logger.trace("res: \(res.result), data: \(res.data?.hexEncodedString() ?? "" )")
        
        if let barcode = res.barcode {
            Logger.info("Did scan barcode: \(barcode.text)")
            delegate?.didScanBarcode(barcode: barcode)
        }
        
        if currentCommand == .BAR_DEV_OPEN {
            Logger.debug("Device Opened")
            if let streamer = accessoryStreamer, !streamer.isOpened {
                streamer.openSession()
            }
            configureSimbology()
            configureDefaults()
            startScan(mode: .hard)
        }
    }
    
    private func packCommand(_ cmd: Barcoder.Cmd, data: Data?) -> Data {
        Logger.trace("cmd: \(cmd.rawValue), value: \(data?.hexEncodedString() ?? "")")
        
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

