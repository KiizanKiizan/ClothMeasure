//
//  ViewController.swift
//  ClothScanController
//
//  Created by 岩井 宏晃 on 2018/04/29.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, SocketHandlerDelegate {

    @IBOutlet weak var ipAddressLabel: UILabel!
    
    let socketHandler = SocketHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ipAddressLabel.text = IPAddress.getWiFiAddress()
        
        socketHandler.delegate = self
        socketHandler.start()
    }
    
    func socketHandlerDidConnect(_ handler: SocketHandler) {
        let vc = ScanViewController.createViewController(socketHandler: handler)
        present(vc, animated: true, completion: nil)
    }
}

