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

    @IBOutlet weak var debugSwitch: UISwitch!
    
    let barcoder = Barcoder.sharedInstance
    
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
        
        barcoder.logHandler = { line in
            self.logTextView.text = line + "\n" + self.logTextView.text
        }
        
        barcoder.delegate = self
        
        barcoder.debug = self.debugSwitch.isOn
    }
    
    @IBAction func startSoftScan() {
        barcoder.startSoftScan()
    }
    
    @IBAction func stopSoftScan() {
        barcoder.stopSoftScan()
    }
    
    // MARK: - Barcode delegate
    
    func barcodeReceived(_ barcode: Barcode) {
        let text = "\(barcode.symbolId.name): \(barcode.text)"
        self.barcodeText.text = text
    }
}

