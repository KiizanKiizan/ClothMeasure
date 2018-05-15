//
//  ScannerViewController.swift
//  ClothScanner
//
//  Created by 岩井 宏晃 on 2018/04/30.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import UIKit

class ScannerViewController: UIViewController, SocketHandlerDelegate, CaptureViewControllerDelegate {

    private let socketHandler = SocketHandler()
    private var captureVc: CaptureViewController!
    private let calibrationInterval: TimeInterval = 1.0
    private var startReadDate: Date?
    private var qrcodeFrame = CGRect.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CaptureViewController {
            vc.delegate = self
            captureVc = vc
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureVc.start()
        socketHandler.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        captureVc.stop()
        socketHandler.delegate = nil
    }
    
    func socketHandlerDidConnect(_ handler: SocketHandler) {
    }
    
    func socketHandlerRecievedScanRequest(_ handler: SocketHandler) {
        captureVc.capture { (image) in
            if let _image = image {
                self.socketHandler.sendImage(image: _image) { (error) in
                    print("send")
                }
            }
        }
    }
    
    func socketHandlerRecievedCalibrationRequest(_ handler: SocketHandler) {
        captureVc.calibrate { (calibrateLength) in
            self.socketHandler.sendCalibrationInfo(calibrateLength, completion: { (error) in
                print("send calibration info")
            })
        }
    }
    
    func captureViewController(_ vc: CaptureViewController, DidReadBarcode text: String, frame: CGRect) {
        if !socketHandler.connected {
            if startReadDate == nil {
                startReadDate = Date()
            }
            
            if let startDate = startReadDate {
                if Date().timeIntervalSince1970 - startDate.timeIntervalSince1970 > calibrationInterval {
                    socketHandler.connect(ipAddress: text)
                    qrcodeFrame = frame
                    vc.readBarcode = false
                }
            }
        }
    }
}
