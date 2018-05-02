//
//  ViewController.swift
//  ClothScanner
//
//  Created by 岩井 宏晃 on 2018/04/29.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SocketHandlerDelegate {
    @IBOutlet weak var ipAddressLabel: UILabel!
    
    let socketHandler = SocketHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ipAddressLabel.text = IPAddress.getWiFiAddress()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        socketHandler.delegate = self
        socketHandler.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        socketHandler.delegate = nil
    }
    
    func socketHandlerDidConnect(_ handler: SocketHandler) {
        let vc = ScannerViewController.createViewController(socketHanlder: handler)
        present(vc, animated: true, completion: nil)
    }
    
    func socketHandlerRecievedScanRequest(_ handler: SocketHandler) {
    }
}

