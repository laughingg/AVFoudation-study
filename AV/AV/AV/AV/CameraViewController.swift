//
//  CameraViewController.swift
//  AV
//
//  Created by Laughing on 2017/1/12.
//  Copyright © 2017年 Laughing. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    var camera: CameraController!
    var btn: CameraButton!

    
    var captureSession: AVCaptureSession!
    var output: AVCaptureStillImageOutput!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btn = CameraButton()
        view.addSubview(btn)
        btn.frame.origin.x = 100
        btn.frame.origin.y = 100
        btn.mode = .movie
        
        btn.addTarget(self, action: #selector(btnSelected), for: .touchUpInside)
        camera = CameraController()
    }
    
    
    func btnSelected(btn: UIButton) {
        btn.isSelected = !btn.isSelected
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        camera.sessionStartRunning()
        
        let previewLayer = camera.previewLayer
        previewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(camera.previewLayer!, at: 0)
        view.backgroundColor = UIColor.black
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
//        camera.sessionStopRunning()
        
    }
    
    
    
    func play(){
    }
    
   
}
