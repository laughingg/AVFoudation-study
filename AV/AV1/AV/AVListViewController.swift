//
//  AVListViewController.swift
//  AV
//
//  Created by Laughing on 2017/1/10.
//  Copyright © 2017年 Laughing. All rights reserved.
//

import UIKit

class AVListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet{
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    var titles: [String] = []
    var demoTitles: [String] = []
    var demoVCs: [UIViewController] = []
    var vcs: [UIViewController] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        demoTitles.append("Camera")
        demoVCs.append(CameraViewController())
        
        titles.append("QRScan")
        titles.append("FaceScan")
        titles.append("AVCaptureStillImageOutput")
        titles.append("CaptureVideoDataOutput")
        titles.append("AVCaptureMovieFileOutput")
        
        vcs.append(QRScanViewController())
        vcs.append(FaceScanViewController())
        vcs.append(AVCaptureStillImageOutputViewController())
        vcs.append(AVCaptureVideoDataOutputViewController())
        vcs.append(AVCaptureMovieFileOutputViewController())
    }
}

extension AVListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return demoTitles.count
        } else {
             return titles.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        }
        
        if indexPath.section == 0 {
            cell?.textLabel?.text = demoTitles[indexPath.row]
        }
        
        if indexPath.section == 1 {
            cell?.textLabel?.text = titles[indexPath.row]
        }
        
        return cell!
    }
}

extension AVListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var vc: UIViewController!
        if indexPath.section == 0 {
            vc = demoVCs[indexPath.row]
            vc.title = demoTitles[indexPath.row]
        }
        
        if indexPath.section == 1 {
            vc = vcs[indexPath.row]
            vc.title = titles[indexPath.row]
        }
        vc.view.backgroundColor = UIColor.white
        

        self.navigationController?.pushViewController(vc, animated: true)
    }
}
