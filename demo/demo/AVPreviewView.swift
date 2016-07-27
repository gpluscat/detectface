//
//  AVPreviewView.swift
//  demo
//
//  Created by qing on 16/7/18.
//  Copyright © 2016年 qing. All rights reserved.
//

import UIKit
import AVFoundation

class AVPreviewView: UIView {
    
    var session: AVCaptureSession {
        get {
            let previewLayer = self.layer as! AVCaptureVideoPreviewLayer
            return previewLayer.session
        }
        set {
            let previewLayer = self.layer as! AVCaptureVideoPreviewLayer
            previewLayer.session = newValue
        }
    }
    
    override class func layerClass() -> AnyClass {
        return AVCaptureVideoPreviewLayer.classForCoder()
    }
    
    class func deviceWithMediaType(mediaType: String, position: AVCaptureDevicePosition) -> AVCaptureDevice {
        let devices = AVCaptureDevice.devicesWithMediaType(mediaType)
        var captureDevice = devices.first
        for device in devices {
            if device.position == position {
                captureDevice = device
                break
            }
        }
        return captureDevice as! AVCaptureDevice
    }

}
