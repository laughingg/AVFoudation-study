////
////  VideoCaptureController.swift
////  HTSB
////
////  Created by Laughing on 2017/1/17.
////  Copyright © 2017年 Laughing. All rights reserved.
////
//
//import UIKit
//import AVFoundation
//
//protocol VideoCaptureControllerDelegate: NSObjectProtocol {
//    func videoCaptureStart()
//    func videoCaptureFinish(url: URL)
//}
//
//
//class VideoCaptureController: NSObject {
//    
//    weak var delegate: VideoCaptureControllerDelegate?
//
//    // 视频录制会话
//    private var _session = AVCaptureSession()
//    var session: AVCaptureSession {
//        return _session;
//    }
//    
//    var sessionPreset = AVCaptureSessionPreset1280x720 {
//        didSet{
//            if session.canSetSessionPreset(sessionPreset) {
//                session.sessionPreset = sessionPreset
//            }
//        }
//    }
//    
//    // MARK: - 队列
//    // 视频回话运行队列
////    fileprivate var sessionQueue:DispatchQueue = DispatchQueue(label: "com.laughing.videoCapture.session")
//    fileprivate var sessionQueue:DispatchQueue = DispatchQueue.main
//    
//    // 视屏队列
//     fileprivate var videoQueue: DispatchQueue = DispatchQueue(label: "com.laughing.videoCapture.video")
////    fileprivate var videoQueue: DispatchQueue = DispatchQueue.main
//    
//    // 音频队列
//    // fileprivate var audioQueue: DispatchQueue = DispatchQueue(label: "com.laughing.videoCapture.audio")
//    fileprivate var audioQueue: DispatchQueue = DispatchQueue.main
//    
//    
//    // MARK: - 资源操作
//    fileprivate var videoWriter: AVVideoWriter = VideoWriter()    // 音频和视频处理
//    fileprivate var audioWriter: AVAudioWriter = AudioWriter()    // 单纯的音频处理
//    
//    // MARK: - 输入
//    // MARK:  输入物理设备
//    // 当前使用的摄像头
//    var camera: AVCaptureDevice? {
//        return videoInput?.device
//    }
//    
//    // 麦克风
//    var microphone: AVCaptureDevice? {
//        return audioInput?.device
//    }
//    
//    fileprivate var videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
//    fileprivate var audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
//    
//    // MARK:  输入
//    // 激活的视屏输入
//    fileprivate lazy var videoInput: AVCaptureDeviceInput? = {
//        
//        do {
//            let videoInput = try AVCaptureDeviceInput(device: self.videoDevice)
//            return videoInput
//        } catch {
//            print(error, "device cannot be opened because it is no longer available or because it is in use!")
//            return nil
//        }
//    }()
//    
//    // 音频输入
//    fileprivate lazy var audioInput: AVCaptureDeviceInput? = {
//        do {
//            let audioInput = try AVCaptureDeviceInput(device: self.audioDevice)
//            return audioInput
//        } catch{
//            print(error, "device cannot be opened because it is no longer available or because it is in use!")
//            return nil
//        }
//    }()
//    
//    
//    // MARK: - 输出
//    fileprivate lazy  var videoDataOutput: AVCaptureVideoDataOutput = {
//        // 视屏
//        let output = AVCaptureVideoDataOutput()
//        output.alwaysDiscardsLateVideoFrames = true
//        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: kCVPixelFormatType_32BGRA]
//        return output
//    }()                                                                                                     // 视频
//    
//    fileprivate lazy var audioDataOutput: AVCaptureAudioDataOutput = AVCaptureAudioDataOutput()             // 音频
//    fileprivate lazy var stillImageOutput: AVCaptureStillImageOutput = {
//        
//        let output = AVCaptureStillImageOutput()
//        output.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
//        return output
//    }()                                                                                                     // 静态图片
//    
//    fileprivate lazy var faceMetadataOutput: AVCaptureMetadataOutput = {
//    
//        let  output = AVCaptureMetadataOutput()
//        if output.availableMetadataObjectTypes.contains(where: { (type) -> Bool in
//            return (type as! String) == AVMetadataObjectTypeFace
//        }) {
//            output.metadataObjectTypes = [AVMetadataObjectTypeFace]
//        }
//        return output
//    }()                                                                                                    // 人脸识别
//    
//    // MARK: - 预览
//    // 视频预览图层
//    var previewLayer: AVCaptureVideoPreviewLayer?
//
//    // MARK: methods
//    override init() {
//        super.init()
//        
//         setupSession()
//    }
//    
//    private func setupSession() {
//        
//        guard camerasCount > 0  else {
//             print("当前设备没有摄像头，不能进行拍照或者录制视屏操作。")
//            return
//        }
//        
//        setupSessionInputs()
//        
//        setupSessionOutputs()
//        
//        // 获取预览视图
//        self.previewLayer =  AVCaptureVideoPreviewLayer(session: self.session)
//    }
//    
//    
//    private func setupSessionInputs() {
//        // 添加视屏输入
//        if session.canAddInput(videoInput) {
//            session.addInput(videoInput)
//        }
//        
//        if session.canAddInput(audioInput) {
//            session.addInput(audioInput)
//        }
//    }
//    
//    
//    private func setupSessionOutputs() {
//    
//        // 视屏
//        videoDataOutput.setSampleBufferDelegate(self, queue: videoQueue)
//        if session.canAddOutput(videoDataOutput) {
//            session.addOutput(videoDataOutput)
//        }
//        
//        // 视屏拍摄的方向设置 
//        // videoDataOutput 没有添加到 session 之前 connection 对象是还没有创建的。
//        let videoConnetion = videoDataOutput.connection(withMediaType: AVMediaTypeVideo)
//        videoConnetion?.videoOrientation = .portrait
//        
//        // 音频
//        audioDataOutput.setSampleBufferDelegate(self, queue: audioQueue)
//        if session.canAddOutput(audioDataOutput) {
//            session.addOutput(audioDataOutput)
//        }
//        
//        // 静态图片获取
//        if session.canAddOutput(stillImageOutput) {
//            session.addOutput(stillImageOutput)
//        }
//        
//        // 人脸识别
//        if session.canAddOutput(faceMetadataOutput) {
//            session.addOutput(faceMetadataOutput)
//        }
//        // 人脸识别在主队列，主要是考虑到，人脸识别会用到系统底层的东西。
//        faceMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
//    }
//}
//
//
//// MARK: - AVCaptureMetadataOutputObjectsDelegate ---- 人脸检测
///// 人脸检测
//extension VideoCaptureController : AVCaptureMetadataOutputObjectsDelegate {
//    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
//        
//         print(metadataObjects)
//        
//        guard metadataObjects.count > 0 else {
//            return
//        }
//        
//        print(metadataObjects[0])
//        
//    }
//}
//
//
//// MARK: - session 操作
///// session 操作
//extension VideoCaptureController {
//    
//    /// 开启会话
//    func sessionStartRunning() {
//        if !session.isRunning {
//            sessionQueue.async {
//                self.session.startRunning()
//            }
//        }
//    }
//    
//    
//    /// 停止回话
//    func sessionStopRunning() {
//        if session.isRunning {
//            sessionQueue.async {
//                self.session.stopRunning()
//            }
//        }
//    }
//    
//    
//    /// session 配置操作
//    ///
//    /// - Parameter config: 配置代码块
//    func sessionConfiguration(config:@escaping (_ session: AVCaptureSession)->()) {
//        
//        sessionQueue.async {
//            self.session.beginConfiguration()
//            config(self.session)
//            self.session.commitConfiguration()
//        }
//    }
//}
//
//// MARK: - 视屏录制
///// 视屏录制
//extension VideoCaptureController {
//    
//    /// 开始录制
//    ///
//    /// - Parameter url: 视屏保存的 url  
//    /// url 为 nil 的时候，给默认给定一个 url
//    func startRecording(url: URL?) {
//        videoQueue.async {
//            self.videoWriter.startWriting(url: url)
//            
//            self.delegate?.videoCaptureStart()
//        }
//    }
//    
//    /// 停止录制
//    func stopRecording() {
//        videoQueue.async {
//            self.videoWriter.stopWriting(finish: { (url) in
//                    self.delegate?.videoCaptureFinish(url: url)
//            })
//            
//            
//        }
//    }
//    
//    /// 暂定录制
//    // TODO: pauseRecording 功能未实现
//    func pauseRecording() {
//        videoQueue.async {
//            self.videoWriter.pauseWriting()
//        }
//    }
//    
//    /// 启动录制（从暂停状态恢复）
//    // TODO: resumeRecording 功能未实现
//    func resumeRecording() {
//        videoQueue.async {
//            self.videoWriter.resumeWriting()
//        }
//    }
//}
//
//// MARK: - 拍照
///// 拍照
//extension VideoCaptureController {
//    
//    func captureStillImage(url: URL?, completionHandler:@escaping (_ outputFileURL: URL, _ imageData: Data)->()) {
//        
//        if url == nil {
//        
//        }
//        
//        // 获取管道
//        var videoConnection:AVCaptureConnection!
//        
//        for connection in stillImageOutput.connections {
//            
//            for port in (connection as! AVCaptureConnection).inputPorts {
//                if ((port as! AVCaptureInputPort).mediaType as String) == AVMediaTypeVideo {
//                    videoConnection = (connection as! AVCaptureConnection)
//                    break
//                }
//            }
//        }
//        
//        // 异步截图管道中的视屏流
//        self.stillImageOutput.captureStillImageAsynchronously(from: videoConnection) { (imageSampleBuffer, error) in
//            
//            var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
//            
//            // 压缩照片
//            imageData = UIImage(data: imageData!)?.compress(maxFileMemorySize: Memory(kb: 450))
//            
//            do {
//                try imageData?.write(to: generatorStillImageOutputFileURL())
//            } catch{
//                print(error, "照片保存沙盒失败！ ")
//            }
//            completionHandler(generatorStillImageOutputFileURL(), imageData!)
//        }
//    }
//}
//
//
//
//// MARK: - AVCaptureAudioDataOutputSampleBufferDelegate
///// 音频
//extension VideoCaptureController: AVCaptureAudioDataOutputSampleBufferDelegate {
//    
//}
//
//// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
///// 视频
//extension VideoCaptureController: AVCaptureVideoDataOutputSampleBufferDelegate {
//
//
//    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
//        
//        let formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer)
//        let mediaType = CMFormatDescriptionGetMediaType(formatDesc!)
//        
//        videoWriter.process(captureOutput, didOutputSampleBuffer: sampleBuffer, from: connection)
//        
//        // 单独处理视屏
//        if mediaType == kCMMediaType_Video {
//
//        }
//        
//        // 单独处理音频
//        if mediaType == kCMMediaType_Audio {
//            
//        }
//    }
//}
//
//
//extension VideoCaptureController {
//    
//    
//    
//    
//    func transformForDeviceOrientation(orientation: UIDeviceOrientation) -> CGAffineTransform {
//        
//        var result: CGAffineTransform!
//        switch orientation {
//        case .landscapeRight:
//            result = CGAffineTransform(rotationAngle: CGFloat(M_PI_2 * 3))
//        case .landscapeLeft:
//            result = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
//            
//        case .portraitUpsideDown:
//            result = CGAffineTransform(rotationAngle: CGFloat(-M_PI))
//            
//            
//        case .portrait,.faceUp, .faceDown:
//            
//            result = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
////                    result = CGAffineTransform.identity
//        default: break
//        }
//        return result
//    }
//    
//    func updateVideoOrientation() {
//        let videoConnetion = videoDataOutput.connection(withMediaType: AVMediaTypeVideo)
//        videoConnetion?.videoOrientation = .portrait
//    }
//}
//
//
//extension VideoCaptureController {
//    
//    func checkVideoAuthorizationStatus() {
//        
//        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
//        
//        switch status {
//            case .authorized: break       // 已经授权
//            case .denied:           // 否认 明确拒绝用户访问
//                break
//            case .notDetermined:    // 不确定 尚未选择关于客户端是否可以访问硬件
//                
//                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (ss) in
//                    
//                })
//                break
//            case .restricted:       // 限制 客户端未被授权访问硬件的媒体类型。用户不能改变客户的状态,可能由于活跃的限制,如家长控制。
//                break
//        }
//    }
//
//    
//    ///能否切换摄像头
//    var canSwitchCameras: Bool {
//        return camerasCount > 1
//    }
//    
//    /// 摄像头个数
//    var camerasCount: Int {
//        return AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).count
//    }
//    
//    /// 切换摄像头
//    func switchCamera() {
//        
//        if !canSwitchCameras {
//            print("不能切换摄像头， 摄像头的个数只有 \(camerasCount)个")
//            return
//        }
//        
//        
//        // 获取闲置设备
//        let device = self.inactiveVideoDevice()
//        
//        var input: AVCaptureDeviceInput!
//        
//        do {
//            input =  try AVCaptureDeviceInput(device: device )
//        } catch {
//            print(error)
//        }
//        
//        self.sessionConfiguration { session in
//            
//            // 移除之前的摄像头
//            session.removeInput(self.videoInput)
//            
//            // 添加新的摄像头
//            if session.canAddInput(input) {
//                
//                session.addInput(input)
//                self.videoInput = input
//            } else {
//                // 不能切换就添加之前的
//                session.addInput(self.videoInput)
//            }
//            
//            DispatchQueue.main.async {
//                self.updateVideoOrientation()
//            }
//        }
//        
//        
//        
//    }
//    
//    /// 获取闲置摄像头
//    func inactiveVideoDevice() -> AVCaptureDevice {
//        if self.videoInput?.device.position == .front {
//            return AVCaptureDevice.camera(position: .back)!
//        } else {
//            return AVCaptureDevice.camera(position: .front)!
//        }
//    }
//    
//    /// 激活了的摄像头
//    func activeVideoDevice() -> AVCaptureDevice? {
//        return videoInput?.device
//    }
//}
//
