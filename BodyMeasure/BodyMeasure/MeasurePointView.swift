//
//  MeasurePointView.swift
//  BodyMeasure
//
//  Created by 岩井 宏晃 on 2018/06/06.
//  Copyright © 2018年 kiizankiizan. All rights reserved.
//

import UIKit

class MeasurePointView: UIView {

    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var centerLineHorizontal: UIView!
    @IBOutlet weak var centerLineVertial: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    private func setup() {
        let view = Bundle.main.loadNibNamed("MeasurePointView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        circleView.layer.cornerRadius = circleView.bounds.width / 2.0
        circleView.layer.borderWidth = 3.0
    }
    
    func setColor(_ color: UIColor) {
        circleView.layer.borderColor = color.cgColor
        circleView.backgroundColor = color.withAlphaComponent(0.3)
        centerLineHorizontal.backgroundColor = color
        centerLineVertial.backgroundColor = color
    }
}
