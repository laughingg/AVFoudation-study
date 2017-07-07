//
//  AVCaptureManager.swift
//  HTSB
//
//  Created by Laughing on 2017/1/6.
//  Copyright © 2017年 Laughing. All rights reserved.
//

import UIKit
import AVFoundation

class AVCaptureManager: NSObject {

    weak var delegate: AVCaptureFileOutputRecordingDelegate?
    
    // 视频录制会话
    var captureSession: AVCaptureSession!
    
    // 摄像头
    var camera: AVCaptureDevice {
        return activeVideoInput.device
    }
    
    // 麦克风
    var microphone: AVCaptureDevice {
        return audioInput.device
    }
    
    // 视频回话运行队列
    var captureSessionQueue: DispatchQueue!
    
    // 激活的视屏输入
    var activeVideoInput: AVCaptureDeviceInput!
    // 音频输入
    var audioInput: AVCaptureDeviceInput!
    
    // 视频文件输出
    var movieFileOutput: AVCaptureMovieFileOutput!
    // 静态图片输出
    var stillImageOutput: AVCaptureStillImageOutput!
    
    // 视频预览图层
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    
    override init() {
        super.init()
    
        setupCaptureSession()
    }
    
    func setupCaptureSession() {
        
        // 回话管理
        captureSession = AVCaptureSession()
        
       
        let videoDevice =  AVCaptureDevice.backCamera.configuration { device in
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
        // 视频
        do {
            activeVideoInput =  try AVCaptureDeviceInput(device: videoDevice)
        } catch {
            print("videoInput", error)
        }
        
        if captureSession.canAddInput(activeVideoInput) {
            captureSession.addInput(activeVideoInput)
        }
        
        do {
            audioInput = try AVCaptureDeviceInput(device: AVCaptureDevice.microphone)
        } catch {
            print("audioInput", error)
        }
        
        if captureSession.canAddInput(audioInput) {
            captureSession.addInput(audioInput)
        }
        
        
        // 静态图片输出
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
        
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
        
        // 影片输出
        movieFileOutput  = AVCaptureMovieFileOutput()
        
        if captureSession.canAddOutput(movieFileOutput) {
            captureSession.addOutput(movieFileOutput)
        }
        
        
        let videoDataOutput = AVCaptureVideoDataOutput()
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        }
        
         previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
         previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        // 预览视图
        // previewLayer.orientation
        // 创建session 运行的队列
        captureSessionQueue = DispatchQueue(label: "com.laughing.captureSessionQueue")
    }

    
    func sessionRun() {
        if !captureSession.isRunning {
            captureSessionQueue.async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func sessionStop() {
        
        if captureSession.isRunning {
            captureSessionQueue.async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    
    // 获取闲置摄像头
    func inactiveVideoDevice() -> AVCaptureDevice {
        if self.activeVideoInput.device.position == .front {
            return AVCaptureDevice.defaultDevice(position: .back)!
        } else {
            return AVCaptureDevice.defaultDevice(position: .front)!
        }
    }
    
    
    func switchCamera() {
        if AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).count > 1 {
        
            let device = self.inactiveVideoDevice()
            
            var input: AVCaptureDeviceInput!
            
            do {
                input =  try AVCaptureDeviceInput(device: device )
            } catch {
                print(error)
            }
            
            self.sessionConfiguration {
                // 移除之前的摄像头
                captureSession.removeInput(self.activeVideoInput)
                
                
                // 添加新的摄像头
                if captureSession.canAddInput(input) {
                    
                    captureSession.addInput(input)
                    self.activeVideoInput = input
                }
            }
        }
    }
    
    
    func sessionConfiguration(config:()->()) {
        self.captureSession.beginConfiguration()
        config()
        self.captureSession.commitConfiguration()
    }
}


extension AVCaptureManager {

    func startMoveRecording(url: URL) {

        movieFileOutput.startRecording(toOutputFileURL: url, recordingDelegate: self.delegate)
    
    }
    
    func stopMovieRecording() {
        movieFileOutput.stopRecording()
    }
}


extension AVCaptureManager {

    func captureStillImage(completionHandler:@escaping (_ url: URL, _ imageData: Data)->()) {
        
        // 获取管道
        var videoConnection:AVCaptureConnection!
        
        for connection in stillImageOutput.connections {
            
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
        self.stillImageOutput.captureStillImageAsynchronously(from: videoConnection) { (imageSampleBuffer, error) in
            

            
            
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

extension AVCaptureManager {

    func checkVideoAuthorizationStatus() {
    
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
        case .authorized:
            // The user has previously granted access to the camera.
            break
            
        case .notDetermined: break
            
        default:
            
            break
        }
    
    }
}



// MARK: - 捕获设备扩展
extension AVCaptureDevice {
    
    
    /// 后置摄像头
    class var backCamera: AVCaptureDevice {
        return AVCaptureDevice(uniqueID: "com.apple.avfoundation.avcapturedevice.built-in_video:0")
    }
    
    /// 前置摄像头
    class var frontCamera: AVCaptureDevice {
        return AVCaptureDevice(uniqueID: "com.apple.avfoundation.avcapturedevice.built-in_video:1")
    }
    
    /// 麦克风
    class var microphone: AVCaptureDevice {
        return AVCaptureDevice(uniqueID: "com.apple.avfoundation.avcapturedevice.built-in_audio:0")
    }
    
    
    /// 根据设备的位置来获取设备（主要是前置和后置摄像头）
    class func defaultDevice(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        
        for device in AVCaptureDevice.devices() {
            if (device as! AVCaptureDevice).position == position {
                return (device as! AVCaptureDevice)
            }
        }
        return nil
    }
    
    

}
