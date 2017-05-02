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
    private let maxRetries = 3
    private let delayBetweenRetries = 1
    
    private var session: EASession?
    var accessory: EAAccessory?
    var accessoryProtocol: String
    var autoconnect: Bool = false
    
    var onConnected: ((EAAccessory)->Void)?
    var onDisconnected: ((Void)->Void)?
    
    private var accessorySerialNumber: String?
    
    init(accessoryProtocol: String, autoconnect: Bool) {
        self.accessoryProtocol = accessoryProtocol
        self.autoconnect = autoconnect
        
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
        closeStreams()
        
        if !isAccessorySupported(accessory) { return }
        
        if (accessory != self.accessory) {
            self.accessory = accessory
        }
        
        accessorySerialNumber = accessory.serialNumber
        onConnected?(accessory)
        openSession()
    }
    
    func disconnect() {
        closeStreams()
        accessory = nil
        onDisconnected?()
    }
    
    func closeSession() {
        closeStreams()
        inputStream = nil
        outputStream = nil
        accessory = nil
        session = nil
    }
    
    func openSession() {
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
            } else {
                Logger.log("Could not open session.")
                retryOpenSession(retriesLeft: retries - 1, delay: delayBetweenRetries)
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
        if retriesLeft > 0 {
            Logger.log("Retrying opening session: \(maxRetries - retriesLeft) of \(maxRetries)")
            closeSession()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(delay)) { [weak self] in
                self?.openSession(retries: retriesLeft)
            }
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
        
        if self.accessory == accessory {
            disconnect()
        }
    }
}
