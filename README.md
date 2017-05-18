# AdyenBarcoder
Use Verifone Barcode scanner over MFi

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

### CocoaPods

AdyenBarcode will be available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "AdyenBarcoder"
```

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
    func didScan(barcode: Barcode)
    @objc optional func didChange(status: BarcoderStatus)
    @objc optional func didReceiveLog(message: String)
}
```

### SoftScan
For starting a soft scan: 
```swift
barcoder.startSoftScan()
```

To stop the soft scan: 
```swift
barcoder.stopSoftScan()
```

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
