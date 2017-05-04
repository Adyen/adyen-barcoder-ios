//
//  AccessoryStreamer.swift
//  AdyenBarcoder
//
//  Created by Taras Kalapun on 2/1/17.
//  Copyright © 2017 Adyen. All rights reserved.
//

import Foundation
import ExternalAccessory

class AccessoryStreamer : Streamer {
    private let maxRetries = 6
    private let delayBetweenRetriesInMillis = 500
    private var session: EASession?
    private var accessorySerialNumber: String?
    
    var accessory: EAAccessory?
    var accessoryProtocol: String
    var onAccessoryConnected: ((EAAccessory)->Void)?
    var onDeviceStatusChange: ((DeviceStatus)->Void)?
    
    var deviceStatus: DeviceStatus = .unknown {
        didSet {
            onDeviceStatusChange?(deviceStatus)
        }
    }
    
    init(accessoryProtocol: String) {
        self.accessoryProtocol = accessoryProtocol
        super.init()
    }
    
    func start() {
        Logger.log("AccessoryStreamer \(accessoryProtocol)")
        initAutoconnect()
    }
    
    deinit {
        disconnect()
    }
    
    func connect(_ accessory: EAAccessory) {
        if !isAccessorySupported(accessory) { return }
        
        if (accessory != self.accessory) {
            self.accessory = accessory
        }
        
        accessorySerialNumber = accessory.serialNumber
        onAccessoryConnected?(accessory)
        openSession()
    }
    
    func disconnect() {
        closeStreams()
        accessory = nil
    }
    
    func closeSession() {
        closeStreams()
        inputStream = nil
        outputStream = nil
        accessory = nil
        session = nil
    }
    
    func openSession() {
        guard deviceStatus != .connecting else { return }
        
        deviceStatus = .connecting
        
        closeSession()
        openSession(retries: maxRetries)
    }
    
    private func openSession(retries: Int) {
        checkAcessory()

        if let accessory = self.accessory {
            session = EASession(accessory: accessory, forProtocol: accessoryProtocol)
            
            Logger.log("Opening Session")
            if let input = session?.inputStream, let output = session?.outputStream {
                inputStream = input
                outputStream = output
                openStreams()
                deviceStatus = .connected
            } else {
                Logger.log("Could not open session.")
                retryOpenSession(retriesLeft: retries - 1, delay: delayBetweenRetriesInMillis)
            }
        }
    }
    
    private func checkAcessory() {
        if accessory == nil {
            let manager = EAAccessoryManager.shared()
            for accessory in manager.connectedAccessories {
                if accessory.serialNumber == accessorySerialNumber && isAccessorySupported(accessory) {
                    self.accessory = accessory
                }
            }
        }
    }
    
    private func retryOpenSession(retriesLeft: Int, delay: Int) {
        if retriesLeft >= 0 {
            Logger.log("Retrying opening session: \(maxRetries - retriesLeft) of \(maxRetries)")
            closeSession()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(delay)) { [weak self] in
                self?.openSession(retries: retriesLeft)
            }
        } else {
            deviceStatus = .unknown
        }
    }

    func isAccessorySupported(_ accessory: EAAccessory) -> Bool {
        return accessory.protocolStrings.contains(accessoryProtocol)
    }
    
    func initAutoconnect() {
        let manager = EAAccessoryManager.shared()
        manager.registerForLocalNotifications()
        
        NotificationCenter.default.addObserver(self, selector: #selector(accessoryDidConnectNotification), name:  NSNotification.Name.EAAccessoryDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(accessoryDidDisconnectNotification), name:  NSNotification.Name.EAAccessoryDidDisconnect, object: nil)
        
        Logger.log("initAutoconnect")
        
        for accessory in manager.connectedAccessories {
            Logger.log("Checking \(accessory.description)")
            if isAccessorySupported(accessory) {
                connect(accessory)
                return
            }
        }
    }
    
    func accessoryDidConnectNotification(_ notification: NSNotification) {
        let accessory = notification.userInfo?[EAAccessoryKey] as! EAAccessory
        
        Logger.log("accessoryDidConnectNotification \(accessory.description)")
        
        if !isAccessorySupported(accessory) {
            Logger.log("not supported")
            return
        }
        connect(accessory)
    }
    
    func accessoryDidDisconnectNotification(_ notification: NSNotification) {
        let accessory = notification.userInfo?[EAAccessoryKey] as! EAAccessory
        
        Logger.log("accessoryDidDisconnectNotification \(accessory.description)")
    }
}
