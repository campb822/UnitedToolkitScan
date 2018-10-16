//
//  PreviewCameraViewController.swift
//  UnitedToolkitScan
//
//  Created by Scott Campbell on 10/10/18.
//  Copyright © 2018 Team United Airlines. All rights reserved.
//

import UIKit
import Alamofire

class PreviewCameraViewController: UIViewController {

    var img: UIImage!
    @IBOutlet weak var photo: UIImageView!
    @IBAction func retakePhoto(_ sender: Any) {
        dismiss(animated:true, completion:nil)
    }
    @IBAction func submitPhoto(_ sender: Any) {
        //uploadImage()
    }
//    let REST_UPLOAD_API_URL = "my url"
//
//    let headers = [
//        "Authorization": "authToken"
//    ]
//
//    let parameters: Parameters = [
//        "name": "test", "description" : "Image test upload from iOS"
//    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photo.image = self.img
        
        //let authTkn = "Token \(user_token)"
        
        
        
        
    }
    
//    func uploadImage() {
//        Alamofire.upload(
//            multipartFormData: { multipartFormData in
//                if let image = self.img {
//                    let imageData = UIImageJPEGRepresentation(image, 0.8)
//                    multipartFormData.append(imageData!, withName: "image", fileName: "photo.jpg", mimeType: "jpg/png")
//                }
//                for (key, value) in parameters {
//                    if value is String || value is Int {
//                        multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
//                    }
//                }
//        },
//            to: REST_UPLOAD_API_URL,
//            headers: headers,
//            encodingCompletion: { encodingResult in
//                switch encodingResult {
//                case .success(let upload, _, _):
//                    upload.responseJSON { response in
//                        debugPrint(response)
//
//                    }
//                case .failure(let encodingError):
//                    print("encoding Error : \(encodingError)")
//                }
//        })
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
