//
//  MeasureZoomView.swift
//  BodyMeasure
//
//  Created by 岩井 宏晃 on 2018/06/09.
//  Copyright © 2018年 kiizankiizan. All rights reserved.
//

import UIKit

class MeasureZoomView: UIView {
    private let scale: CGFloat = 5.0
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pointView: MeasurePointView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    private func setup() {
        let view = Bundle.main.loadNibNamed("MeasureZoomView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        view.layer.borderWidth = 2.0
        view.layer.borderColor = UIColor.black.cgColor
        addSubview(view)
    }
    
    func setImage(_ image: UIImage?) {
        imageView.image = image
    }
    
    func setImagePos(_ pos: CGPoint) {
        let x = -pos.x * scale + bounds.width / 2.0
        let y = -pos.y * scale + bounds.height / 2.0
        imageView.frame = CGRect(x: x,
                                 y: y,
                                 width: imageView.bounds.width,
                                 height: imageView.bounds.height)
    }
    
    func setImageSize(_ size: CGSize) {
        imageView.frame = CGRect(x: imageView.frame.origin.x,
                                 y: imageView.frame.origin.y,
                                 width: size.width * scale,
                                 height: size.height * scale)
    }
    
    func setPointViewColor(_ color: UIColor) {
        pointView.setColor(color)
    }
}
