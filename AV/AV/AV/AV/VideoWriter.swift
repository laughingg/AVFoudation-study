//
//  VideoWriter.swift
//  HTSB
//
//  Created by Laughing on 2017/1/17.
//  Copyright © 2017年 Laughing. All rights reserved.
//

import UIKit
import AVFoundation

class VideoWriter: NSObject {

    fileprivate var isWriting: Bool = false
    // 暂停录制
    fileprivate var isWritingPaused: Bool = false
    
    fileprivate var assetWriter: AVAssetWriter?
    fileprivate var assetWriterInput: AVAssetWriterInput?
    
    fileprivate var videoOutputFileURL: URL?
    
    override init() {
        super.init()
    }
    

    
    /// 处理视频录制
    ///
    /// - Parameters:
    ///   - captureOutput: captureOutput description
    ///   - sampleBuffer: sampleBuffer description
    ///   - connection: connection description
    func process(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
    
        if isWriting {
            
            let formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer)
            let mediaType = CMFormatDescriptionGetMediaType(formatDesc!)
            
            if CMSampleBufferDataIsReady(sampleBuffer) {
                
                // 非视屏的时候直接返回
                guard mediaType == kCMMediaType_Video, let output = (captureOutput as? AVCaptureVideoDataOutput) else {
                    return
                }
                
                // 初始化
                if assetWriter == nil {
   
                    // 处理 url
                    var url : URL!
                    if videoOutputFileURL != nil {
                        url = videoOutputFileURL
                    } else {
                        url = generatorMovieOutputFileURL()
                        videoOutputFileURL = url
                    }
                    
                    
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
                        
                        // 视屏方向修复
//                        let orientation = UIDevice.current.orientation
//                        assetWriterInput?.transform = transformForDeviceOrientation(orientation: orientation)
//                        print(orientation.rawValue)
                    } catch {
                        print( error, "文件写入失败！")
                    }
                }
                
                
                // 开始写入
                if assetWriter?.status == .unknown {
                    let startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                    assetWriter?.startWriting()
                    assetWriter?.startSession(atSourceTime: startTime)
                } else if assetWriter?.status == .failed {
                    print( assetWriter?.error!.localizedDescription as Any)
                    
                } else {
                    
                    // 附加数据
                    if assetWriterInput!.isReadyForMoreMediaData {
                        assetWriterInput?.append(sampleBuffer)
//                        print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
                    }
                }
            }
        }
    
    }
}

// MARK: - Writer 操作
/// Writer 操作
extension VideoWriter {

    func startWriting(url: URL?) {
        
        isWriting = true
        videoOutputFileURL = url
        assetWriter = nil
    }
    
    func stopWriting(finish: @escaping (_ url: URL)->()) {
        
        isWriting = false
        
        // 完成写入
        assetWriter?.finishWriting {
            
            if let url = self.videoOutputFileURL {
                finish(url)
            }

             self.videoOutputFileURL = nil
        }
    }
    
    /// 暂定录制
    func pauseWriting() {
        isWritingPaused = true
    }
    
    /// 启动录制（从暂停状态恢复）
    func resumeWriting() {
        isWritingPaused = false
    }
}


extension VideoWriter {
    
    func generatorStillImageOutputFileURL() -> URL {
        let path = NSTemporaryDirectory()
        let stillImageFilePath = path + self.currentDateformateString + ".jpeg"
        return URL(fileURLWithPath: stillImageFilePath)
    }
    
    
    func generatorMovieOutputFileURL() -> URL {
        let path = NSTemporaryDirectory()
        let stillImageFilePath = path + self.currentDateformateString + ".mp4"
        return URL(fileURLWithPath: stillImageFilePath)
    }
    
    /// 获取当前时间的时间戳
    var  currentDateformateString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyyMMddHHmmss"
        return fmt.string(from: Date())
    }
}
