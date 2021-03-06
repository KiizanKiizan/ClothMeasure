//
//  ScanTableViewCell.swift
//  ClothScanController
//
//  Created by 岩井 宏晃 on 2018/04/30.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import UIKit

protocol ScanTableViewCellDelegate: class {
    func scanTableViewCellDidPushFrontImageButton(_ cell: ScanTableViewCell)
    func scanTableViewCellDidPushBackImageButton(_ cell: ScanTableViewCell)
}

class ScanTableViewCell: UITableViewCell, ScanButtonViewDelegate {
    @IBOutlet weak var itemIdLabel: UILabel!
    @IBOutlet weak var frontImage: ScanButtonView!
    @IBOutlet weak var backImage: ScanButtonView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    var itemLoading: Bool = false {
        didSet {
            if itemLoading {
                containerView.isHidden = true
                indicatorView.startAnimating()
            } else {
                containerView.isHidden = false
                indicatorView.stopAnimating()
            }
        }
    }
    
    var barcodeNumber = "" {
        didSet {
            if itemIdLabel != nil {
                itemIdLabel.text = barcodeNumber
            }
        }
    }
    
    weak var delegate: ScanTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        frontImage.delegate = self
        backImage.delegate = self
        
        itemIdLabel.text = barcodeNumber
    }
    
    func startFrontImageButtonIndicator() {
        frontImage.startIndicator()
    }
    
    func startBackImageButtonIndicator() {
        backImage.startIndicator()
    }
    
    func setFrontImage(image: UIImage?){
        frontImage.setImage(image: image)
    }
    
    func setBackImage(image: UIImage?){
        backImage.setImage(image: image)
    }
    
    func scanButtonViewDidPushScanButton(_ view: ScanButtonView) {
        if view === frontImage {
            delegate?.scanTableViewCellDidPushFrontImageButton(self)
        } else if view === backImage {
            delegate?.scanTableViewCellDidPushBackImageButton(self)
        }
    }
}
