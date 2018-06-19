//
//  CameraViewController.swift
//  BodyMeasure
//
//  Created by 岩井 宏晃 on 2018/06/04.
//  Copyright © 2018年 kiizankiizan. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, MotionManagerDelegate {
    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var pitchLabel: UILabel!
    
    private let captureSession = AVCaptureSession()
    fileprivate var isSetup = false
    fileprivate weak var capturePreviewLayer: AVCaptureVideoPreviewLayer!
    fileprivate let imageOutput = AVCapturePhotoOutput()
    fileprivate var completion: ((Data?) -> Void)?
    fileprivate var imageData: ImageData?
    
    private let motionManager = MotionManager()
    
    class func create() -> UINavigationController {
        return UIStoryboard(name: "Camera", bundle: nil).instantiateInitialViewController() as! UINavigationController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        motionManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureSession.startRunning()
        motionManager.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        captureSession.stopRunning()
        motionManager.stop()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setup()
    }
    
    func capture(completion: @escaping (Data?) -> Void) {
        self.completion = completion
        
        let settings = AVCapturePhotoSettings()
        settings.isAutoStillImageStabilizationEnabled = true
        settings.isHighResolutionPhotoEnabled = true
        imageOutput.capturePhoto(with: settings, delegate: self)
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
            
            imageOutput.isHighResolutionCaptureEnabled = true
            captureSession.addInput(captureInput)
            captureSession.addOutput(captureOutput)
            captureSession.addOutput(imageOutput)
            
            capturePreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            
            capturePreviewLayer.frame = view.bounds
            capturePreviewLayer.videoGravity = .resizeAspectFill
            preview.layer.addSublayer(capturePreviewLayer)
        } catch let error as NSError {
            print(error)
        }
    }
    
    private func exec_capture() {
        if imageData == nil || imageData?.sideImage != nil {
            imageData = ImageData()
            imageData?.save()
        }
        capture { (data) in
            if self.imageData!.frontImage == nil {
                self.imageData!.frontImage = data
            } else if self.imageData!.sideImage == nil {
                self.imageData!.sideImage = data
            }
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        completion?(photo.fileDataRepresentation())
        completion = nil
    }
    
    func motionManager(_ motionManager: MotionManager, attitude: CMAttitude) {
        let pitchAngle = attitude.pitch * 180.0 / .pi
        pitchLabel.text = String(format: "%.1f", pitchAngle)
        if pitchAngle < 83.0 {
            pitchLabel.textColor = UIColor.red
        } else {
            pitchLabel.textColor = UIColor.blue
        }
    }

    @IBAction func pushCancelButton(_ sender: Any) {
        if imageData != nil && imageData?.sideImage == nil {
            let alert = UIAlertController(title: "データ不足", message:  "横からの画像が取れていません", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
            return
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pushCaptureButton(_ sender: Any) {
        exec_capture()
    }
    
    @IBAction func pushTimerButton(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(8)) {
            self.exec_capture()
        }
    }
}
