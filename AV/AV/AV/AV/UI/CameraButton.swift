//
//  CameraButton.swift
//  AV
//
//  Created by Laughing on 2017/1/13.
//  Copyright © 2017年 Laughing. All rights reserved.
//

import UIKit


enum CameraButtonMode {
    case photo
    case movie
}

class CameraButton: UIButton {
    
    var circleLayer: CALayer = {
        let layer = CALayer()
        return layer
    }()
    
    var mode: CameraButtonMode {
        didSet{
            circleLayer.backgroundColor = (mode == .photo) ? UIColor.white.cgColor : UIColor.red.cgColor
        }
    }
    
    convenience init(mode: CameraButtonMode) {
        self.init(frame:CGRect.zero)
        self.mode = mode
    }
    
    override init(frame: CGRect) {
        self.mode = .photo
        super.init(frame: CGRect(x: 0, y: 0, width: 68, height: 68))
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.mode = .photo
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        
        
        setupUI()
        
    }
    
    func setupUI() {
    
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = self.frame.size.height/2
        self.tintColor = UIColor.clear
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 8;
        
        let circleColor = self.mode == .photo ? UIColor.white.cgColor : UIColor.red.cgColor
        
        circleLayer.bounds = self.bounds.insetBy(dx: 10, dy: 10)
        circleLayer.backgroundColor = circleColor
        circleLayer.position = CGPoint(x: circleLayer.bounds.midX, y: circleLayer.bounds.midX)
        circleLayer.cornerRadius = circleLayer.bounds.size.height/2
        layer.addSublayer(circleLayer)
    }
    
    override var isSelected: Bool {
        didSet{
            let group = CAAnimationGroup()
            let scale = CABasicAnimation(keyPath: "transform.scale")
            let cornerRadius = CABasicAnimation(keyPath: "cornerRadius")
            
            if isSelected  {
                
                scale.toValue = 0.6
                cornerRadius.toValue = circleLayer.bounds.size.height / 4
                
            } else {
                scale.toValue = 1
                cornerRadius.toValue = circleLayer.bounds.size.height / 2
            }
            
            circleLayer.setValue(scale.toValue, forKey: "transform.scale")
            circleLayer.setValue(cornerRadius.toValue, forKey: "cornerRadius")
            group.animations = [scale, cornerRadius]
            group.duration = 2
            
            circleLayer.add(group, forKey: nil)
        }
    }
}
