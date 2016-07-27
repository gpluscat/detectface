//
//  FaceAPI.swift
//  demo
//
//  Created by qing on 16/7/19.
//  Copyright © 2016年 qing. All rights reserved.
//

import UIKit
import Alamofire

class FaceAPI: NSObject {
    /// 优图
    static let YOUTU_APPID = "10034256"
    static let YOUTU_SECRETID = "AKIDPnGqr5L8FXzGGboURgQ7DxtBJ7FyoRI8"
    static let YOUTU_SECRETKEY = "alxyk5MQoB713Lfofg6DvjCS6JwCp6gD"
    static let YOUTU_AUTHORIZATION = Auth.appSignWithAppId(YOUTU_APPID, withSecretId: YOUTU_SECRETID, withSecretKey: YOUTU_SECRETKEY)
    
    /// 百度Voice
    static let BAIDU_VOICE_APPID = "7102398"
    static let BAIDU_VOICE_APIKEY = "Doe5jalGyce5jQGhk9zTEfOF"
    static let BAIDU_VOICE_SECRETKEY = "uSSNVGFNDWzsZeCb4iFF4NykmM2zi8S1"
    
    static let YOUTU_BASE_API_URL = "http://api.youtu.qq.com/youtu/"
    /// 身份证ocr识别
    static let IDCARDOCR_API_URL = "\(YOUTU_BASE_API_URL)ocrapi/idcardocr"
    /// 人脸检测
    static let DETECTFACE_API_URL = "\(YOUTU_BASE_API_URL)api/detectface"
    /// 人脸对比
    static let FACECOMPARE_API_URL = "\(YOUTU_BASE_API_URL)api/facecompare"
    
    ///
    /// 身份证照片识别接口
    ///
    class func requestIdcardOcr(base64Img: String , success: ((name: String, idcard: String) -> Void)?, failure: (() -> Void)?) {
        
        sendRequest(["app_id": YOUTU_APPID, "card_type": 0, "image": base64Img], url: IDCARDOCR_API_URL, success: { (result: [String: AnyObject]) in
            let idcard = result["id"] as! String
            let name = result["name"] as! String
            
            if let closure = success {
                closure(name: name, idcard: idcard)
            }
            }, failure: failure)
    }
    
    private class func sendRequest(params: [String: AnyObject], url: String, success:((result: [String: AnyObject]) -> Void)?, failure: (() -> Void)?) {
        Alamofire.request(.POST, url, parameters: params, encoding: .JSON, headers: ["Content-Type": "text/json", "Authorization": YOUTU_AUTHORIZATION]).responseJSON { (response: Response<AnyObject, NSError>) in
            print(">>>>>>>>>>response \(response.result.value)")
            if response.result.isSuccess {
                if let json = response.result.value {
                    let jsonData = json as! [String: AnyObject]
                    let errorcode = jsonData["errorcode"] as! Int
                    
                    if errorcode == 0 {
                        if let closure = success {
                            closure(result: jsonData)
                        }
                    }
                    else {
                        if let closure = failure {
                            closure()
                        }
                    }
                }
            }
            else {
                if let closure = failure {
                    closure()
                }
            }
        }
    }
    
    
    ///
    /// 人脸识别
    ///
    class func requestDetectFace(base64Img: String , success: ((face: [[String: AnyObject]]) -> Void)?, failure: (() -> Void)?) {
        sendRequest(["app_id": YOUTU_APPID, "image": base64Img], url: DETECTFACE_API_URL, success: { (result: [String: AnyObject]) in
            let face = result["face"] as! [[String: AnyObject]]
            if let closure = success {
                closure(face: face)
            }
            }, failure: failure)
        
        //        {
        //            errorcode = 0;
        //            errormsg = OK;
        //            face =     (
        //                {
        //                    age = 42;
        //                    beauty = 73;
        //                    expression = 23;
        //                    "face_id" = 1618694494172020735;
        //                    gender = 99;
        //                    glass = 1;
        //                    height = 595;
        //                    pitch = "-5";
        //                    roll = 1;
        //                    width = 595;
        //                    x = 44;
        //                    y = 388;
        //                    yaw = 0;
        //                }
        //            );
        //            "image_height" = 1280;
        //            "image_width" = 720;
        //            "session_id" = "";
        //        }
    }
    
    ///
    /// 人脸对比
    ///
    class func requestFaceCompare(base64ImgA: String, base64ImgB: String, success: ((similarity: Float) -> Void)?, failure: (() -> Void)?) {
        sendRequest(["app_id": YOUTU_APPID, "imageA": base64ImgA, "imageB": base64ImgB], url: FACECOMPARE_API_URL, success: { (result: [String: AnyObject]) in
            let similarity = result["similarity"] as! Float
            if let closure = success {
                closure(similarity: similarity)
            }
            }, failure: failure)
    }
    
    ///
    /// 获取 Baidu Access Token
    ///
    class func oauthBaiduVoice(success: ((token: String) -> Void)?, failure: (() -> Void)?) {
        let urlString = "https://openapi.baidu.com/oauth/2.0/token?grant_type=client_credentials&client_id=\(BAIDU_VOICE_APIKEY)&client_secret=\(BAIDU_VOICE_SECRETKEY)"
        print(">>>>>>>>>>urlString \(urlString)")
        Alamofire.request(.GET, urlString, parameters: nil, encoding: .JSON, headers: ["Content-Type": "application/json"]).responseJSON { (response: Response<AnyObject, NSError>) in
            print(">>>>>>>>>>response \(response)")
            if response.result.isSuccess {
                if let json = response.result.value {
                    let jsonData = json as! [String: AnyObject]
                    let accessToken = jsonData["access_token"] as! String
                    
                    if let closure = success {
                        closure(token: accessToken)
                    }
                }
            }
            else {
                if let closure = failure {
                    closure()
                }
            }
        }
        
        //        {
        //            "access_token" = "24.a02da3630ad007b0cc423f4a5088a4c1.2592000.1471687112.282335-7102398";
        //            "expires_in" = 2592000;
        //            "refresh_token" = "25.7d82a5c990f4f37088e9280139500e8a.315360000.1784455112.282335-7102398";
        //            scope = "public audio_voice_assistant_get wise_adapt lebo_resource_base lightservice_public hetu_basic lightcms_map_poi kaidian_kaidian wangrantest_test wangrantest_test1 vis-faceverify_faceverify bnstest_test1";
        //            "session_key" = "9mzdWuzpe0v/HKcg0nafcCGlMQTz/0C3Faw/hEGJGXipweP6xSR5BLYV/Y3mqwIt6kt0DvX/0L/UGlqXSjm9bNBjOYRR";
        //            "session_secret" = 2e563edda637f4b56cdcffceaa19657d;
        //        }
    }
    
    
    ///
    /// Baidu Voice
    ///
    class func vop(token: String, speech: String, len: Int) {
        let params: [String: AnyObject] = ["format": "wav", "rate": 8000, "channel": 1, "cuid": "ef0d06fef07e3c3f3c03853101133f79c3d6ae05", "token": token, "speech": speech, "len": len]
        Alamofire.request(.POST, "http://vop.baidu.com/server_api", parameters: params, encoding: .JSON, headers: ["Content-Type": "application/json;charset=UTF-8"]).responseJSON { (response: Response<AnyObject, NSError>) in
            print(">>>>>>>>>>response \(response)")
        }
        
        //        Alamofire.request(.POST, "http://www.google.com/speech-api/v1/recognize?xjerr=1&lang=zh-CN&maxresults=1").responseData { (response: Response<NSData, NSError>) in
        //            print(">>>>>>>>>>response aa \(response)")
        //        }
    }
    
    private class func dictToJson(dict: [String: AnyObject]){
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.PrettyPrinted)
            let jsonStr = String(data: jsonData, encoding: NSUTF8StringEncoding)
            if let json = jsonStr {
                print(">>>>>>>>>>jsonStr \(json)")
            }
        }
        catch {
            
        }
    }
    
    ///
    /// 等比例缩放图片
    ///
    class func imageWithMaxSide(length: CGFloat, image: UIImage) -> UIImage {
        let scale = UIScreen.mainScreen().scale
        let imgSize = imageSizeScale(image.size, limit: length)
        
        UIGraphicsBeginImageContextWithOptions(imgSize, true, scale)
        image.drawInRect(CGRectMake(0, 0, imgSize.width, imgSize.height), blendMode: .Normal, alpha: 1)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    private class func imageSizeScale(size: CGSize, limit: CGFloat) -> CGSize {
        let max = size.width > size.height ? size.width : size.height
        if max < limit {
            return size
        }
        var imgSize: CGSize
        let ratio = size.height / size.width
        if size.width > size.height {
            imgSize = CGSizeMake(limit, limit * ratio)
        }
        else {
            imgSize = CGSizeMake(limit / ratio, limit)
        }
        return imgSize
    }
}
