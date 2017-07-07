//
//  AVViewController.swift
//  AV
//
//  Created by Laughing on 2017/1/3.
//  Copyright © 2017年 Laughing. All rights reserved.
//

import UIKit
import AVFoundation

class AVViewController: UIViewController {

    // 负责整体的视屏的输入和输出的控制和管理
    var session: AVCaptureSession!
    
    var device: AVCaptureDevice!
    var input: AVCaptureDeviceInput!
    var output: AVCaptureOutput!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { (pass) in
            print("ssssss") 
        }

        // 视屏的会话管理者
        session = AVCaptureSession()
        
        
        // 获取物理设备（前置摄像头，后置摄像头，麦克风）
//        device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        let device1 = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let device2 = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
        let device3 = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeText)
        let device4 = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeClosedCaption)
        let device5 = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeSubtitle)
        let device6 = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeTimecode)
        let device7 = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeMetadata)
        let device8 = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeMuxed)
        
        
        
        
        
        // 后置摄像头
        let backCamera =  AVCaptureDevice(uniqueID: "com.apple.avfoundation.avcapturedevice.built-in_video:0")
        // 前置摄像头
        let frontCamera = AVCaptureDevice(uniqueID: "com.apple.avfoundation.avcapturedevice.built-in_video:1")
        // 麦克风
        let microphone = AVCaptureDevice(uniqueID: "com.apple.avfoundation.avcapturedevice.built-in_audio:0")
        
        // 根据设备来创建输出对象
        do {
            
            
            
            
            input =  try AVCaptureDeviceInput(device: frontCamera)
        } catch {
            print(error)
        }
        
        // 添加输出
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        
        // 添加预览视图
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.frame = self.view.frame
        self.view.layer.addSublayer(previewLayer!)
        
        session.startRunning()
        
    }
}
