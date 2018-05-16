//
//  ViewController.swift
//  ClothMeasure
//
//  Created by 岩井 宏晃 on 2018/04/26.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SocketHandlerDelegate, BarcodeReaderViewControllerDelegate, MeasurePointPairDelegate {

    @IBOutlet weak var connectIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var neckLabel: UILabel!
    @IBOutlet weak var shoulderLabel: UILabel!
    @IBOutlet weak var chest: UILabel!
    @IBOutlet weak var waistLabel: UILabel!
    @IBOutlet weak var leftArmLabel: UILabel!
    @IBOutlet weak var rightArmLabel: UILabel!
    
    private let socketHandler = SocketHandler()
    private var fetchImage: FetchImage!
    private var fetchCalibrationInfo: FetchCalibrationInfo!
    private var measurePointPairs = [MeasurePointPair]()
    private var measureViewController: MeasureViewController!
    private var pointPerCentimeter: Float = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchImage = FetchImage(socketHandler: socketHandler)
        fetchCalibrationInfo = FetchCalibrationInfo(socketHandler: socketHandler)
        
        let measurePointVcs = [
            MeasurePointViewController.createViewController(initPosRatio: CGPoint(x: 0.8, y: 0.6), cursorPosition: .top),
            MeasurePointViewController.createViewController(initPosRatio: CGPoint(x: 1.2, y: 0.6), cursorPosition: .top),
            MeasurePointViewController.createViewController(initPosRatio: CGPoint(x: 0.55, y: 0.75), cursorPosition: .bottom),
            MeasurePointViewController.createViewController(initPosRatio: CGPoint(x: 1.45, y: 0.75), cursorPosition: .bottom),
            MeasurePointViewController.createViewController(initPosRatio: CGPoint(x: 0.3, y: 0.8), cursorPosition: .bottom),
            MeasurePointViewController.createViewController(initPosRatio: CGPoint(x: 1.7, y: 0.8), cursorPosition: .bottom),
            MeasurePointViewController.createViewController(initPosRatio: CGPoint(x: 0.7, y: 1.1), cursorPosition: .left),
            MeasurePointViewController.createViewController(initPosRatio: CGPoint(x: 1.3, y: 1.1), cursorPosition: .right),
            MeasurePointViewController.createViewController(initPosRatio: CGPoint(x: 0.7, y: 1.4), cursorPosition: .left),
            MeasurePointViewController.createViewController(initPosRatio: CGPoint(x: 1.3, y: 1.4), cursorPosition: .right)
        ]
        measurePointPairs = [
            MeasurePointPair(type: .neck,
                             startMeasurePointVc: measurePointVcs[0],
                             endMeasurePointVc: measurePointVcs[1]),
            MeasurePointPair(type: .shoulder,
                             startMeasurePointVc: measurePointVcs[2],
                             endMeasurePointVc: measurePointVcs[3]),
            MeasurePointPair(type: .chest,
                             startMeasurePointVc: measurePointVcs[6],
                             endMeasurePointVc: measurePointVcs[7]),
            MeasurePointPair(type: .waist,
                             startMeasurePointVc: measurePointVcs[8],
                             endMeasurePointVc: measurePointVcs[9]),
            MeasurePointPair(type: .leftArm,
                             startMeasurePointVc: measurePointVcs[2],
                             endMeasurePointVc: measurePointVcs[4]),
            MeasurePointPair(type: .rightArm,
                             startMeasurePointVc: measurePointVcs[3],
                             endMeasurePointVc: measurePointVcs[5]),
        
        ]
        measurePointPairs.forEach { $0.delegate = self }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MeasureViewController {
            measureViewController = vc
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !measureViewController.didSetup {
            measureViewController.measurePointPairs = measurePointPairs
            measureViewController.setup()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        socketHandler.delegate = self
        
        updatePointPerCentimeter()
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
            self.measureViewController.setImage(image)
        }
    }
    
    func socketHandlerRecieveCalibrationInfo(_ handler: SocketHandler) {
        fetchCalibrationInfo.fetch { (info, error) in
            if info != nil {
                ApplicationSetting().savePointPerCentimeter(info!)
                self.updatePointPerCentimeter()
            }
        }
    }
    
    func barcodeReaderViewController(_ vc: BarcodeReaderViewController, DidReadBarcode number: String) {
        vc.dismiss(animated: true, completion: {
            self.socketHandler.connect(ipAddress: number)
            self.connectIndicator.startAnimating()
        })
    }
    
    func measurePointPairDidMovePoint(_ controller: MeasurePointPair) {
        updateLabel(controller: controller)
    }
    
    private func updateLabel(controller: MeasurePointPair) {
        var label: UILabel?
        switch controller.type {
        case .neck:
            label = neckLabel
        case .shoulder:
            label = shoulderLabel
        case .chest:
            label = chest
        case .waist:
            label = waistLabel
        case .leftArm:
            label = leftArmLabel
        case .rightArm:
            label = rightArmLabel
        case .calibration:
            break
        }
        label?.text = roundDistance(controller.distance())
    }
    
    private func roundDistance(_ distane: Float) -> String {
        return String(format: "%d cm", Int(roundf(distane / pointPerCentimeter)))
    }
    
    private func updatePointPerCentimeter() {
        pointPerCentimeter = ApplicationSetting().pointPerCentimeter()
        measurePointPairs.forEach { updateLabel(controller: $0) }
    }
    
    @IBAction func pushConnectButton(_ sender: Any) {
        let barcodeReaderVc = BarcodeReaderViewController()
        barcodeReaderVc.delegate = self
        present(barcodeReaderVc, animated: true, completion: {
            barcodeReaderVc.start()
        })
    }
    
    @IBAction func pushCalibrationButton(_ sender: Any) {
        let vc = CalibrationViewController.createViewController(scanSocketHandler: socketHandler)
        present(vc, animated: true, completion: nil)
    }
}


