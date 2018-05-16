//
//  CaptureViewController.swift
//  BarcodeReader
//
//  Created by 岩井 宏晃 on 2018/04/24.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import UIKit
import AVFoundation

protocol CaptureViewControllerDelegate: class {
    func captureViewController(_ vc: CaptureViewController, DidReadBarcode text: String, frame: CGRect)
}

class CaptureViewController: UIViewController {

    var readBarcode = true
    private let captureSession = AVCaptureSession()
    fileprivate var isSetup = false
    fileprivate weak var capturePreviewLayer: AVCaptureVideoPreviewLayer!
    fileprivate let imageOutput = AVCaptureStillImageOutput()
    fileprivate var calibrationLeftRect: CGRect?
    fileprivate var calibrationRightRect: CGRect?
    private let calibrationDistance: Float = 50.0
    
    weak var delegate: CaptureViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setup()
    }
    
    func start() {
        captureSession.startRunning()
    }
    
    func stop() {
        captureSession.stopRunning()
    }
    
    func capture(completion: @escaping (UIImage?) -> Void) {
        guard let connection = imageOutput.connection(with: .video) else {
            completion(nil)
            return
        }
        
        imageOutput.captureStillImageAsynchronously(from: connection) { (buffer, error) in
            if error != nil || buffer == nil {
                completion(nil)
            } else {
                if let jpgData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer!) {
                    completion(UIImage(data: jpgData))
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func calibrate(completion: @escaping (Float) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            if let leftRect = self.calibrationLeftRect, let rightRect = self.calibrationRightRect {
                let leftPos = CGPoint(x: leftRect.origin.x + leftRect.width / 2.0, y: leftRect.origin.y + leftRect.height / 2.0)
                let rightPos = CGPoint(x: rightRect.origin.x + rightRect.width / 2.0, y: rightRect.origin.y + rightRect.height / 2.0)
                let diffX = Float(leftPos.x) - Float(rightPos.x)
                let diffY = Float(rightPos.y) - Float(rightPos.y)
                
                completion(sqrtf(diffX * diffX + diffY * diffY) / self.calibrationDistance)
            } else {
                self.calibrate(completion: completion)
            }
        }
    }
    
    private func setup() {
        if isSetup {
            return
        }
        
        isSetup = true
        
        do {
            let captureDevice = AVCaptureDevice.default(for: .video)!
            
            let captureInput = try AVCaptureDeviceInput(device: captureDevice)
            let captureOutput = AVCaptureMetadataOutput()
            captureOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            captureSession.addInput(captureInput)
            captureSession.addOutput(captureOutput)
            captureSession.addOutput(imageOutput)
            
            captureOutput.metadataObjectTypes = captureOutput.availableMetadataObjectTypes
            
            capturePreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            
            capturePreviewLayer.frame = view.bounds
            capturePreviewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(capturePreviewLayer)
        } catch let error as NSError {
            print(error)
        }
    }
}

extension CaptureViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if !readBarcode {
            return
        }
        
        if let barcodeObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            let number = barcodeObject.stringValue ?? ""
            if !number.isEmpty {
                DispatchQueue.main.async {
                    switch number {
                    case "calibrationLeft":
                        self.calibrationLeftRect = barcodeObject.bounds
                    case "calibrationRight":
                        self.calibrationRightRect = barcodeObject.bounds
                    default:
                        self.delegate?.captureViewController(self, DidReadBarcode: number, frame: self.capturePreviewLayer.layerRectConverted(fromMetadataOutputRect: barcodeObject.bounds))
                    }
                }
            }
        }
    }
}


