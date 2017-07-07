//
//  AVCaptureVideoDataOutputViewController.swift
//  AV
//
//  Created by Laughing on 2017/1/10.
//  Copyright © 2017年 Laughing. All rights reserved.
//

import UIKit
import AVFoundation

class AVCaptureVideoDataOutputViewController: UIViewController {

    var captureSession: AVCaptureSession!
    
    var input: AVCaptureDeviceInput!
    
    var startBtn: UIButton!
    var stopBtn: UIButton!
    var pauseBtn: UIButton!
    var resumeBtn: UIButton!
    
    // 正在录制
    var isRecording: Bool = false
    // 暂停录制
    var isRecordingPaused: Bool = false
    var videoFilePath: String?
    var pauseTime: CMTime?
    
    
    var assetWriter: AVAssetWriter?
    var assetWriterInput: AVAssetWriterInput?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupUI()
        
        setupCaptureSession()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
}


extension AVCaptureVideoDataOutputViewController {

    // 开始录制
    func startRecording() {
        isRecording = true
        isRecordingPaused = false
    }
    
    // 停止录制
    func stopRecording() {
        isRecording = false
        isRecordingPaused = false
        
        assetWriter?.finishWriting {
            print("视频录制完成。。。。")
            
            self.videoFilePath = nil
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
    
    
    func setupUI() {
        
        let startBtn = UIButton()
        startBtn.frame = CGRect(x: 10, y: 74, width: 50, height: 30 )
        startBtn.backgroundColor = UIColor.red
        startBtn.setTitleColor(UIColor.green, for: .selected)
        startBtn.setTitle("开始", for: .normal)
        startBtn.addTarget(self, action: #selector(startRecording), for: .touchUpInside)
        view.addSubview(startBtn)
        self.startBtn = startBtn
        
        
        let stopBtn = UIButton()
        stopBtn.frame = CGRect(x: 10, y: 74 + 40 + 30, width: 50, height: 30 )
        stopBtn.backgroundColor = UIColor.red
        stopBtn.setTitle("停止", for: .normal)
        stopBtn.addTarget(self, action: #selector(stopRecording), for: .touchUpInside)
        view.addSubview(stopBtn)
        self.stopBtn = stopBtn
        
        
        let pauseBtn = UIButton()
        pauseBtn.frame = CGRect(x: 10, y: 74 + 40 + 30 + 40 + 30, width: 50, height: 30 )
        pauseBtn.backgroundColor = UIColor.red
        pauseBtn.setTitle("暂停", for: .normal)
        pauseBtn.addTarget(self, action: #selector(pauseRecording), for: .touchUpInside)
        view.addSubview(pauseBtn)
        self.pauseBtn = pauseBtn
        
        
        let resumeBtn = UIButton()
        resumeBtn.frame = CGRect(x: 10, y: 74 + 40 + 30 + 40 + 30 + 40 + 30, width: 50, height: 30 )
        resumeBtn.backgroundColor = UIColor.red
        resumeBtn.setTitle("恢复", for: .normal)
        resumeBtn.addTarget(self, action: #selector(resumeRecording), for: .touchUpInside)
        view.addSubview(resumeBtn)
        self.resumeBtn = resumeBtn
    }
    
    
    func setupCaptureSession() {
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPreset1280x720
        
        // AVCaptureSessionPreset
        /*
            AVCaptureSessionPresetPhoto             : 全分辨率照片质量的输出
         
            AVCaptureSessionPresetHigh              : 高质量的视频和音频输出
            AVCaptureSessionPresetMedium            : 适合 wifi 分享
            AVCaptureSessionPresetLow               : 适合 3g 分享
         
            AVCaptureSessionPreset320x240  (Mac)    : 320 x240像素视频输出
            AVCaptureSessionPreset352x288           : CIF(352 x288像素)视频输出质量
            AVCaptureSessionPreset640x480           : VGA(640 x480像素)视频输出质量
            AVCaptureSessionPreset960x540  (Mac)    : 四分之一 高清(960 x540像素)视频输出质量
            AVCaptureSessionPreset1280x720          : 720p 质量(1280 x720像素)视频输出
            AVCaptureSessionPreset1920x1080 (iOS)   : 1080p 视频(1920 x1080像素)视频输出
            AVCaptureSessionPreset3840x2160 (iOS9)  : 2160p(也称为UHD或4 k)质量(3840 x2160像素)视频输出
            AVCaptureSessionPresetiFrame960x540     : 质量达到960 x540的 H.264 视屏，ACC 音频大约 30Mbits/sec
            AVCaptureSessionPresetiFrame1280x720    : 质量达到1280x720的 H.264 视屏，ACC 音频大约 40Mbits/sec

            AVCaptureSessionPresetInputPriority (iOS7) : 不控制音频和视频输出。 设置这个值表明，不支持任何session预设值，改变activeFormat 属性设置。当你修改，session 会自动修正这个值。session 已经放弃任何输入和输出的改变。
         */
//        if captureSession.canSetSessionPreset(AVCaptureSessionPresetMedium) {
//            captureSession.sessionPreset = AVCaptureSessionPreset1280x720
//        }
        // 捕获设备
        let inputDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        // 输入
        do {
            input = try AVCaptureDeviceInput(device: inputDevice)
        } catch {
            print(error)
        }
        
        // 输出
        let output = AVCaptureVideoDataOutput()
        
        let dict = output.recommendedVideoSettingsForAssetWriter(withOutputFileType: AVFileTypeMPEG4)
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: kCVPixelFormatType_32BGRA]
        output.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        
        let connection1 = output.connection(withMediaType: AVMediaTypeVideo)
        
        // 装配
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        
    
        
        
        
        switchCamera()
        
        let connection = output.connection(withMediaType: AVMediaTypeVideo)
        connection?.videoOrientation = .portrait
        
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = self.view.bounds
        self.view.layer.insertSublayer(previewLayer!, at: 0)
    }
}

extension AVCaptureVideoDataOutputViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        let formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer)
        let mediaType = CMFormatDescriptionGetMediaType(formatDesc!)
        
//        if mediaType == kCMMediaType_Video {
//        
//        }
        
        // 开始录制
        if isRecording && isRecordingPaused{
        
            // 暂停录制
            print("暂停录制。。。")
            
            // 获取暂停录制的时间
            if pauseTime == nil {
                
                // 计算暂停的时间
                let time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                pauseTime = time
            }
            
        
        } else if isRecording && !isRecordingPaused {
            
            print("开始录制。。。")
            
            // url
            if videoFilePath == nil {
                let path = NSTemporaryDirectory()
                let filePath = path + "/" + Date().description + ".mov"
                videoFilePath =  filePath
                print(filePath)
            }
            
            
            
            
            if CMSampleBufferDataIsReady(sampleBuffer) {
                
                 let output = (captureOutput as! AVCaptureVideoDataOutput)
                if assetWriter == nil {
                    let url = URL(fileURLWithPath: videoFilePath!)
                    
                    do {
                        assetWriter = try AVAssetWriter(url: url, fileType: AVFileTypeMPEG4)
                        assetWriter?.shouldOptimizeForNetworkUse = true
                        
                        let videoWidth = output.videoSettings["Width"] as! Int
                        let videoHeight = output.videoSettings["Height"] as! Int
//                        let setting = (captureOutput as! AVCaptureVideoDataOutput).videoSettings
                        let setting = [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : videoWidth, AVVideoHeightKey: videoHeight] as [String : Any]
                        
                        
                        assetWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: setting as [String : Any]?)
                        
                        
                        assetWriter?.add(assetWriterInput!)
                        
                        
//                        let orientation = UIDevice.current.orientation
//                        assetWriterInput?.transform = transformForDeviceOrientation(orientation: orientation)
//                        print(orientation.rawValue)
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
            
        } else {
            print("停止录制。。。")
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        print(#function, "丢弃了新的帧！", Date())
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
            captureSession.removeInput(self.input)
            
            // 添加新的摄像头
            if session.canAddInput(input) {
                
                session.addInput(input)
                self.input = input
            } else {
                // 不能切换就添加之前的
                session.addInput(input)
            }
        }
        
    }
    
    /// session 配置操作
    ///
    /// - Parameter config: 配置代码块
    func sessionConfiguration(config:(_ session: AVCaptureSession)->()) {
        
        self.captureSession.beginConfiguration()
        config(self.captureSession)
        self.captureSession.commitConfiguration()
    }
    
    /// 获取闲置摄像头
    func inactiveVideoDevice() -> AVCaptureDevice {
        if self.input?.device.position == .front {
            return AVCaptureDevice.camera(position: .back)!
        } else {
            return AVCaptureDevice.camera(position: .front)!
        }
    }
    
    /// 激活了的摄像头
    func activeVideoDevice() -> AVCaptureDevice {
        return (input?.device)!
    }
}
