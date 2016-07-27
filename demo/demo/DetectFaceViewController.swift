//
//  DetectFaceViewController.swift
//  demo
//
//  Created by qing on 16/7/20.
//  Copyright © 2016年 qing. All rights reserved.
//

import UIKit
import AVFoundation

class DetectFaceViewController: UIViewController {

    @IBOutlet weak var previewView: AVPreviewView!
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var noBgView: UIView!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var lineViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var no1: UILabel!
    @IBOutlet weak var no2: UILabel!
    @IBOutlet weak var no3: UILabel!
    @IBOutlet weak var no4: UILabel!
    @IBOutlet weak var no5: UILabel!
    @IBOutlet weak var no6: UILabel!
    @IBOutlet weak var no7: UILabel!
    @IBOutlet weak var no8: UILabel!
    
    @IBOutlet weak var countDownLabel: UILabel!
    private var countDown: Int = 4
    private var noTag: Int = 0
    
    private var timer: NSTimer!
    
    private var session: AVCaptureSession!
    private var videoDeviceInput: AVCaptureDeviceInput!
    private var stillImageOutput: AVCaptureStillImageOutput!
    
    private var sessionQueue: dispatch_queue_t!
    
    private enum AVCameraSetupResult: Int {
        case AVSetupResultSuccess
        case AVSetupResultCameraNotAuthorized
        case AVSetupResultSessionConfigurationFailed
    }
    private var setupResult: AVCameraSetupResult = .AVSetupResultSuccess
    
    private var aiv: AlertIndicatorView!
    
    private var name: String = ""
    private var idcard: String = ""
    var base64Img: String = ""
    private var base64ImgB: String = ""
    private var voiceStr: String = ""
    
    init(name: String, idcard: String) {
        super.init(nibName: "DetectFaceViewController", bundle: nil)
        
        self.name = name
        self.idcard = idcard
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "读取人脸信息"
        self.view.backgroundColor = UIColor.whiteColor()
        
        let item = UIBarButtonItem(title: "返回", style: .Plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = item
        
        self.tipLabel.text = "请将摄像头对准您的脸\n点击开始，3秒后会有随机数字出现\n请大声朗读数字"
        self.startButton.setImage(UIImage(named: "microphone_ing"), forState: .Disabled)
        self.noBgView.layer.borderWidth = 2
        self.noBgView.layer.borderColor = UIColor.blackColor().CGColor
        
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
            
            let videoDevice = AVPreviewView.deviceWithMediaType(AVMediaTypeVideo, position: AVCaptureDevicePosition.Front)
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
        
        FlySpeech.createUtility()
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
        sender.enabled = false
        
        self.tipLabel.hidden = true
        self.noBgView.hidden = false
        
        createRandom()
        
        /// 3s
//        let delayInSeconds = 3.0
//        let popTime = dispatch_time(DISPATCH_TIME_NOW,
//                                    Int64(delayInSeconds * Double(NSEC_PER_SEC)))
//        dispatch_after(popTime, dispatch_get_main_queue()) { [weak self] in
//            if let weakSelf = self {
//                weakSelf.createRandom()
//                
//                
//            }
//        }
    }
    
    /// 生成随机数
    private func createRandom() {
        removeTimer()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(timerHandler), userInfo: nil, repeats: true)
    }
    
    func timerHandler() {
        self.countDown -= 1
        if self.countDown > 0 {
            self.countDownLabel.text = "\(self.countDown)"
        }

        if self.countDown == 0 {
            self.countDownLabel.hidden = true
            FlySpeech.sharedInstance().success = { [weak self] (result: String!) in
                print(">>>>>>>>>>voice result \(result)")
                if let weakSelf = self {
                    weakSelf.voiceStr = result
                }
            }
            FlySpeech.sharedInstance().failure = {
                print(">>>>>>>>>>voice failure")
            }
            FlySpeech.sharedInstance().startListening()
        }
        
        if self.countDown > 0 {
            return
        }
        let r = Int(arc4random() % 10) // 0~9
        let rStr = "\(r)"
        print(">>>>>>>>>>\(rStr)")
        if self.noTag == 0 {
            self.no1.text = rStr
            self.noTag = 1
        }
        else if self.noTag == 1 {
            self.no2.text = rStr
            self.noTag = 2
        }
        else if self.noTag == 2 {
            self.no3.text = rStr
            self.noTag = 3
        }
        else if self.noTag == 3 {
            self.no4.text = rStr
            self.noTag = 4
        }
        else if self.noTag == 4 {
            self.no5.text = rStr
            self.noTag = 5
        }
        else if self.noTag == 5 {
            self.no6.text = rStr
            self.noTag = 6
        }
        else if self.noTag == 6 {
            self.no7.text = rStr
            self.noTag = 7
        }
        else if self.noTag == 7 {
            self.no8.text = rStr
            self.noTag = 8
        }
        
        let width = self.view.frame.size.width - 20
        let sepWidth = width / 8
        self.lineViewWidthConstraint.constant += sepWidth
        
        if self.noTag >= 8 {
            removeTimer()
            FlySpeech.sharedInstance().stopListening()
            // 处理数据
            snapStillImage()
        }
    }
    
    private func removeTimer() {
        if self.timer != nil {
            self.timer.invalidate()
            self.timer = nil
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeTimer()
        
        FlySpeech.sharedInstance().cancel()
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
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                        let image = UIImage(data: imageData)
                        if let img = image {
                            print(">>>>>>>>>>image \(img.size)")
                            let scaleImage = FaceAPI.imageWithMaxSide(CGRectGetWidth(UIScreen.mainScreen().bounds) * 2, image: img)
                            let jpegData = UIImageJPEGRepresentation(scaleImage, 1)!
                            let base64Img = jpegData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                weakSelf.startAnimating()
                                weakSelf.base64ImgB = base64Img
                                
                                FaceAPI.requestDetectFace(base64Img, success: { (face: [[String: AnyObject]]) in
                                    print(">>>>>>>>>>face \(face)")
                                    // 检测出人脸
                                    weakSelf.faceCompare()
                                    }, failure: {
                                        weakSelf.faceCompare()
                                })
                            })
                        }
                    }
                })
            }
        }
    }
    
    ///
    /// 人脸比较
    ///
    private func faceCompare() {
        FaceAPI.requestFaceCompare(base64Img, base64ImgB: base64ImgB, success: { [weak self] (similarity: Float) in
            if let weakSelf = self {
                weakSelf.stopAnimating()
                print(">>>>>>>>>>similarity \(similarity)")
                
                let nav = weakSelf.navigationController
                nav?.popViewControllerAnimated(false)
                
                let voiceTag = weakSelf.voiceStr.characters.count > 0 ? "成功" : "失败"
                let controller = AuthCompleteViewController(name: weakSelf.name, voice: voiceTag, similarity: "\(similarity)")
                nav?.pushViewController(controller, animated: true)
            }
        }) { [weak self] in
            if let weakSelf = self {
                weakSelf.stopAnimating()
                
                let nav = weakSelf.navigationController
                nav?.popViewControllerAnimated(false)
                let voiceTag = weakSelf.voiceStr.characters.count > 0 ? "成功" : "失败"
                let controller = AuthCompleteViewController(name: weakSelf.name, voice: voiceTag, similarity: "失败")
                nav?.pushViewController(controller, animated: true)
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
