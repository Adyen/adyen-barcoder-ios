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

class ViewController: UIViewController {

    @IBOutlet weak var barcodeText: UILabel!
    @IBOutlet weak var logTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Barcoder.debug = true
        Barcoder.logHandler = { line in
            self.logTextView.text = line + "\n" + self.logTextView.text
        }
        
        Barcoder.sharedInstance.scanHandler = { [weak self] barcode in
            let text = "\(barcode.symbolId.name): \(barcode.text)"
            self?.barcodeText.text = text
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startSoftScan() {
        Barcoder.sharedInstance.startSoftScan()
    }
    
    @IBAction func stopSoftScan() {
        Barcoder.sharedInstance.stopSoftScan()
    }
}

