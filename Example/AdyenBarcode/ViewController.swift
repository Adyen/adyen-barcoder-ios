//
//  ViewController.swift
//  AdyenBarcoder
//
//  Created by Taras Kalapun on 1/26/17.
//  Copyright © 2017 Adyen. All rights reserved.
//

import UIKit
import ExternalAccessory
import AdyenBarcoder

class ViewController: UIViewController, BarcoderDelegate {

    @IBOutlet weak var barcodeText: UILabel!
    @IBOutlet weak var accessoryText: UILabel!
    @IBOutlet weak var logTextView: UITextView!
    
    @IBOutlet weak var autoOpenSwitch: UISwitch!
    @IBOutlet weak var i2of5Switch: UISwitch!
    @IBOutlet weak var debugSwitch: UISwitch!
    
    let barcoder = AdyenBarcoder.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setAccessoryText(accessory: EAAccessory?) {
        let name : String! = (accessory != nil) ? accessory?.name : ""
        self.accessoryText.text = name
    }
    
    @IBAction func startBarcoder() {
        barcoder.accessoryConnectedHandler = { accessory in
            self.setAccessoryText(accessory: accessory)
        }
        
        barcoder.accessoryDisconnectedHandler = {
            self.setAccessoryText(accessory: nil)
        }
        
        barcoder.deviceConfigHandler = { barcoder in
            
            if self.i2of5Switch.isOn {
                //Interleaved 2 of 5
                barcoder.mSymbology(.EN_EAN13_JAN13, value: 0)
                barcoder.mSymbology(.EN_INTER2OF5, value: 1)
                barcoder.mSymbology(.SETLEN_ANY_I2OF5, value: 0)
                barcoder.mSymbology(.I2OF5_CHECK_DIGIT, value: 0)
                barcoder.mSymbology(.XMIT_M2OF5_CHK_DIGIT, value: 1)
                barcoder.mSymbology(.CONV_I2OF5_EAN13, value: 0)
            } else {
                barcoder.mSymbology(.EN_EAN13_JAN13, value: 1)
                barcoder.mSymbology(.EN_INTER2OF5, value: 0)
            }
            
            barcoder.startScan()
        }
        
        barcoder.logHandler = { line in
            self.logTextView.text = line + "\n" + self.logTextView.text
        }
        
        barcoder.delegate = self
        
        barcoder.debug = self.debugSwitch.isOn
        barcoder.autoConnect = true
        barcoder.autoOpenDevice = self.autoOpenSwitch.isOn
        
        barcoder.run()
    }

    @IBAction func reconnect(_ sender: Any) {
        AdyenBarcoder.sharedInstance.reconnect()
    }
    
    @IBAction func disconnect(_ sender: Any) {
        AdyenBarcoder.sharedInstance.disconnect()
    }

    
//    @IBAction func startScan(_ sender: Any) {
//        AdyenBarcode.sharedInstance.startScan()
//    }
//    
//    @IBAction func stopScan(_ sender: Any) {
//        AdyenBarcode.sharedInstance.stopScan()
//    }
//    
    @IBAction func closeDevice(_ sender: Any) {
        AdyenBarcoder.sharedInstance.closeDevice()
    }

    @IBAction func openDevice(_ sender: Any) {
        AdyenBarcoder.sharedInstance.openDevice()
    }

    
    // MARK: - Barcode delegate

    
    func barcodeReceived(_ barcode: Barcode) {
        let text = "\(barcode.symbolId.name): \(barcode.text)"
        self.barcodeText.text = text
    }
    
}

