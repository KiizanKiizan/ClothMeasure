//
//  BarcodeReaderViewController.swift
//  BarcodeReader
//
//  Created by 岩井 宏晃 on 2018/04/24.
//  Copyright © 2018年 kiizan-kiizan. All rights reserved.
//

import UIKit
import AVFoundation

protocol BarcodeReaderViewControllerDelegate: class {
    func barcodeReaderViewController(_ vc: BarcodeReaderViewController, DidReadBarcode text: String, frame: CGRect)
}

class BarcodeReaderViewController: UIViewController {

    var readBarcode = true
    private let captureSession = AVCaptureSession()
    fileprivate var isSetup = false
    fileprivate weak var capturePreviewLayer: AVCaptureVideoPreviewLayer!
    
    weak var delegate: BarcodeReaderViewControllerDelegate?
    
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

extension BarcodeReaderViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if !readBarcode {
            return
        }
        
        if let barcodeObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            let number = barcodeObject.stringValue ?? ""
            if !number.isEmpty {
                DispatchQueue.main.async {
                    self.delegate?.barcodeReaderViewController(self, DidReadBarcode: number, frame: self.capturePreviewLayer.layerRectConverted(fromMetadataOutputRect: barcodeObject.bounds))
                }
            }
        }
    }
}


