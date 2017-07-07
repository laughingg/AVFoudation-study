//
//  QRScanController.swift
//  AV
//
//  Created by Laughing on 2017/1/12.
//  Copyright © 2017年 Laughing. All rights reserved.
//

import UIKit
import AVFoundation

class QRScanController: CaptureController {
    var metadataOutput: AVCaptureMetadataOutput!
    var detectorQueue: DispatchQueue = DispatchQueue(label: "com.laughing.QRScan")
    
    override func setupSessionOutputs() {
        metadataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
        }
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: detectorQueue)
        
        if metadataOutput.availableMetadataObjectTypes.contains(where: { (type) -> Bool in
            return (type as! String) == AVMetadataObjectTypeQRCode
        }) {
            
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        }
    }
}

extension QRScanController : AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        
    }
}
