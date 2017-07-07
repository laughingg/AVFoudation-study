//
//  FaceScanViewController.swift
//  AV
//
//  Created by Laughing on 2017/1/10.
//  Copyright © 2017年 Laughing. All rights reserved.
//

import UIKit
import AVFoundation

class FaceScanViewController: UIViewController {

    var captureSession: AVCaptureSession!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureSession()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setupCaptureSession() {
        
        captureSession = AVCaptureSession()
        
        // 捕获设备
//        let inputDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let inputDevice = AVCaptureDevice.camera(position: .front)
        
        // 输入
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: inputDevice)
        } catch {
            print(error)
        }
        
        // 输出
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        // 装配
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        if output.availableMetadataObjectTypes.contains(where: { (type) -> Bool in
            return (type as! String) == AVMetadataObjectTypeQRCode
        }) {
            
            output.metadataObjectTypes = [AVMetadataObjectTypeFace]
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = self.view.bounds
        self.view.layer.addSublayer(previewLayer!)
        
        captureSession.startRunning()
    }
}


extension FaceScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        
        if metadataObjects.count > 0 {
            print(#function, "face",  type(of: metadataObjects[0]), metadataObjects.count)
            
            print((metadataObjects[0] as! AVMetadataFaceObject).faceID)
            print((metadataObjects[0] as! AVMetadataFaceObject).hasRollAngle)
            print((metadataObjects[0] as! AVMetadataFaceObject).rollAngle)
            print((metadataObjects[0] as! AVMetadataFaceObject).hasYawAngle)
            print((metadataObjects[0] as! AVMetadataFaceObject).yawAngle)
            print((metadataObjects[0] as! AVMetadataFaceObject).type)
            print((metadataObjects[0] as! AVMetadataFaceObject).time)
            print((metadataObjects[0] as! AVMetadataFaceObject).duration)
            print((metadataObjects[0] as! AVMetadataFaceObject).bounds)
        }
    }
    
}

