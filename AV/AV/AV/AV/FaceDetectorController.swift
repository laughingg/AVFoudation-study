//
//  FaceDetectorController.swift
//  AV
//
//  Created by Laughing on 2017/1/12.
//  Copyright © 2017年 Laughing. All rights reserved.
//

import UIKit
import AVFoundation

class FaceDetectorController: CaptureController {

    weak var delegate: AVCaptureMetadataOutputObjectsDelegate?
    var metadataOutput: AVCaptureMetadataOutput!
    var detectorQueue: DispatchQueue = DispatchQueue(label: "com.laughing.FaceDetector")
    
    override func setupSessionOutputs() {
        metadataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
        }
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: detectorQueue)
        
        if metadataOutput.availableMetadataObjectTypes.contains(where: { (type) -> Bool in
            return (type as! String) == AVMetadataObjectTypeFace
        }) {
            
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeFace]
        }
    }
}

extension FaceDetectorController : AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        if metadataObjects.count > 0 {
            print(#function, "face",  type(of: metadataObjects[0]))
        }
        
    }
}
