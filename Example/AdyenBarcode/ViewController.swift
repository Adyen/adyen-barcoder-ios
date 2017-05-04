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
    
    let barcoder = Barcoder.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barcoder.logLevel = .debug
        barcoder.delegate = self
    }
    
    func didScanBarcode(barcode: Barcode) {
        let text = "\(barcode.symbolId.name): \(barcode.text)"
        barcodeText.text = text
    }
    
    func didReceiveNewLogMessage(_ message: String) {
        let line = "\(Date().timeIntervalSince1970) " + message
        logTextView.text = line + "\n" + self.logTextView.text
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
