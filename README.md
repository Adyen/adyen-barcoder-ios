# AdyenBarcoder
Use Verifone Barcode scanner over MFi

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

### Cocoapods

1. Add `pod 'AdyenBarcoder'` to your `Podfile`.
2. Run `pod install`.

### Carthage

1. Add `github "adyen/adyen-barcoder-ios"` to your `Cartfile`.
2. Run `carthage update`.
3. Link the framework with your target as described in [Carthage Readme](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).

### Manual

Copy files from `AdyenBarcoder` folder.

## Usage

You need to add `com.verifone.pmr.barcode` in the `Supported external accessory protocols` into `Info.plist` file

### Initializing

To initialize Barcoder library simply get the shared instance and set your `BarcoderDelegate`.
```swift
let barcoder = Barcoder.sharedInstance
barcoder.delegate = self
```

### BarcoderDelegate

The only mandatory method is `didScan(barcode:)`. This is where the result of the scan will be delivered. You can also receive state updates on `didChange(status:)`. 

```swift
@objc public protocol BarcoderDelegate {
    @objc func didScan(barcode: Barcode)
    @objc optional func didChange(status: BarcoderStatus)
    @objc optional func didReceiveLog(message: String)
}
```

### BarcoderMode

Barcoder library supports four modes:

```swift
@objc public enum BarcoderMode: Int {
    case hardwareAndSofwareButton // Default mode. Both hardware button and software commands (startSoftScan, stopSoftScan) are enabled.
    case hardwareButton // Only hardware button is enabled. Calls to software commands will be ignored.
    case softwareButton // Only software commands are enabled. Clicking the hardware button will not trigger the lights.
    case disabled // Disabled.
}
````

You can set the mode via the `mode` variable on `Barcoder.sharedInstance`. The default value is `.hardwareAndSofwareButton`.

### SoftScan

For starting a soft scan: 
```swift
barcoder.startSoftScan()
```

To stop the soft scan: 
```swift
barcoder.stopSoftScan()
```

#### Important: Remember to allways call `stopSoftScan` after starting a `startSoftScan`.

### Logging

There are five log levels available: None, Error, Info, Debug, Trace. 
To set the log level simply set the variable on your `Barcoder` instance: 
```swift
barcoder.logLevel = .debug
```
You will receive each new log message via `BarcoderDelegate` method `didReceiveLog(message:)`.

## Advanced Usage

### Interleaved 2 of 5

You can enable or disable setting the interleaved2of5 variable on `Barcoder` instance:
```swift
barcoder.interleaved2Of5 = true
```

### Custom Symbology
It's possible to customize the barcoder symbology with `setSymbology(enabled:)` method:
```swift
//Should be called AFTER .ready event on `didChange(status:)`
barcoder.setSymbology(.EN_CODE11, enabled: true)
```
The full list of accepted symbology can be found on `SymPid` enum.

## Example usage in Objective-C

```obj-c
    //
    // Do not forget to put in Podfile:
    // use_frameworks!
    // pod "AdyenBarcoder"
    //
    // And put in Info.plist file:
    // "com.verifone.pmr.barcode" in the "Supported external accessory protocols"

#import <AdyenBarcoder/AdyenBarcoder-Swift.h>

@interface ViewController () <BarcoderDelegate>
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize
    [Barcoder sharedInstance].delegate = self;
}

// Did scanned
- (void)didScanWithBarcode:(Barcode * _Nonnull)barcode {
    NSLog(@"Scanned barcode: %@", barcode.text);
}

@end
```
