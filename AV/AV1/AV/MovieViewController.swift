//
//  MovieViewController.swift
//  AV
//
//  Created by Laughing on 2017/1/6.
//  Copyright © 2017年 Laughing. All rights reserved.
//

import UIKit
import AVFoundation

class MovieViewController: UIViewController {
    
    @IBAction func start(_ sender: Any) {
        
        startSession()
    }
    
    @IBAction func stop(_ sender: Any) {
        
        stopSession()
    }
    // 负责整体的视屏的输入和输出的控制和管理
    var session: AVCaptureSession!
    
    var device: AVCaptureDevice!
    var frontVideoInput: AVCaptureDeviceInput!
    var backVideoInput: AVCaptureDeviceInput!
    
    var activeVideoInput: AVCaptureDeviceInput!
    
    var audioInput: AVCaptureDeviceInput!
    
    var moveFileOutput: AVCaptureMovieFileOutput!
    
    var videoQueue: DispatchQueue!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        
        
        setupSession()
    }
}


extension MovieViewController {
    
    func setupSession() {
        // 视屏的会话管理者
        session = AVCaptureSession()
        
        // 后置摄像头
        let backCamera =  AVCaptureDevice(uniqueID: "com.apple.avfoundation.avcapturedevice.built-in_video:0")
        // 前置摄像头
        let frontCamera = AVCaptureDevice(uniqueID: "com.apple.avfoundation.avcapturedevice.built-in_video:1")
        // 麦克风
        let microphone = AVCaptureDevice(uniqueID: "com.apple.avfoundation.avcapturedevice.built-in_audio:0")
        
        // 根据设备来创建输出对象
        // 视频
        do {
            frontVideoInput =  try AVCaptureDeviceInput(device: frontCamera)
        } catch {
            print(error)
        }
        
        // 添加输入
        if session.canAddInput(frontVideoInput) {
            session.addInput(frontVideoInput)
        }
        
        
        activeVideoInput = frontVideoInput
        
//        do {
//            backVideoInput =  try AVCaptureDeviceInput(device: backCamera)
//        } catch {
//            print(error)
//        }
//        
//        // 添加输入
//        if session.canAddInput(backVideoInput) {
//            session.addInput(backVideoInput)
//        }
        
        
        // 音频
        do {
            audioInput = try AVCaptureDeviceInput(device: microphone)
        } catch {
            print(error)
        }
        
        if session.canAddInput(audioInput) {
            session.addInput(audioInput)
            
        }
        
        
        
        
        // 添加输出
         moveFileOutput = AVCaptureMovieFileOutput()
        if session.canAddOutput(moveFileOutput) {
        
            session.addOutput(moveFileOutput)
        }
        
        
        // 添加预览视图
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(previewLayer!, at: 0)
    
        
        videoQueue = DispatchQueue(label: "com.laughing.viewQueue")
    }
    
    
    func startSession() {
        if !self.session.isRunning {
            videoQueue.async {
                self.session.startRunning()
            }
        }
    }
    
    func stopSession() {
        if self.session.isRunning {
            videoQueue.async {
                self.session.stopRunning()
            }
        }
    }
    
    func camera(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
    
        let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        
        for device in devices! {
            if (device as! AVCaptureDevice).position == position {
                return device as? AVCaptureDevice
            }
        }
        return nil
    }
    
    func activeCamera() -> AVCaptureDevice {
        return activeVideoInput.device
    }
    
    func inactiveCamera() -> AVCaptureDevice {
        if self.activeCamera().position == .front {
            return self.camera(position: .back)!
        } else {
            return self.camera(position: .front)!
        }
    }
    
    func canSwitchCameras () -> Bool {
        return self.cameraCount() > 1
    }
    
    
    
    func cameraCount() -> Int {
        return AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).count
    }
    
    
    func switchCamera() -> Bool {
        if !self.canSwitchCameras() {
            return false
        }
        
        let device = self.inactiveCamera()
        var input: AVCaptureDeviceInput!
        
        do {
            input =  try AVCaptureDeviceInput(device: device )
        } catch {
            print(error)
        }
        
        
        self.session.beginConfiguration()
        self.session.removeInput(self.activeVideoInput)
        
        if self.session.canAddInput(input) {
        
            self.session.addInput(input)
            self.activeVideoInput = input
        } else {
            self.session.addInput(self.activeVideoInput)
        }
        
        self.session.commitConfiguration()
        
        return true
        
    }
    
    
    func isRecording() -> Bool {
        return self.moveFileOutput.isRecording
    }
    
    func startRecording() {
        if !self.isRecording() {
        
            // 链接插座
            let videoConnection = self.moveFileOutput.connection(withMediaType: AVMediaTypeVideo)
            
            if (videoConnection?.isVideoOrientationSupported)! {
//                videoConnection?.videoOrientation = self.
            }
            
            if (videoConnection?.isVideoStabilizationSupported)! {
                videoConnection?.enablesVideoStabilizationWhenAvailable = true
            }
            
            let device = self.activeCamera()

            
            let url = self.uniqueURL()
            
            self.moveFileOutput.startRecording(toOutputFileURL: url, recordingDelegate: self)
        }
    }
    
    func stopRecording() {
    
        if self.isRecording() {
            self.moveFileOutput.stopRecording()
        }
    }
    
    func uniqueURL() -> URL {
        let path = NSTemporaryDirectory()
        let filePath = path + "/" + Date().description + ".mov"
        
        return URL(fileURLWithPath: filePath)
    }
}


extension MovieViewController : AVCaptureFileOutputRecordingDelegate {

    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
    
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
    
    
    }
}
