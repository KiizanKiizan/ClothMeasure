//
//  CalibrationViewController.swift
//  ClothMeasure
//
//  Created by 岩井 宏晃 on 2018/05/05.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import UIKit

class CalibrationViewController: UIViewController, SocketHandlerDelegate {
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var measureViewContainer: UIView!
    
    private var measureViewController: MeasureViewController!
    private var scanSocketHandler: SocketHandler!
    private var fetchImage: FetchImage!
    private var measurePointPair: MeasurePointPair!
    private var calibrator: Calibrator!
    
    private let calibrationDistance: Float = 42.5
    
    class func createViewController(scanSocketHandler: SocketHandler) -> CalibrationViewController {
        let vc = UIStoryboard(name: "CalibrationViewController", bundle: nil).instantiateInitialViewController() as! CalibrationViewController
        
        vc.scanSocketHandler = scanSocketHandler
        vc.fetchImage = FetchImage(socketHandler: scanSocketHandler)
        let startMeasurePointVc = MeasurePointViewController.createViewController(initPosRatio: CGPoint(x: 0.9, y: 1.0), cursorPosition: .bottom)
        let endMeasurePointVc = MeasurePointViewController.createViewController(initPosRatio: CGPoint(x: 1.1, y: 1.0), cursorPosition: .bottom)
        vc.measurePointPair = MeasurePointPair(type: .calibration,
                                               startMeasurePointVc: startMeasurePointVc,
                                               endMeasurePointVc: endMeasurePointVc)
        
        return vc
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MeasureViewController {
            measureViewController = vc
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calibrator = Calibrator(scale: UIScreen.main.scale)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !measureViewController.didSetup {
            measureViewController.measurePointPairs = [measurePointPair]
            measureViewController.setup()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scanSocketHandler.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        scanSocketHandler.delegate = nil
    }
    
    func socketHandlerDidConnect(_ handler: SocketHandler) {
    }
    
    func socketHandlerRecieveImage(_ handler: SocketHandler) {
        fetchImage.fetch { (image, error) in
            if error == nil {
                self.measureViewController.setImage(image)
                self.calibrator.calibration(image: image!, completion: { (result) in
                    if result != nil {
                        ApplicationSetting().saveCentimeterPerPoint(result!)
                    }
                })
            }
        }
    }
    
    func socketHandlerRecieveCalibrationInfo(_ handler: SocketHandler) {
    }
    
    @IBAction func pushScanButton(_ sender: Any) {
        scanSocketHandler.exec(request: ScanImageRequest(), completion: nil)
    }
    @IBAction func pushDoneButton(_ sender: Any) {
        //ApplicationSetting().savePointPerCentimeter(calibrationDistance / measurePointPair.distance())
        dismiss(animated: true, completion: nil)
    }
}
