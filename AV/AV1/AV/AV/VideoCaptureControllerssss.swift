//
//  VideoCaptureController.swift
//  AV
//
//  Created by Laughing on 2017/1/12.
//  Copyright © 2017年 Laughing. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class VideoCaptureControllerssss: NSObject {
    
    
    // 视频录制会话
    var session: AVCaptureSession!
    // 视频回话运行队列
    var sessionQueue:DispatchQueue!
    
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
    
    
    // ------------------------------------------------------------------------------------------------------------------------
    var videoDataOutput: AVCaptureVideoDataOutput!              // 视频
    var audioDataOutput: AVCaptureAudioDataOutput!              // 音频
    var stillImageOutput: AVCaptureStillImageOutput!            // 静态图片
    var faceMetadataOutput: AVCaptureMetadataOutput!            // 人脸识别
    
    // 视屏队列
    var videoQueue: DispatchQueue = DispatchQueue(label: "com.laughing.videoCapture.video")
    
    // 音频队列
    var audioQueue: DispatchQueue = DispatchQueue(label: "com.laughing.videoCapture.audio")
    
    /// 正在录制
    var isRecording: Bool = false
    
    /// 暂停录制
    var isRecordingPaused: Bool = false
    
    var assetWriter: AVAssetWriter?
    var assetWriterInput: AVAssetWriterInput?
    var videoOutputFileURL: URL?
    
    
    // MARK: -
    override init() {
        super.init()
        
        setupCaptureSession()
    }
    
    
    // MARK: - Configuration
    /// Configuration
    func setupCaptureSession() {
        
        session =  AVCaptureSession()
        sessionQueue = DispatchQueue(label: "com.laughing.captureSession")
        
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
    }
    
    func setupSessionOutputs() {
        
        // 输出
        videoDataOutput = AVCaptureVideoDataOutput()
        audioDataOutput = AVCaptureAudioDataOutput()
        stillImageOutput = AVCaptureStillImageOutput()
        
        videoDataOutput.setSampleBufferDelegate(self, queue: videoQueue)
        videoDataOutput.recommendedVideoSettingsForAssetWriter(withOutputFileType: AVFileTypeMPEG4)
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: kCVPixelFormatType_32BGRA]
        
        // 视频
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }

        // 音频
        if session.canAddOutput(audioDataOutput) {
            session.addOutput(audioDataOutput)
        }
        
        audioDataOutput.setSampleBufferDelegate(self, queue: audioQueue)
        
        if session.canAddOutput(stillImageOutput) {
            session.addOutput(stillImageOutput)
            stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        }
        
        // 人脸识别
        faceMetadataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(faceMetadataOutput) {
            session.addOutput(faceMetadataOutput)
        }
        
        faceMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        if faceMetadataOutput.availableMetadataObjectTypes.contains(where: { (type) -> Bool in
            return (type as! String) == AVMetadataObjectTypeFace
        }) {
            faceMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeFace]
        }
        
        
        let videoConnection = videoDataOutput.connection(withMediaType: AVMediaTypeVideo)
        videoConnection?.videoOrientation = .portrait
        
        
        // 获取预览视图
        self.previewLayer =  AVCaptureVideoPreviewLayer(session: self.session)
    }
}


// MARK: - session 操作
extension VideoCaptureControllerssss {
    
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

extension VideoCaptureControllerssss {
    
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



// MARK: - AVCaptureMetadataOutputObjectsDelegate ---- 人脸识别
extension VideoCaptureControllerssss : AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        if metadataObjects.count > 0 {
            print(#function, "face",  type(of: metadataObjects[0]))
        }
    }
}



// MARK: - 常用 action
extension VideoCaptureControllerssss {
    /// 开始录制
    ///
    /// - Parameter url: 视屏保存的 url
    func startRecording(url: URL) {
        isRecording = true
        videoOutputFileURL = url
    }
    
    /// 停止录制
    func stopRecording() {
        isRecording = false
        
        videoQueue.async {
            self.assetWriter?.finishWriting {
                print("视频录制完成。。。。")
                
                self.videoOutputFileURL = nil
            }
        }
    }
    
    // 暂定录制
    func pauseRecording() {
        isRecordingPaused = true
    }
    
    // 启动录制（从暂停状态恢复）
    func resumeRecording() {
        isRecordingPaused = false
    }
    
    /// 拍照
    ///
    /// - Parameter completionHandler: 拍照成功的回调
    func takePhoto(completionHandler:@escaping (_ videoOutputFileURL: URL, _ imageData: Data)->()) {
    
    }
}


// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension VideoCaptureControllerssss: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
    
        let formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer)
        let mediaType = CMFormatDescriptionGetMediaType(formatDesc!)
        
        // 处理视屏
        if mediaType == kCMMediaType_Video {
         
            
            let output = (captureOutput as! AVCaptureVideoDataOutput)
            
            
            if isRecording {
            
                if CMSampleBufferDataIsReady(sampleBuffer) {
                    
                    if assetWriter == nil {
                        let url = videoOutputFileURL
                        
                        do {
                            assetWriter = try AVAssetWriter(url: url!, fileType: AVFileTypeMPEG4)
                            assetWriter?.shouldOptimizeForNetworkUse = true
                            
                            let videoWidth = output.videoSettings["Width"] as! Int
                            let videoHeight = output.videoSettings["Height"] as! Int

                            let setting = [AVVideoCodecKey : AVVideoCodecH264,
                                           AVVideoWidthKey : videoWidth,
                                           AVVideoHeightKey: videoHeight] as [String : Any]
                            
                            assetWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: setting)
                            assetWriter?.add(assetWriterInput!)
                            
                            
                            let orientation = UIDevice.current.orientation
                            assetWriterInput?.transform = transformForDeviceOrientation(orientation: orientation)
                                                    print(orientation.rawValue)
                        } catch {
                            
                        }
                    }
                    
                    
                    if assetWriter?.status == .unknown {
                        let startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                        assetWriter?.startWriting()
                        assetWriter?.startSession(atSourceTime: startTime)
                    } else if assetWriter?.status == .failed {
                        print( assetWriter?.error!.localizedDescription as Any)
                        
                    } else {
                        
                        if assetWriterInput!.isReadyForMoreMediaData {
                            assetWriterInput?.append(sampleBuffer)
                            print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
                        }
                    }
                }
            }
        }
        
        // 处理音频
        if mediaType == kCMMediaType_Audio {
        
        }
    }
    
    
    // 掉帧回调
    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
    
       
    }
}


// MARK: - AVCaptureAudioDataOutputSampleBufferDelegate
extension VideoCaptureControllerssss: AVCaptureAudioDataOutputSampleBufferDelegate {

// 我靠， 和 AVCaptureVideoDataOutputSampleBufferDelegate 的代理方法一样。我去！
//    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
//        
//    }
    
}

extension VideoCaptureControllerssss {
    
    
    func movConvertMP4(mediaURL: URL, convertHandler: @escaping (_ outputFileURL: URL)->()) {
        let mediaAsset = AVAsset(url: mediaURL)
        
        let exportSession = AVAssetExportSession(asset: mediaAsset, presetName: AVAssetExportPreset640x480)
        exportSession?.shouldOptimizeForNetworkUse = true
        exportSession?.outputFileType = AVFileTypeMPEG4
        
        let path = NSTemporaryDirectory()
        let filePath = path + "/" + Date().description + ".mp4"
        exportSession?.outputURL = URL(fileURLWithPath: filePath)
        
        exportSession?.exportAsynchronously {
            convertHandler((exportSession?.outputURL)!)
        }
    }
}


// MARK: - 拍照
extension VideoCaptureControllerssss {
    
    func captureStillImage(completionHandler:@escaping (_ outputFileURL: URL, _ imageData: Data)->()) {
        
        // 获取管道
        var videoConnection:AVCaptureConnection!
        
        for connection in stillImageOutput.connections {
            
            for port in (connection as! AVCaptureConnection).inputPorts {
                
                if ((port as! AVCaptureInputPort).mediaType as String) == AVMediaTypeVideo {
                    videoConnection = (connection as! AVCaptureConnection)
                    break
                }
            }
        }
        
        // 异步截图
        self.stillImageOutput.captureStillImageAsynchronously(from: videoConnection) { (imageSampleBuffer, error) in
            
            var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
            
            // 压缩照片
            imageData = UIImage(data: imageData!)?.compress(maxFileMemorySize: Memory(kb: 450))
            
            do {
                
                try imageData?.write(to: self.generatorStillImageOutputFileURL())
            } catch{
                print(error, "照片保存沙盒失败！ ")
            }
                completionHandler(self.generatorStillImageOutputFileURL(), imageData!)
        }
    }


    func generatorStillImageOutputFileURL() -> URL {
        let path = NSTemporaryDirectory()
        let stillImageFilePath = path + "/" + self.currentDateformateString + ".jpeg"
        return URL(fileURLWithPath: stillImageFilePath)
    }
    
    
    func generatorMovieOutputFileURL() -> URL {
        let path = NSTemporaryDirectory()
        let stillImageFilePath = path + "/" + self.currentDateformateString + ".mp4"
        return URL(fileURLWithPath: stillImageFilePath)
    }
    
    /// 获取当前时间的时间戳
    var  currentDateformateString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyyMMddHHmmss"
        return fmt.string(from: Date())
    }
    
    
    func transformForDeviceOrientation(orientation: UIDeviceOrientation) -> CGAffineTransform {
        
        var result: CGAffineTransform!
        switch orientation {
        case .landscapeRight:
            result = CGAffineTransform(rotationAngle: CGFloat(M_PI_2 * 3))
        case .landscapeLeft:
            result = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
            
        case .portraitUpsideDown:
            result = CGAffineTransform(rotationAngle: CGFloat(-M_PI))
            
            
        case .portrait,.faceUp, .faceDown:
            
            result = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
        //            result = CGAffineTransform.identity
        default: break
        }
        return result
    }
}
