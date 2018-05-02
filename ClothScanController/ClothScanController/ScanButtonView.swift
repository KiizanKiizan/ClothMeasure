//
//  ScanButtonView.swift
//  ClothScanController
//
//  Created by 岩井 宏晃 on 2018/04/30.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import UIKit

protocol ScanButtonViewDelegate: class {
    func scanButtonViewDidPushScanButton(_ view: ScanButtonView)
}

class ScanButtonView: UIView {

    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    weak var delegate: ScanButtonViewDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    private func setup() {
        let view = Bundle.main.loadNibNamed("ScanButtonView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
    }
    
    func startIndicator() {
        indicator.startAnimating()
        scanButton.setTitle("", for: .normal)
    }
    
    func setImage(image: UIImage?) {
        let enabled = image == nil
        let title = enabled ? "撮影" : ""
        scanButton.setTitle(title, for: .normal)
        scanButton.setBackgroundImage(image, for: .normal)
        scanButton.isUserInteractionEnabled = enabled
        indicator.stopAnimating()
    }
    
    @IBAction func pushScanButton(_ sender: Any) {
        delegate?.scanButtonViewDidPushScanButton(self)
    }
}
