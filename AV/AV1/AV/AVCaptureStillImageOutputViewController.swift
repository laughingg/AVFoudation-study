//
//  AVCaptureStillImageOutputViewController.swift
//  AV
//
//  Created by Laughing on 2017/1/11.
//  Copyright © 2017年 Laughing. All rights reserved.
//

import UIKit
import AVFoundation

class AVCaptureStillImageOutputViewController: UIViewController {

    var captureSession: AVCaptureSession!
    var output: AVCaptureStillImageOutput!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureSession()
    }
    
    func setupCaptureSession() {
        
        captureSession = AVCaptureSession()
        
        // 捕获设备
        let inputDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            
        inputDevice?.configuration { device in
            // 闪关灯自动
            if device.isFlashModeSupported(.auto) {
                device.flashMode = .auto
            }
            
            // 白平衡自动
            if device.isWhiteBalanceModeSupported(.autoWhiteBalance) {
                device.whiteBalanceMode = .autoWhiteBalance
            }
            
            // 自动对焦
            if device.isFocusModeSupported(.autoFocus) {
                device.focusMode = .autoFocus
            }
            
            // 自动曝光
            if device.isExposureModeSupported(.autoExpose) {
                device.exposureMode = .autoExpose
            }
        }
        
        
        // 输入
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: inputDevice)
        } catch {
            print(error)
        }
        
        // 输出
        let output = AVCaptureStillImageOutput()
        output.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
        self.output = output

        // 装配
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = self.view.bounds
        self.view.layer.addSublayer(previewLayer!)
        
        captureSession.startRunning()
        
        
        
        
        
        let btn = UIButton()
        btn.setTitle("拍照", for: .normal)
        view.addSubview(btn)
        btn.frame = CGRect(x: 10, y: 74, width: 100, height: 30)
        btn.backgroundColor = UIColor.red
        btn.addTarget(self, action: #selector(play), for: .touchUpInside)
    }
    
    func play(){
        captureStillImage { (url, data) in
            
        }
    }
    
    
    func captureStillImage(completionHandler:@escaping (_ url: URL, _ imageData: Data)->()) {
        
        // 获取管道
        var videoConnection:AVCaptureConnection!
        
        for connection in output.connections {
            
            for port in (connection as! AVCaptureConnection).inputPorts {
                
                if ((port as! AVCaptureInputPort).mediaType as String) == AVMediaTypeVideo {
                    videoConnection = (connection as! AVCaptureConnection)
                    break
                }
            }
            
            if videoConnection != nil {
                break;
            }
        }
        
        
        
        
        // 异步截图
        self.output.captureStillImageAsynchronously(from: videoConnection) { (imageSampleBuffer, error) in
            
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
            
            
            let path = NSTemporaryDirectory()
            let filePath = path + "/" + Date().description + ".jpeg"
            
            print(path)
            
            let url = URL(fileURLWithPath: filePath)
            
            do {
                try imageData?.write(to: url)
            } catch{
                print(error)
            }
            
            completionHandler(url, imageData!)
        }
    }

}



