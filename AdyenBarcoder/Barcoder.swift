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

@objc public enum BarcoderStatus: Int {
    case disconnected, connecting, ready
    
    var description: String {
        get {
            switch self {
            case .connecting: return "Connecting"
            case .ready: return "Ready for use"
            case .disconnected: return "Disconnected"
            }
        }
    }
}

@objc public protocol BarcoderDelegate {
    func didScan(barcode: Barcode)
    @objc optional func didChange(status: BarcoderStatus)
    @objc optional func didReceiveLog(message: String)
}

typealias CommandCompletion = (ParserResponse?, Error?) -> Void

public class Barcoder: NSObject {
    private let accessoryProtocol = "com.verifone.pmr.barcode"
    private var accessoryStreamer: AccessoryStreamer?
    private var currentCommand: Barcoder.Cmd?
    private var accessoryConnectionId = -1
    private var isInitialized = false
    private var isDeviceOpen = false
    
    //  Command completion
    private var currentCommandCompletion: CommandCompletion?
    private var waitingForDeviceOpenResponse = false
    private var commandResponseTimer: Timer?
    
    public static let sharedInstance = Barcoder()
    
    public var delegate: BarcoderDelegate? {
        didSet {
            if !isInitialized {
                setup()
                isInitialized = true
            }
        }
    }
    
    public internal(set) var status: BarcoderStatus = .disconnected {
        didSet {
            if status != oldValue {
                Logger.info("Device status changed: \(status.description)")
                delegate?.didChange?(status: status)
            }
        }
    }
    
    public var logLevel: LogLevel = .info {
        didSet {
            Logger.level = logLevel
        }
    }
    
    public var interleaved2Of5 = false {
        didSet {
            if status == .ready {
                configureSimbology()
            }
        }
    }
    
    private override init() {
        super.init()
        Logger.handler = { [weak self] message in
            self?.delegate?.didReceiveLog?(message: message)
        }
    }
    
    private func setup() {
        Logger.info("Initializing Barcoder")
        registerForNotifications()
        run()
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
                Logger.trace("Set isDeviceOpen to false.")
                self?.isDeviceOpen = false
                self?.accessoryConnectionId = accessory.connectionID
                self?.openDevice()
            } else {
                let isOpen = self?.isDeviceOpen ?? false
                Logger.trace("Leave isDeviceOpen set to \(isOpen).")
            }
        }
        
        accessoryStreamer.onDeviceStatusChange = { [weak self] status in
            switch status {
            case .opening:
                self?.status = .connecting
            case .open:
                if let isDeviceOpen = self?.isDeviceOpen {
                    self?.status = isDeviceOpen ? .ready : .connecting
                }
            default:
                self?.status = .disconnected
            }
        }
        
        self.accessoryStreamer = accessoryStreamer
        accessoryStreamer.start()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        
        waitingForDeviceOpenResponse = true
        
        if let timer = commandResponseTimer {
            timer.invalidate()
        }
        commandResponseTimer = Timer.scheduledTimer(
            timeInterval: 5,
            target: self,
            selector: #selector(self.commandDidTimeout),
            userInfo: nil,
            repeats: false
        )
        
        sendCommand(.BAR_DEV_OPEN) { response, error in
            
            self.commandResponseTimer?.invalidate()
            self.waitingForDeviceOpenResponse = false
            
            let result = response?.result ?? false
            Logger.debug("Open device command did finish.")
            Logger.debug("Open device command result: \(result)")
            if self.currentCommand == .BAR_DEV_OPEN && result == true {
                self.didOpenDevice()
            }
        }
    }
    
    @objc private func commandDidTimeout(_ timer: Timer) {
        Logger.trace("Command did timeout.")
        
        //  Do not continue if device is not open
        if accessoryStreamer?.deviceStatus != .open {
            Logger.trace("Accessory streamer device state is not open, stop reconnecting.")
            waitingForDeviceOpenResponse = false
            return
        }
        
        if waitingForDeviceOpenResponse {
            openDevice()
        }
    }
    
    private func closeDevice() {
        sendCommand(.BAR_DEV_CLOSE)
    }
    
    private func configureDefaults() {
        sendCommand(.EN_CONTINUOUS_RD, parameter: GenPid.CONTINUOUS_READ.rawValue, false)
        sendCommand(.AUTO_BEEP_CONFIG, parameter: GenPid.AUTO_BEEP_MODE.rawValue, 1) //beep
    }
    
    public func setSymbology(_ parameter: Barcoder.SymPid, enabled: Bool) {
        setSymbology(parameter, value: enabled ? 1 : 0)
    }
    
    public func setSymbology(_ parameter: Barcoder.SymPid, data: Data) {
        sendCommand(.SYMBOLOGY, parameter: parameter.rawValue, data)
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
    
    private func sendCommand(_ cmd: Barcoder.Cmd) {
        sendCommand(cmd) { response, error in
            let result = response?.result ?? false
            Logger.trace("Send command completion, result: \(result).")
        }
    }
    
    private func sendCommand(_ cmd: Barcoder.Cmd, completion: @escaping (ParserResponse?, Error?) -> Void) {
        Logger.trace("Will send command: \(cmd.rawValue)")
        currentCommand = cmd
        currentCommandCompletion = completion
        accessoryStreamer?.send(packCommand(cmd, data: nil))
    }
    
    private func sendCommand<T>(_ cmd: Barcoder.Cmd, parameter: UInt8, _ value: T) {
        Logger.trace("Will send command: \(cmd.rawValue) \(parameter) \(value)")
        currentCommand = cmd
        accessoryStreamer?.send(packCommand(cmd, data: packParam(parameter, value)))
    }
    
    private func parseIncomingData(_ data: Data) {
        let res = Parser().parseResponse(data)
        Logger.trace("res: \(res.result), data: \(res.data?.hexEncodedString() ?? "" )")
        
        currentCommandCompletion?(res, nil)

        if let barcode = res.barcode {
            Logger.info("Did scan barcode: \(barcode.text)")
            delegate?.didScan(barcode: barcode)
        }        
    }
    
    private func didOpenDevice() {
        Logger.debug("Device Opened")
        isDeviceOpen = true
        status = .ready
        if let streamer = accessoryStreamer, !streamer.isOpened {
            streamer.openSession()
        }
        configureSimbology()
        configureDefaults()
        startScan(mode: .hard)
    }
    
    private func configureSimbology() {
        if interleaved2Of5 {
            setSymbology(.EN_EAN13_JAN13, value: 0)
            setSymbology(.EN_INTER2OF5, value: 1)
            
            setSymbology(.SETLEN_ANY_I2OF5, value: 0)
            setSymbology(.I2OF5_CHECK_DIGIT, value: 0)
            setSymbology(.XMIT_M2OF5_CHK_DIGIT, value: 1)
            setSymbology(.CONV_I2OF5_EAN13, value: 0)
        } else {
            setSymbology(.EN_EAN13_JAN13, value: 1)
            setSymbology(.EN_INTER2OF5, value: 0)
        }
    }
    
    private func setSymbology(_ parameter: Barcoder.SymPid, value: UInt8) {
        sendCommand(.SYMBOLOGY, parameter: parameter.rawValue, value)
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

