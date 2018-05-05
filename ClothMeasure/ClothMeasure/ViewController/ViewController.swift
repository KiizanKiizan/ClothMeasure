//
//  ViewController.swift
//  ClothMeasure
//
//  Created by 岩井 宏晃 on 2018/04/26.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import UIKit

enum MeasureType {
    case neck
    case shoulder
    case chest
    case waist
    case armLeft
    case armRight
}

class ViewController: UIViewController, SocketHandlerDelegate, BarcodeReaderViewControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var connectIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var neckLabel: UILabel!
    @IBOutlet weak var shoulderLabel: UILabel!
    @IBOutlet weak var chest: UILabel!
    @IBOutlet weak var waistLabel: UILabel!
    @IBOutlet weak var leftArmLabel: UILabel!
    @IBOutlet weak var rightArmLabel: UILabel!
    
    @IBOutlet weak var neckLeftView: UIView!
    @IBOutlet weak var neckRightView: UIView!
    @IBOutlet weak var shoulderLeftView: UIView!
    @IBOutlet weak var shoulderRightView: UIView!
    @IBOutlet weak var armLeftView: UIView!
    @IBOutlet weak var armRightView: UIView!
    @IBOutlet weak var chestLeftView: UIView!
    @IBOutlet weak var chestRightView: UIView!
    @IBOutlet weak var waistLeftView: UIView!
    @IBOutlet weak var waistRightView: UIView!
    
    private let shapeLayer = CAShapeLayer()
    private let socketHandler = SocketHandler()
    private var fetchImage: FetchImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchImage = FetchImage(socketHandler: socketHandler)
        
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        view.layer.addSublayer(shapeLayer)
        
        updateLine()
        
        let views = [
            neckLeftView,
            neckRightView,
            shoulderLeftView,
            shoulderRightView,
            armLeftView,
            armRightView,
            chestLeftView,
            chestRightView,
            waistLeftView,
            waistRightView
        ]
        
        views.forEach {
            $0?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panLabel)))
            self.measure(view: $0!)
        }
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
        connectIndicator.stopAnimating()
    }
    
    func socketHandlerRecieveImage(_ handler: SocketHandler) {
        fetchImage.fetch { (image, error) in
            self.imageView.image = image
        }
    }
    
    func barcodeReaderViewController(_ vc: BarcodeReaderViewController, DidReadBarcode number: String) {
        vc.dismiss(animated: true, completion: {
            self.socketHandler.connect(ipAddress: number)
            self.connectIndicator.startAnimating()
        })
    }

    @objc func panLabel(sender: UIPanGestureRecognizer) {
        let move = sender.translation(in: view)
        
        sender.view!.center.x += move.x
        sender.view!.center.y += move.y
        
        sender.setTranslation(.zero, in: view)
        updateLine()
        measure(view: sender.view!)
    }
    
    private func updateLine() {
        let uiPath = UIBezierPath()
        uiPath.move(to: neckLeftView.center)
        uiPath.addLine(to: shoulderLeftView.center)
        uiPath.addLine(to: armLeftView.center)
        uiPath.move(to: neckRightView.center)
        uiPath.addLine(to: shoulderRightView.center)
        uiPath.addLine(to: armRightView.center)
        uiPath.move(to: chestLeftView.center)
        uiPath.addLine(to: waistLeftView.center)
        uiPath.move(to: chestRightView.center)
        uiPath.addLine(to: waistRightView.center)
        
        shapeLayer.path = uiPath.cgPath
    }
    
    private func measure(view: UIView) {
        if view === neckLeftView || view === neckRightView {
            updateLabel(type: .neck)
        } else if view === shoulderLeftView {
            updateLabel(type: .shoulder)
            updateLabel(type: .armLeft)
        } else if view === shoulderRightView {
            updateLabel(type: .shoulder)
            updateLabel(type: .armRight)
        } else if view === armLeftView {
            updateLabel(type: .armLeft)
        } else if view === armRightView {
            updateLabel(type: .armRight)
        } else if view === chestLeftView || view === chestRightView {
            updateLabel(type: .chest)
        } else if view === waistLeftView || view === waistRightView {
            updateLabel(type: .waist)
        }
    }
    
    private func updateLabel(type: MeasureType) {
        switch type {
        case .neck:
            neckLabel.text = calcDistance(p1: neckLeftView.center, p2: neckRightView.center)
        case .shoulder:
            shoulderLabel.text = calcDistance(p1: shoulderLeftView.center, p2: shoulderRightView.center)
        case .chest:
            chest.text = calcDistance(p1: chestLeftView.center, p2: chestRightView.center)
        case .waist:
            waistLabel.text = calcDistance(p1: waistLeftView.center, p2: waistRightView.center)
        case .armLeft:
            leftArmLabel.text = calcDistance(p1: armLeftView.center, p2: shoulderLeftView.center)
        case .armRight:
            rightArmLabel.text = calcDistance(p1: armRightView.center, p2: shoulderRightView.center)
        }
    }
    
    private func calcDistance(p1: CGPoint, p2: CGPoint) -> String {
        let dx = Float(p1.x - p2.x)
        let dy = Float(p1.y - p2.y)
        return String(format: "%.2f cm", sqrtf(dx*dx + dy*dy) / 4.0)
    }
    
    @IBAction func pushConnectButton(_ sender: Any) {
        let barcodeReaderVc = BarcodeReaderViewController()
        barcodeReaderVc.delegate = self
        present(barcodeReaderVc, animated: true, completion: {
            barcodeReaderVc.start()
        })
    }
}


