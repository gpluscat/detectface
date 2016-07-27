//
//  IdcardViewController.swift
//  demo
//
//  Created by qing on 16/7/19.
//  Copyright © 2016年 qing. All rights reserved.
//

import UIKit
import AVFoundation

class IdcardViewController: UIViewController {

    @IBOutlet weak var previewView: AVPreviewView!
    
    private var session: AVCaptureSession!
    private var videoDeviceInput: AVCaptureDeviceInput!
    private var stillImageOutput: AVCaptureStillImageOutput!
    
    private var sessionQueue: dispatch_queue_t!
    
    private var base64Img: String = ""
    
    private enum AVCameraSetupResult: Int {
        case AVSetupResultSuccess
        case AVSetupResultCameraNotAuthorized
        case AVSetupResultSessionConfigurationFailed
    }
    
    private var setupResult: AVCameraSetupResult = .AVSetupResultSuccess
    private var aiv: AlertIndicatorView!
    
    deinit {
        self.session.stopRunning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.title = "身份证识别"
        self.view.backgroundColor = UIColor.whiteColor()
        
        let item = UIBarButtonItem(title: "返回", style: .Plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = item

        session = AVCaptureSession()
        previewView.session = session
        sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL)
        
        let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        if status == .Authorized {
            
        }
        else if status == .NotDetermined {
            dispatch_suspend(self.sessionQueue)
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { [unowned self] (granted: Bool) in
                if !granted {
                    self.setupResult = .AVSetupResultCameraNotAuthorized
                }
                dispatch_resume(self.sessionQueue)
                })
        }
        else {
            self.setupResult = .AVSetupResultCameraNotAuthorized
        }
        
        dispatch_async(self.sessionQueue) { [unowned self] in
            if self.setupResult != .AVSetupResultSuccess {
                return
            }
            
            let videoDevice = AVPreviewView.deviceWithMediaType(AVMediaTypeVideo, position: AVCaptureDevicePosition.Back)
            do {
                try self.videoDeviceInput = AVCaptureDeviceInput.init(device: videoDevice)
                self.session.beginConfiguration()
                
                if self.session.canAddInput(self.videoDeviceInput) {
                    self.session.addInput(self.videoDeviceInput)
                }
                else {
                    print("Could not add video device input to the session")
                    self.setupResult = .AVSetupResultSessionConfigurationFailed
                }
                
                self.stillImageOutput = AVCaptureStillImageOutput()
                if self.session.canAddOutput(self.stillImageOutput) {
                    self.stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                    self.session.addOutput(self.stillImageOutput)
                }
                else {
                    print("Could not add still image output to the session")
                    self.setupResult = .AVSetupResultSessionConfigurationFailed
                }
                
                self.session.commitConfiguration()
            }
            catch let error as NSError {
                print(">>>>>>>>>>error \(error.localizedDescription)")
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        startRunning()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopRunning()
    }
    
    private func startRunning() {
        dispatch_async(self.sessionQueue) { [weak self] in
            if let weakSelf = self {
                if weakSelf.setupResult == .AVSetupResultSuccess {
                    weakSelf.session.startRunning()
                }
                else if weakSelf.setupResult == .AVSetupResultCameraNotAuthorized {
                    
                }
                else if weakSelf.setupResult == .AVSetupResultSessionConfigurationFailed {
                }
            }
        }
    }
    
    private func stopRunning() {
        dispatch_async(self.sessionQueue) { [weak self] in
            if let weakSelf = self {
                if weakSelf.setupResult == .AVSetupResultSuccess {
                    weakSelf.session.stopRunning()
                }
            }
        }
    }
    
    @IBAction func buttonPressed(sender: UIButton) {
        snapStillImage()
    }
    
    ///
    /// 弹出框
    ///
    private func showAlert() {
        let alertController = UIAlertController(title: "识别失败", message: "是否跳过继续认证？", preferredStyle: .Alert)
        let jumpAction = UIAlertAction(title: "跳过识别", style: .Default) { [unowned self] (action: UIAlertAction) in
            let controller = InputViewController()
            controller.base64Img = self.base64Img
            self.navigationController?.pushViewController(controller, animated: true)
        }
        let cancelAction = UIAlertAction(title: "重新识别", style: .Default) { [unowned self] (action: UIAlertAction) in
            self.startRunning()
        }
        alertController.addAction(jumpAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    ///
    /// 拍照
    ///
    private func snapStillImage() {
        dispatch_async(self.sessionQueue) { [weak self] in
            if let weakSelf = self {
                let connection = weakSelf.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
                weakSelf.stillImageOutput.captureStillImageAsynchronouslyFromConnection(connection, completionHandler: { (imageDataSampleBuffer: CMSampleBuffer!, error: NSError!) in
                    if imageDataSampleBuffer != nil {
                        weakSelf.stopRunning()
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                        let image = UIImage(data: imageData)
                        if let img = image {
                            print(">>>>>>>>>>image \(img.size)")
                            let scaleImage = FaceAPI.imageWithMaxSide(CGRectGetWidth(UIScreen.mainScreen().bounds) * 2, image: img)
                            let jpegData = UIImageJPEGRepresentation(scaleImage, 1)!
                            let base64Img = jpegData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                weakSelf.base64Img = base64Img
                                weakSelf.startAnimating()
                                
                                FaceAPI.requestIdcardOcr(base64Img, success: { (name, idcard) in
                                    weakSelf.stopAnimating()

                                    let controller = InputViewController(name: name, idcard: idcard)
                                    controller.base64Img = base64Img
                                    weakSelf.navigationController?.pushViewController(controller, animated: true)
                                }) {
                                    weakSelf.stopAnimating()
                                    weakSelf.showAlert()
                                }
                            })
                        }
                    }
                })
            }
        }
    }
    
    private func startAnimating() {
        stopAnimating()
        
        aiv = AlertIndicatorView(frame: CGRectZero)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(aiv)
        
        self.view.addConstraint(NSLayoutConstraint(item: aiv, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: aiv, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1, constant: 0))
        
        aiv.startAnimating()
    }
    
    private func stopAnimating() {
        if aiv != nil {
            aiv.stopAnimating()
            aiv.removeFromSuperview()
        }
    }

}
