//
//  ViewController.swift
//  ClothScanController
//
//  Created by 岩井 宏晃 on 2018/04/29.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, SocketHandlerDelegate {
    @IBOutlet weak var QRImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    let scanSocketHandler = SocketHandler(portNumber: 8080)
    let sendSocketHandler = SocketHandler(portNumber: 8008)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let ipAddress = IPAddress.getWiFiAddress() {
            QRImageView.image = QRCodeMaker.creatQRCode(text: ipAddress)
        }
        
        scanSocketHandler.delegate = self
        sendSocketHandler.delegate = self
        scanSocketHandler.start()
    }
    
    func socketHandlerDidConnect(_ handler: SocketHandler) {
        if scanSocketHandler === handler {
            titleLabel.text = "測定アプリと接続"
            sendSocketHandler.start()
        }
        if sendSocketHandler === handler {
            let vc = ScanViewController.createViewController(scanSocketHandler: scanSocketHandler, sendSocketHandler: sendSocketHandler)
            present(vc, animated: true, completion: nil)
        }
    }
}
