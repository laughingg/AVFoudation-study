//
//  CaptureController.swift
//  AV
//
//  Created by Laughing on 2017/1/6.
//  Copyright © 2017年 Laughing. All rights reserved.
//

import UIKit
import AVFoundation


class CaptureController: NSObject {
    
    // 视频录制会话
    var session: AVCaptureSession =  AVCaptureSession()
    // 视频回话运行队列
    var sessionQueue:DispatchQueue  = DispatchQueue(label: "com.laughing.captureSession")

    var sessionPreset = AVCaptureSessionPresetHigh {
        didSet{
            if session.canSetSessionPreset(sessionPreset) {
                session.sessionPreset = sessionPreset
            }
        }
    }
    
    // MARK: - 物理设备
    // 当前使用的摄像头
    var camera: AVCaptureDevice {
        return videoInput!.device
    }
    
    // 麦克风
    var microphone: AVCaptureDevice {
        return audioInput!.device
    }
    
    
    // MARK: - 输入
    // 激活的视屏输入
    var videoInput: AVCaptureDeviceInput?
    // 音频输入
    var audioInput: AVCaptureDeviceInput?
    

    // MARK: - 预览
    // 视频预览图层
    var previewLayer: AVCaptureVideoPreviewLayer?
    

    // MARK: -
    override init() {
        super.init()
        
        // 检查授权状态
        checkVideoAuthorizationStatus()
    }
    
    
    // MARK: - Configuration
    /// Configuration
    func setupCaptureSession() {
        
        // 设置输入
        setupSessionInputs()
        
        // 设置输出
        setupSessionOutputs()
    }
    
    func setupSessionInputs() {
    
        // 获取设备
        let videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
        
        
        // 添加设备
        do {
            videoInput =  try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            }
        } catch {
            print(error, "device cannot be opened because it is no longer available or because it is in use!")
        }
        
        
        do {
            audioInput = try AVCaptureDeviceInput(device: audioDevice)
            if session.canAddInput(audioInput) {
                session.addInput(audioInput)
            }
        } catch {
             print(error, "device cannot be opened because it is no longer available or because it is in use!")
        }
        

        // 获取预览视图
        self.previewLayer =  AVCaptureVideoPreviewLayer(session: self.session)
    }
    
    
    /// 这个方法是留给子类实现的
    func setupSessionOutputs() {
        
    }
}


// MARK: - session 操作
extension CaptureController {
    
    /// 开启会话
    func sessionStartRunning() {
        if !session.isRunning {
            sessionQueue.async {
                self.session.startRunning()
            }
        }
    }
    
    
    /// 停止回话
    func sessionStopRunning() {
        if session.isRunning {
            sessionQueue.async {
                self.session.stopRunning()
            }
        }
    }
    
    
    /// session 配置操作
    ///
    /// - Parameter config: 配置代码块
    func sessionConfiguration(config:(_ session: AVCaptureSession)->()) {
        
        self.session.beginConfiguration()
        config(self.session)
        self.session.commitConfiguration()
    }
}

extension CaptureController {

    func checkVideoAuthorizationStatus() {
        
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        switch status {
        case .authorized:       // 已经授权
            setupCaptureSession()
        case .denied:           // 否认 明确拒绝用户访问
            break
        case .notDetermined:    // 不确定 尚未选择关于客户端是否可以访问硬件
            
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (ss) in
                
            })
            break
        case .restricted:       // 限制 客户端未被授权访问硬件的媒体类型。用户不能改变客户的状态,可能由于活跃的限制,如家长控制。
            break
        }
    }
    
    ///能否切换摄像头
    var canSwitchCameras: Bool {
        return camerasCount > 1
    }
    
    /// 摄像头个数
    var camerasCount: Int {
        return AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).count
    }
    
    /// 切换摄像头
    func switchCamera() {
        
        if !canSwitchCameras {
            print("不能切换摄像头， 摄像头的个数只有 \(camerasCount)个")
            return
        }
        
       
        // 获取闲置设备
        let device = self.inactiveVideoDevice()
        
        var input: AVCaptureDeviceInput!
        
        do {
            input =  try AVCaptureDeviceInput(device: device )
        } catch {
            print(error)
        }
        
        self.sessionConfiguration { session in
            // 移除之前的摄像头
            session.removeInput(self.videoInput)
            
            // 添加新的摄像头
            if session.canAddInput(input) {
                
                session.addInput(input)
                self.videoInput = input
            } else {
                // 不能切换就添加之前的
                session.addInput(videoInput)
            }
        }
    }
    
    /// 获取闲置摄像头
    func inactiveVideoDevice() -> AVCaptureDevice {
        if self.videoInput?.device.position == .front {
            return AVCaptureDevice.camera(position: .back)!
        } else {
            return AVCaptureDevice.camera(position: .front)!
        }
    }
    
    /// 激活了的摄像头
    func activeVideoDevice() -> AVCaptureDevice {
        return (videoInput?.device)!
    }
}



// MARK: - 设备扩展
extension AVCaptureDevice {
    
    /// 后置摄像头
    class var backCamera: AVCaptureDevice? {
        return AVCaptureDevice.camera(position: .back)
    }
    
    /// 前置摄像头
    class var frontCamera: AVCaptureDevice? {
        return AVCaptureDevice.camera(position: .front)
    }
    
    /// 麦克风
    class var microphone: AVCaptureDevice? {
        return AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
    }
    
    /// 根据摄像头的位置来获取摄像头
    ///
    /// - Parameter position: 摄像头位置
    /// - Returns: 摄像头
    class func camera(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        var tmpDevice: AVCaptureDevice!
        for device in AVCaptureDevice.devices() {
            if (device as! AVCaptureDevice).position == position {
                tmpDevice =  (device as! AVCaptureDevice)
            }
        }
        return tmpDevice
    }
    
    
    /// 设备的配置
    func configuration(config: (AVCaptureDevice)->()) {
        
        do {
            try self.lockForConfiguration()
        }catch{
            print(error, #function, self)
        }
        config(self)
        
        self.unlockForConfiguration()
    }
}

//tb=1024gb
//gb=1024mb
//mb=1024kb
//kb=1024bytes
//bytes=8bit

struct Memory {
    var value: Int
    
    init(tb:Int) {
        value = tb * 1024 * 1024 * 1024 * 1024
    }
    
    init(gb: Int) {
        value = gb * 1024 * 1024 * 1024
    }
    
    init(mb: Int) {
        value = mb * 1024 * 1024
    }
    
    init(kb: Int) {
        value = kb * 1024
    }
    
    init(bytes: Int) {
        value = bytes
    }
}




extension UIImage {
    
    func imageCompress(maxFileMemorySize size: Memory) -> Data {
        
        let maxFileSize = size.value
        var compressionQuality: CGFloat = 0.9
        
        var compressedData = UIImageJPEGRepresentation(self, compressionQuality)
        
        while (compressedData?.count)! >  maxFileSize{
            
            compressionQuality *= 0.9
            var tmpCompressedData = UIImageJPEGRepresentation(self, compressionQuality)
            
            if tmpCompressedData?.count == compressedData?.count {
                compressedData = tmpCompressedData
                return compressedData!
            }
            
            compressedData = tmpCompressedData
        }
        return compressedData!
    }
}


func generatorStillImageOutputFileURL() -> URL {
    let path = NSTemporaryDirectory()
    let stillImageFilePath = path + "/" + currentDateformateString + ".jpeg"
    return URL(fileURLWithPath: stillImageFilePath)
}


func generatorMovieOutputFileURL() -> URL {
    let path = NSTemporaryDirectory()
    let stillImageFilePath = path + "/" + currentDateformateString + ".mp4"
    return URL(fileURLWithPath: stillImageFilePath)
}

/// 获取当前时间的时间戳
var  currentDateformateString: String {
    let fmt = DateFormatter()
    fmt.dateFormat = "yyyyMMddHHmmss"
    return fmt.string(from: Date())
}
