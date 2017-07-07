//
//  AVCaptureMovieFileOutputViewController.swift
//  AV
//
//  Created by Laughing on 2017/1/10.
//  Copyright © 2017年 Laughing. All rights reserved.
//

import UIKit
import AVFoundation

class AVCaptureMovieFileOutputViewController: UIViewController {

    var captureSession: AVCaptureSession!
    var output: AVCaptureMovieFileOutput!
    
    var startBtn: UIButton!
    var stopBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        setupCaptureSession()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    deinit {
        print(#function, self)
    }
}


extension AVCaptureMovieFileOutputViewController {
    
    
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
    }
    

    func setupCaptureSession() {
        
        captureSession = AVCaptureSession()
        
        // 捕获设备
        let inputDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        // 输入
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: inputDevice)
        } catch {
            print(error)
        }
        
        // 输出
        let output = AVCaptureMovieFileOutput()
        self.output = output
        
        // 装配
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
 
//        let outputConnection = output.connection(withMediaType: AVMediaTypeVideo)
//        outputConnection?.videoOrientation = .portrait
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = self.view.bounds
        
        self.view.layer.insertSublayer(previewLayer!, at: 0)
    }
}


extension AVCaptureMovieFileOutputViewController {

    // 停止录制
    func stopRecording(btn: UIButton) {
        self.startBtn.isSelected = false
        
        self.output.stopRecording()
    }
    
    // 开始录制
    func startRecording(btn: UIButton) {
        
        if output.isRecording {
            return
        }
        
        
        self.output.startRecording(toOutputFileURL: videoOutputFileURL(), recordingDelegate: self)
        self.startBtn.isSelected = true
    }
    
    func videoOutputFileURL() -> URL {
    
        let path = NSTemporaryDirectory()
        let filePath = path + "/" + Date().description + ".mov"
        let url = URL(fileURLWithPath: filePath)
        return url
    }
}


extension AVCaptureMovieFileOutputViewController: AVCaptureFileOutputRecordingDelegate {
    
    // 开始录制的时候调用
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print(#function)
    }

    // 结束录制的时候调用
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        print(#function)
    }
}
