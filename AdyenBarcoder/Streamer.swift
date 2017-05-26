//
//  Streamer.swift
//  AdyenBarcoder
//
//  Created by Taras Kalapun on 2/1/17.
//  Copyright © 2017 Adyen. All rights reserved.
//

import Foundation


class Streamer: NSObject, StreamDelegate {
    var inputOpened = false
    var outputOpened = false

    var isOpened: Bool {
        get {
            return self.inputOpened && self.outputOpened
        }
    }
    
    var inputStream:  InputStream?
    var outputStream: OutputStream?
    var dataPackets = Queue<Data>()
    
    var onDataReceived: ((Data)->Void)?
    
    /// trying to handle all messages in a another queue
    //private var queue = dispatch_queue_create("com.adyen.connection.queue", DISPATCH_QUEUE_SERIAL)
    
    /// flag which is indicating, that spase is available on the output stream,
    /// but there was no data to write.
    private var canWrite = true
    private var wasRead = true
    
    //  Response timeout
    private let responseTimeout: TimeInterval = 4
    private var responseTimer: Timer?
    
    /// sleeping time after each command was send to ev3
    let connSleepTime = 0.125
    
    deinit {
        closeStreams()
    }
    
    func openStreams() {
        Logger.debug("Opening streams")
        
        if let stream = self.inputStream {
            stream.delegate = self
            stream.schedule(in: RunLoop.current, forMode: .defaultRunLoopMode)
            stream.open()
        }
        if let stream = self.outputStream {
            stream.delegate = self
            stream.schedule(in: RunLoop.current, forMode: .defaultRunLoopMode)
            stream.open()
        }
    }
    
    func closeStreams() {
        if let stream = self.inputStream {
            stream.delegate = nil
            stream.remove(from: RunLoop.current, forMode: .defaultRunLoopMode)
            stream.close()
            self.inputOpened = false
        }
        if let stream = self.outputStream {
            stream.delegate = nil
            stream.remove(from: RunLoop.current, forMode: .defaultRunLoopMode)
            stream.close()
            self.outputOpened = false
        }
        
        self.dataPackets.removeAll()
        Logger.debug("Streams closed")
    }
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.errorOccurred:
            break
        case Stream.Event.endEncountered:
            //aStream.close()
            break
        case Stream.Event.openCompleted:
            
            if aStream == self.outputStream {
                self.outputOpened = true
            }
            if aStream == self.inputStream {
                self.inputOpened = true
            }
            
            if self.isOpened {
                Logger.debug("Streams opened")
            }

            break
        case Stream.Event.hasBytesAvailable:
            guard let stream = self.inputStream else { return }
            streamHasBytesAvailable(stream)
        case Stream.Event.hasSpaceAvailable:
            streamHasSpaceAvailable()
            break
        default:
            break
        }
    }
    
    func streamHasBytesAvailable(_ stream: InputStream) {
        var buffer = [UInt8](repeating: 0, count: 2048)
        var data = Data()
        
        while (stream.hasBytesAvailable) {
            let bytesRead: Int = stream.read(&buffer, maxLength: buffer.count)
            if bytesRead >= 0 {
                data.append(buffer, count: bytesRead)
            }
        }
        Logger.trace("<", data: data)
        if let handler = onDataReceived {
             handler(data)
        }
        
        self.wasRead = true
        self.write()
    }
    
    func streamHasSpaceAvailable() {
        self.canWrite = true
        self.write()
    }
    
    private func write() {
        if !self.wasRead {
            Logger.trace("Write bytes failed in: !self.wasRead")
            return
        }
        
        if self.dataPackets.isEmpty {
            Logger.trace("Write bytes failed in: self.dataPackets.isEmpty")
            return
        }
        
        guard let stream = self.outputStream else { return }
        if (!stream.hasSpaceAvailable) {
            Logger.trace("Write bytes failed in: guard let stream = self.outputStream")
            return
        }
        
        canWrite = false
        wasRead = false
        
        
        guard let data = self.dataPackets.dequeue() else {
            Logger.trace("Write bytes failed in: guard let data = self.dataPackets.dequeue()")
            return
        }
        
        let bytesWritten = data.withUnsafeBytes { stream.write($0, maxLength: data.count) }
        
        if bytesWritten == -1 {
            Logger.trace("Error while writing data to output stream.")
            //print("error while writing data to bt output stream")
            canWrite = true
            wasRead = true
            return // Some error occurred ...
        } else {
            Logger.trace("Did write bytes to output stream.")

            //  Start command timeout timer
            responseTimer?.invalidate()
            responseTimer = Timer.scheduledTimer(
                timeInterval: responseTimeout,
                target: self,
                selector: #selector(self.wasReadDidTimeout),
                userInfo: nil,
                repeats: false
            )
        }
    }
    
    func wasReadDidTimeout(_ timer: Timer) {
        Logger.trace("Bytes stream did timeout to receive response bytes.")
        wasRead = true
    }
    
    func send(_ data: Data?) {
        if (data != nil) {
            self.dataPackets.enqueue(data!)
        } else {
            Logger.trace("No data to send.")
        }
        
        if self.canWrite {
            Logger.trace("Will write to stream.")
            write()
        } else {
            Logger.trace("Cannot write to stream at this moment.")
        }
    }
}

class Queue<T> {
    var queue = [T]()
    
    var isEmpty: Bool {
        get {
            return queue.count == 0
        }
    }
    
    func enqueue(_ element: T) {
        queue.append(element)
    }
    
    func dequeue() -> T? {
        if queue.count > 0 {
            return queue.remove(at: 0)
        }
        return nil
    }
    
    func removeAll() {
        queue.removeAll(keepingCapacity: false)
    }
}

extension UnicodeScalar {
    var hexNibble:UInt8 {
        let value = self.value
        if 48 <= value && value <= 57 {
            return UInt8(value - 48)
        }
        else if 65 <= value && value <= 70 {
            return UInt8(value - 55)
        }
        else if 97 <= value && value <= 102 {
            return UInt8(value - 87)
        }
        fatalError("\(self) not a legal hex nibble")
    }
}

extension Data {
    init(hex: String) {
        let scalars = hex.replacingOccurrences(of: " " , with: "").unicodeScalars
        var bytes = Array<UInt8>(repeating: 0, count: (scalars.count + 1) >> 1)
        for (index, scalar) in scalars.enumerated() {
            var nibble = scalar.hexNibble
            if index & 1 == 0 {
                nibble <<= 4
            }
            bytes[index >> 1] |= nibble
        }
        self = Data(bytes: bytes)
    }
    
    func hexEncodedString() -> String! {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
}
