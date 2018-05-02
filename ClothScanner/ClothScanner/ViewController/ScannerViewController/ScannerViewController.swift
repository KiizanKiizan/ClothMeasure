//
//  ScannerViewController.swift
//  ClothScanner
//
//  Created by 岩井 宏晃 on 2018/04/30.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import UIKit

class ScannerViewController: UIViewController, SocketHandlerDelegate {

    private var socketHandler: SocketHandler!
    
    class func createViewController(socketHanlder: SocketHandler) -> ScannerViewController {
        let vc = UIStoryboard(name: "ScannerViewController", bundle: nil).instantiateInitialViewController() as! ScannerViewController
        
        vc.socketHandler = socketHanlder
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        socketHandler.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
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
}
