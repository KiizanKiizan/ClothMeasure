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

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, MotionManagerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var pitchLabel: UILabel!
    @IBOutlet weak var faceLectView: UIView!
    
    private let captureSession = AVCaptureSession()
    fileprivate var isSetup = false
    fileprivate weak var capturePreviewLayer: AVCaptureVideoPreviewLayer!
    fileprivate let imageOutput = AVCapturePhotoOutput()
    fileprivate var completion: ((Data?) -> Void)?
    fileprivate var imageData: ImageData?
    
    fileprivate let detectFrameNum = 8
    fileprivate var currentFrameCount = 0
    
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
            let captureOutput = AVCaptureVideoDataOutput()
            let dctPixelFormatType  = [kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA]
            captureOutput.videoSettings = dctPixelFormatType as [String : Any]
            captureOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global())
            
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
    
    func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage {
        //バッファーをUIImageに変換
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = (CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        let imageRef = context!.makeImage()
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let resultImage = UIImage(cgImage: imageRef!)
        return resultImage
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
    {
        if (currentFrameCount + 1) % detectFrameNum != 0 {
            currentFrameCount += 1
            return
        }
        currentFrameCount = 0
        
        connection.videoOrientation = .portrait
        
        //バッファーをUIImageに変換
        let image = self.imageFromSampleBuffer(sampleBuffer: sampleBuffer)
        let ciimage = CIImage(image: image)!
        
        //CIDetectorAccuracyHighだと高精度（使った感じは遠距離による判定の精度）だが処理が遅くなる
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options:[CIDetectorAccuracy: CIDetectorAccuracyHigh] )!
        let faces = detector.features(in: ciimage)
        
        DispatchQueue.main.async {
            if let feature = faces.first {
                // 座標変換
                var faceRect = feature.bounds
                let widthPer = (self.preview.bounds.width / image.size.width)
                let heightPer = (self.preview.bounds.height / image.size.height)
                
                // UIKitは左上に原点があるが、CoreImageは左下に原点があるので揃える
                faceRect.origin.y = image.size.height - faceRect.origin.y - faceRect.size.height
                
                //倍率変換
                faceRect.origin.x = faceRect.origin.x * widthPer
                faceRect.origin.y = faceRect.origin.y * heightPer
                faceRect.size.width = faceRect.size.width * widthPer
                faceRect.size.height = faceRect.size.height * heightPer
                self.faceLectView.frame = faceRect
            } else {
                self.faceLectView.frame = .zero
            }
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
