//
//  ViewController.swift
//  ClothScanner
//
//  Created by 岩井 宏晃 on 2018/04/29.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, SocketHandlerDelegate {
    @IBOutlet weak var ipAddressTextField: UITextField!
    
    let socketHandler = SocketHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ipAddressTextField.delegate = self
        ipAddressTextField.text = socketHandler.previousHost
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        socketHandler.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        socketHandler.delegate = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let ip = textField.text else {
            return
        }
        
        if ip.isEmpty {
            return
        }
        
        socketHandler.connect(ipAddress: ip)
    }
    
    func socketHandlerDidConnect(_ handler: SocketHandler) {
        let vc = ScannerViewController.createViewController(socketHanlder: handler)
        present(vc, animated: true, completion: nil)
    }
    
    func socketHandlerRecievedScanRequest(_ handler: SocketHandler) {
    }
}

