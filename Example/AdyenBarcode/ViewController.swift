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
        barcoder.debug = true
        barcoder.delegate = self
    }

    @IBAction func startSoftScan() {
        barcoder.startSoftScan()
    }
    
    @IBAction func stopSoftScan() {
        barcoder.stopSoftScan()
    }
    
    func didScanBarcode(barcode: Barcode) {
        let text = "\(barcode.symbolId.name): \(barcode.text)"
        barcodeText.text = text
    }
    
    func didReceiveNewLogMessage(_ message: String) {
        let line = "\(Date().timeIntervalSince1970) " + message
        logTextView.text = line + "\n" + self.logTextView.text
    }
}
