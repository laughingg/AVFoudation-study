//
//  CameraController.swift
//  AV
//
//  Created by Laughing on 2017/1/12.
//  Copyright © 2017年 Laughing. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: CaptureController {
    
    weak var delegate: AVCaptureFileOutputRecordingDelegate?
    
    // 视频文件输出
    var movieFileOutput: AVCaptureMovieFileOutput!
    var movieOutputFileURL: URL?
    
    // 静态图片输出
    var stillImageOutput: AVCaptureStillImageOutput!
    var stillImageOutputFileURL: URL?
    
    
    override func setupSessionOutputs() {
        super.setupSessionOutputs()
        
        sessionPreset = AVCaptureSessionPreset1280x720
        
        // 静态图片输出
        stillImageOutput = AVCaptureStillImageOutput()
        if session.canAddOutput(stillImageOutput) {
            session.addOutput(stillImageOutput)
        }
        stillImageOutput.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
        
        movieFileOutput = AVCaptureMovieFileOutput()
        if session.canAddOutput(movieFileOutput) {
            session.addOutput(movieFileOutput)
        }
    }
}

// MARK: - 拍照
extension CameraController {
    
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
           
            imageData = UIImage(data: imageData!)?.imageCompress(maxFileMemorySize: Memory(kb: 450))
            
            if let url = self.stillImageOutputFileURL {
                do {
                    
                    try imageData?.write(to: url)
                } catch{
                    print(error, "照片保存沙盒失败！ ")
                }
                
               completionHandler(url, imageData!)
                
            } else {
                
                self.stillImageOutputFileURL = generatorStillImageOutputFileURL()
                do {
                    try imageData?.write(to: self.stillImageOutputFileURL!)
                    
                } catch{
                    print(error, "照片保存沙盒失败！ ")
                }
                
                
                completionHandler(self.stillImageOutputFileURL!, imageData!)
            }
        }
    }
}


// MARK: - quick time movie recording
extension CameraController {
    /// 开始录制
    ///
    /// - Parameter url: 视屏保存的 url
    func startRecording(url: URL) {
        
        movieFileOutput.startRecording(toOutputFileURL: url, recordingDelegate: self.delegate)
    }
    
    /// 停止录制
    func stopRecording() {
        movieFileOutput.stopRecording()
    }
}


//extension CameraController {
//    
//    func generatorMovieOutputFileURL() -> URL {
//        let path = NSTemporaryDirectory()
//        let stillImageFilePath = path + "/" + self.currentDateformateString + ".mov"
//        return URL(fileURLWithPath: stillImageFilePath)
//    }
//    
//    
//    func generatorStillImageOutputFileURL() -> URL {
//        let path = NSTemporaryDirectory()
//        let stillImageFilePath = path + "/" + self.currentDateformateString + ".jpeg"
//        return URL(fileURLWithPath: stillImageFilePath)
//    }
//    
//    /// 获取当前时间的时间戳
//    var  currentDateformateString: String {
//        let fmt = DateFormatter()
//        fmt.dateFormat = "yyyyMMddHHmmss"
//        return fmt.string(from: Date())
//    }
//}




