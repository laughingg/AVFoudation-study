//
//  ViewController.swift
//  Playback and Editing
//
//  Created by 肖卓鸿 on 2017/6/23.
//  Copyright © 2017年 肖卓鸿. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var urlAsset : AVURLAsset?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let path = Bundle.main.path(forResource: "dog.mp4", ofType: nil)
        let url = URL(fileURLWithPath: path!)
        urlAsset = AVURLAsset(url: url)
        
        
        var assetReader: AVAssetReader?;
        do {
            assetReader = try AVAssetReader(asset: urlAsset!)
            print(assetReader!.asset)
            print(assetReader!.status)
            print(assetReader!.timeRange)
        } catch {
            print(error);
        }
        
        
        print(assetReader!);
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

