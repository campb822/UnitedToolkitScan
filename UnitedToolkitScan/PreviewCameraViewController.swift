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

    @IBAction func submitPhoto(_ sender: Any) {
        uploadImage()
    }
    let REST_UPLOAD_API_URL = "http://35.9.22.103/image_verifier/api/process_kit_image/"
    let REST_RETRIEVE_IMAGE_URL = "http://35.9.22.103/image_verifier/api/retrieve_processed_image/"

    struct ImageJSONResponse: Decodable{
        let auth_token: String
    }
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
            "description" : "Image test upload from app",
            "barcode_text" : 9567754
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
                        print("response: ")
                        print(response)
                        
                        self.getDataFromServer(DataResponse: response)
                        //controller.imgData = response.data!
                        //self.navigationController!.pushViewController(controller, animated: true)
                        
                    }
                case .failure(let encodingError):
                    print("encoding Error : \(encodingError)")
                }
        })
    }
    
    func getDataFromServer(DataResponse: Any){
        
        let keychain = Keychain(service: "com.UnitedAirlinesCapstone.UnitedToolkitScan")
        let token = try? keychain.get("auth_token")
        print(token!!)
        

        let parameters:[String: Any] = [
            "Authorization" : "Token " + token!!,
            "result_id": DataResponse
        ]
        
        let url = "http://35.9.22.103/image_verifier/api/retrieve_processed_image/"
        let request = Alamofire.request(url, method:.get, parameters: parameters, encoding: URLEncoding(destination: .methodDependent)).responseString { response in
            switch response.result {
            case .success:
                print("response description: ")
                print(response.description)
                let jsonData = response.data
                let decoder = JSONDecoder()
                guard let decodedResponse = try? decoder.decode(ImageJSONResponse.self, from: jsonData!) else{
                    return
                }
                print("decoded response: ")
                print(decodedResponse)
            case .failure(let error):
                print("error: ")
                print(error)
            }
        }
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

