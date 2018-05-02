//
//  ScanViewController.swift
//  ClothScanController
//
//  Created by 岩井 宏晃 on 2018/04/30.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import UIKit

class ScanViewController: UIViewController, BarcodeReaderViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, ScanTableViewCellDelegate {
    @IBOutlet weak var barcodeReaderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var barcodeReaderTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var barcodeReaderContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private var socketHandler: SocketHandler!
    private var barcodeReaderVc: BarcodeReaderViewController!
    private var imageDatas = [ScanImageData]()
    
    class func createViewController(socketHandler: SocketHandler) -> UINavigationController {
        let navi = UIStoryboard(name: "ScanViewController", bundle: nil).instantiateInitialViewController() as! UINavigationController
        let vc = navi.topViewController as! ScanViewController
        vc.socketHandler = socketHandler
        
        return navi
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barcodeReaderTopConstraint.constant = -barcodeReaderHeightConstraint.constant
        barcodeReaderContainerView.isHidden = true
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? BarcodeReaderViewController {
            barcodeReaderVc = vc
            barcodeReaderVc.delegate = self
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScanTableViewCell", for: indexPath) as! ScanTableViewCell
        let data = imageDatas[indexPath.row]
        cell.barcodeNumber = data.barcodeNumber
        cell.setFrontImage(image: data.frontImage)
        cell.setBackImage(image: data.backImage)
        cell.delegate = self
        return cell
    }
    
    func scanTableViewCellDidPushFrontImageButton(_ cell: ScanTableViewCell) {
        if !socketHandler.busy {
            cell.startFrontImageButtonIndicator()
            socketHandler.scan(completion: { (image, error) in
                cell.setFrontImage(image: image)
            })
        }
    }
    
    func scanTableViewCellDidPushBackImageButton(_ cell: ScanTableViewCell) {
        if !socketHandler.busy {
            cell.startBackImageButtonIndicator()
            socketHandler.scan(completion: { (image, error) in
                cell.setBackImage(image: image)
            })
        }
    }
    
    func barcodeReaderViewController(_ vc: BarcodeReaderViewController, DidReadBarcode number: String) {
        if imageDatas.contains(where: { $0.barcodeNumber == number }) {
            return
        }
        imageDatas.append(ScanImageData(barcodeNumber: number))
        tableView.reloadData()
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
