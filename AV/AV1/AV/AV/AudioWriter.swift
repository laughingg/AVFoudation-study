//
//  AudioWriter.swift
//  HTSB
//
//  Created by Laughing on 2017/1/17.
//  Copyright © 2017年 Laughing. All rights reserved.
//

import UIKit
import AVFoundation

class AudioWriter: NSObject {

    func process(_ captureOutput: AVCaptureAudioDataOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        print(#function, self)
    }
}
