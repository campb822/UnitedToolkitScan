//
//  PreviewCameraViewController.swift
//  UnitedToolkitScan
//
//  Created by Scott Campbell on 10/10/18.
//  Copyright © 2018 Team United Airlines. All rights reserved.
//

import UIKit
import Alamofire
import KeychainAccess
import AVFoundation

class PreviewCameraViewController: UIViewController {

    var img: UIImage!
    var imageData: Data!
    var imgFromServerData: Data!
    @IBOutlet weak var photo: UIImageView!

    //@IBOutlet weak var imageFromServer: UIImageView!
    //var imgFromServer: UIImage!
    @IBAction func submitPhoto(_ sender: Any) {
        uploadImage()
    }
    let REST_UPLOAD_API_URL = "http://35.9.22.103/image_verifier/api/process_kit_image/"


    override func viewDidLoad() {
        super.viewDidLoad()
        photo.image = self.img
    }
    
    func uploadImage() {
        let loadingView = UIStoryboard(name: "Loading", bundle: Bundle.main)
        let imgFromServLoadingView = UIStoryboard(name: "ImgProcessingLoading", bundle: Bundle.main)
        //loadingView.imgData = response.data!
        guard let controller = loadingView.instantiateViewController(withIdentifier: "loadViewController1") as? LoadingViewController else{
            print("cannot find view controller")
            return
        }
        guard let controller1 = imgFromServLoadingView.instantiateViewController(withIdentifier: "imgLoadViewController") as? ImgProcessingLoadingViewController else{
            print("cannot find view controller")
            return
        }
        self.navigationController!.pushViewController(controller1, animated: true)
        
        let keychain = Keychain(service: "com.UnitedAirlinesCapstone.UnitedToolkitScan")
        let token = try? keychain.get("auth_token")
        print(token!!)
        
        let headers = [
            "Authorization" : "Token " + token!!
        ]
        let parameters: Parameters = [
            "name": "test",
            "description" : "Image test upload from app"
        ]
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                if let image = self.img {
                    let imageData = image.jpegData(compressionQuality: 1)
                    
                    multipartFormData.append(imageData!, withName: "technician_image", fileName: "photo.jpg", mimeType: "jpeg")
                    
                }
                for (key, value) in parameters {
                    if value is String || value is Int {
                        multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                    }
                }
        },
            to: REST_UPLOAD_API_URL,
            headers: headers,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        
                        debugPrint(response)
                        //let loadingView = LoadingViewController(nibName: "LoadingViewController", bundle:nil)
                        
                        //self.navigationController?.pushViewController(loadingView, animated: true)
                        //loadingView.imgData = response.data!
                        controller.imgData = response.data!
                        //self.performSegue(withIdentifier: "showLoadingSegue", sender: nil)
                        //self.imageFromServer.image = UIImage(data: (response.data!))
                        
                        self.navigationController!.pushViewController(controller, animated: true)
                        
                    }
                case .failure(let encodingError):
                    print("encoding Error : \(encodingError)")
                }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is LoadingViewController
        {
            let loadView = segue.destination as? LoadingViewController
            loadView?.imgData = self.imgFromServerData
        }
    }

}



@IBDesignable extension UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

