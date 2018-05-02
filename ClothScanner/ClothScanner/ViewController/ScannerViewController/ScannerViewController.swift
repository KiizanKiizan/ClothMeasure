//
//  ScannerViewController.swift
//  ClothScanner
//
//  Created by 岩井 宏晃 on 2018/04/30.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import UIKit

class ScannerViewController: UIViewController, SocketHandlerDelegate, BarcodeReaderViewControllerDelegate {

    private let socketHandler = SocketHandler()
    private var barcodeReaderVc: BarcodeReaderViewController!
    private let calibrationInterval: TimeInterval = 5.0
    private var startReadDate: Date?
    private var qrcodeFrame = CGRect.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? BarcodeReaderViewController {
            vc.delegate = self
            barcodeReaderVc = vc
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        barcodeReaderVc.start()
        socketHandler.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        barcodeReaderVc.stop()
        socketHandler.delegate = nil
    }
    
    func socketHandlerDidConnect(_ handler: SocketHandler) {
    }
    
    func socketHandlerRecievedScanRequest(_ handler: SocketHandler) {
        let image = UIImage(named: "dummy")!
        socketHandler.sendImage(image: image) { (error) in
            print("send")
        }
    }
    
    func barcodeReaderViewController(_ vc: BarcodeReaderViewController, DidReadBarcode text: String, frame: CGRect) {
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
