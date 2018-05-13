//
//  ScanViewController.swift
//  ClothScanController
//
//  Created by 岩井 宏晃 on 2018/04/30.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import UIKit

class ScanViewController: UIViewController, BarcodeReaderViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, ScanTableViewCellDelegate, SocketHandlerDelegate {
    @IBOutlet weak var barcodeReaderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var barcodeReaderTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var barcodeReaderContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private var scanImage: ScanImage!
    private var sendImage: SendImage!
    private var barcodeReaderVc: BarcodeReaderViewController!
    private var items = [Item]()
    private var sendSocketHandler: SocketHandler!
    
    class func createViewController(scanSocketHandler: SocketHandler, sendSocketHandler: SocketHandler) -> UINavigationController {
        let navi = UIStoryboard(name: "ScanViewController", bundle: nil).instantiateInitialViewController() as! UINavigationController
        let vc = navi.topViewController as! ScanViewController
        vc.scanImage = ScanImage(socketHandler: scanSocketHandler)
        vc.sendImage = SendImage(socketHandler: sendSocketHandler)
        vc.sendSocketHandler = sendSocketHandler
        
        return navi
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barcodeReaderTopConstraint.constant = -barcodeReaderHeightConstraint.constant
        barcodeReaderContainerView.isHidden = true
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        sendSocketHandler.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sendSocketHandler.delegate = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? BarcodeReaderViewController {
            barcodeReaderVc = vc
            barcodeReaderVc.delegate = self
        }
    }
    
    private func scanImage(cell: ScanTableViewCell, front: Bool) {
        if !scanImage.busy && !sendImage.busy {
            if front {
                cell.startFrontImageButtonIndicator()
            } else {
                cell.startBackImageButtonIndicator()
            }
            scanImage.scan(completion: { (image, data, error) in
                if let imageData = data {
                    self.sendImage.sendImage(imageData: imageData, completion: { (error) in
                        if front {
                            cell.setFrontImage(image: image)
                        } else {
                            cell.setBackImage(image: image)
                        }
                    })
                } else {
                    if front {
                        cell.setFrontImage(image: image)
                    } else {
                        cell.setBackImage(image: image)
                    }
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScanTableViewCell", for: indexPath) as! ScanTableViewCell
        let data = items[indexPath.row]
        cell.barcodeNumber = data.barcodeNumber
        cell.setFrontImage(image: data.frontImage)
        cell.setBackImage(image: data.backImage)
        cell.delegate = self
        return cell
    }
    
    func scanTableViewCellDidPushFrontImageButton(_ cell: ScanTableViewCell) {
        scanImage(cell: cell, front: true)
    }
    
    func scanTableViewCellDidPushBackImageButton(_ cell: ScanTableViewCell) {
        scanImage(cell: cell, front: false)
    }
    
    func barcodeReaderViewController(_ vc: BarcodeReaderViewController, DidReadBarcode number: String) {
        if items.contains(where: { $0.barcodeNumber == number }) {
            return
        }
        items.append(Item(barcodeNumber: number))
        tableView.reloadData()
    }
    
    func socketHandlerDidConnect(_ handler: SocketHandler) {
    }
    
    func socketHandlerDidRecievedScanImageCommand(_ handler: SocketHandler) {
        if !scanImage.busy {
            scanImage.scan(completion: { (image, data, error) in
                if let imageData = data {
                    self.sendImage.sendImage(imageData: imageData, completion: { (error) in
                    })
                }
            })
        }
    }
    
    @IBAction func pushBarcodeReaderButton(_ sender: UIBarButtonItem) {
        let show = barcodeReaderContainerView.isHidden
        sender.isEnabled = false
        let duration: TimeInterval = 0.3
        if show {
            barcodeReaderContainerView.isHidden = false
            barcodeReaderTopConstraint.constant = 0.0
            barcodeReaderVc.start()
            UIView.animate(withDuration: duration,
                           animations: {
                            self.view.layoutIfNeeded()
            }, completion: { (result) in
                sender.isEnabled = true
            })
        } else {
            barcodeReaderTopConstraint.constant = -barcodeReaderHeightConstraint.constant
            UIView.animate(withDuration: duration,
                           animations: {
                            self.view.layoutIfNeeded()
            }, completion: { (result) in
                self.barcodeReaderContainerView.isHidden = true
                self.barcodeReaderVc.stop()
                sender.isEnabled = true
            })
        }
    }
}
