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
    @IBOutlet weak var logTextView: UITextView!
    @IBOutlet weak var statusView: UIView!
    
    let barcoder = Barcoder.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barcoder.logLevel = .debug
        barcoder.delegate = self
    }
    
    func didScan(barcode: Barcode) {
        let text = "\(barcode.symbolId.name): \(barcode.text)"
        barcodeText.text = text
    }
    
    func didReceiveLog(message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss:SSSS"
        
        let line = "\(formatter.string(from: Date())) - \(message) "
        logTextView.text = line + "\n" + self.logTextView.text
        NSLog(line)
    }
    
    func didChange(status: BarcoderStatus) {
        switch status {
        case .disconnected: statusView.backgroundColor = UIColor.lightGray
        case .connecting: statusView.backgroundColor = UIColor.yellow
        case .ready: statusView.backgroundColor = UIColor.green
        }
    }

    @IBAction func startSoftScan() {
        barcoder.startSoftScan()
    }
    
    @IBAction func stopSoftScan() {
        barcoder.stopSoftScan()
    }
    
    @IBAction func didChangeLogLevel(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: barcoder.logLevel = .none
        case 1: barcoder.logLevel = .error
        case 2: barcoder.logLevel = .info
        case 3: barcoder.logLevel = .debug
        case 4: barcoder.logLevel = .trace
        default: break
        }
    }
}
