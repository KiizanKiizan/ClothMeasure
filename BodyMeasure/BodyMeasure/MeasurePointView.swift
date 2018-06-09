//
//  MeasurePointView.swift
//  BodyMeasure
//
//  Created by 岩井 宏晃 on 2018/06/06.
//  Copyright © 2018年 kiizankiizan. All rights reserved.
//

import UIKit

protocol MeasurePointViewDelegate: class {
    func measurePointViewDidSelectPointView(_ view: MeasurePointView)
    func measurePointViewDidDeselectPointView(_ view: MeasurePointView)
    func measurePointView(_ view: MeasurePointView, DidMove pos: CGPoint)
}

class MeasurePointView: UIView {

    private(set) var color = UIColor.red
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var centerLineHorizontal: UIView!
    @IBOutlet weak var centerLineVertial: UIView!
    
    weak var delegate: MeasurePointViewDelegate?
    
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
        self.color = color
        circleView.layer.borderColor = color.cgColor
        circleView.backgroundColor = color.withAlphaComponent(0.3)
        centerLineHorizontal.backgroundColor = color
        centerLineVertial.backgroundColor = color
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if event?.touches(for: circleView) != nil {
            delegate?.measurePointViewDidSelectPointView(self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touchEvent = event?.touches(for: circleView)?.first {
            let preDx = touchEvent.previousLocation(in: self).x
            let preDy = touchEvent.previousLocation(in: self).y
            
            let newDx = touchEvent.location(in: self).x
            let newDy = touchEvent.location(in: self).y
            
            let move = CGPoint(x: newDx - preDx,
                               y: newDy - preDy)
            
            center = CGPoint(x: center.x + move.x,
                             y: center.y + move.y)
            delegate?.measurePointView(self, DidMove: center)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if event?.touches(for: circleView) != nil {
            delegate?.measurePointViewDidDeselectPointView(self)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if event?.touches(for: circleView) != nil {
            delegate?.measurePointViewDidDeselectPointView(self)
        }
    }
}
