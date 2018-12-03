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
    var barcodeFromServ: String!
    
    var expected_tool_count : Int!
    var result_id: Int!
    var tool_count: Int!
    var toolkit_name: String!
    var toolkit_barcode: String!
    var check_type: String!
    
    @IBOutlet weak var photo: UIImageView!

    @IBAction func submitPhoto(_ sender: Any) {
        uploadImage()
    }
    let REST_UPLOAD_API_URL = "https://35.9.22.103/image_verifier/api/process_kit_image/"
    let REST_RETRIEVE_IMAGE_URL = "https://35.9.22.103/image_verifier/api/retrieve_processed_image/"

    struct ImageJSONResponse: Decodable{
        let auth_token: String
    }
    
    struct Img2JSONResponse:Decodable{
        let expected_tool_count: Int;
        let result_id: Int;
        let tool_count: Int;
        let toolkit_barcode: String;
        let toolkit_name: String;
    }
    let sessionManager = loadSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photo.image = self.img
    }
    
    func uploadImage() {

        let imgFromServLoadingView = UIStoryboard(name: "ImgProcessingLoading", bundle: Bundle.main)
        guard let controller1 = imgFromServLoadingView.instantiateViewController(withIdentifier: "imgLoadViewController") as? ImgProcessingLoadingViewController else{
            print("cannot find view controller")
            return
        }
        self.navigationController!.pushViewController(controller1, animated: true)
        
        let keychain = Keychain(service: "com.UnitedAirlinesCapstone.UnitedToolkitScan")
        let token = try? keychain.get("auth_token")
        print(token!!)
        let headers: HTTPHeaders = [
            "Authorization" : "Token " + token!!
        ]
        let parameters: Parameters = [
            "name": "test",
            "description" : "Image test upload from app",
            "barcode_text" : barcodeFromServ!,
            "check_type" : check_type!
        ]
        
        sessionManager.getManager().upload(
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
                        print(response.description)
                        let responseJSON = response.data
                        let decoder = JSONDecoder()
                        
                        guard let decodedResponse = try? decoder.decode(Img2JSONResponse.self, from: responseJSON!) else{
                            print("error")
                            let alertPrompt = UIAlertController(title: "Image Processing Timed Out", message: "Please Try Again.",preferredStyle: .alert)
                            let alert = UIAlertAction( title: "Go Back", style: UIAlertAction.Style.default, handler: { (action) -> Void in
                                self.navigationController!.popViewController(animated: true)
                            })
                            alertPrompt.addAction(alert)
                            self.present(alertPrompt, animated: true)
                            
                            return
                        }
                        self.getDataFromServer(DataResponse: decodedResponse)

                        
                    }
                case .failure(let encodingError):
                    print("encoding Error : \(encodingError)")
                }
        })
    }
    
    func getDataFromServer(DataResponse: Img2JSONResponse){
        let loadingView = UIStoryboard(name: "Loading", bundle: Bundle.main)
        guard let controller = loadingView.instantiateViewController(withIdentifier: "loadViewController1") as? LoadingViewController else{
            print("cannot find view controller")
            return
        }
        let keychain = Keychain(service: "com.UnitedAirlinesCapstone.UnitedToolkitScan")
        let token = try? keychain.get("auth_token")
        print(token!!)
        

        let parameters:[String: Any] = [
            "resultId": DataResponse.result_id
        ]
        
        let headers: HTTPHeaders = [
            "Authorization" : "Token " + token!!
        ]
        let url = "https://35.9.22.103/image_verifier/api/retrieve_processed_image/"
        _ = sessionManager.getManager().request(url, method:.get, parameters: parameters, encoding: URLEncoding(destination: .methodDependent), headers: headers).responseString { response in
            switch response.result {
            case .success:
                controller.imgData = response.data!
                controller.expected_tool_count = DataResponse.expected_tool_count
                controller.result_id = DataResponse.result_id
                controller.tool_count = DataResponse.tool_count
                controller.toolkit_barcode = DataResponse.toolkit_barcode
                controller.toolkit_name = DataResponse.toolkit_name
                controller.check_type = self.check_type
                self.navigationController!.pushViewController(controller, animated: true)

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
            loadView?.expected_tool_count = self.expected_tool_count
            loadView?.result_id = self.result_id
            loadView?.tool_count = self.tool_count
            loadView?.toolkit_barcode = self.toolkit_barcode
            loadView?.toolkit_name = self.toolkit_name
            loadView?.check_type = self.check_type
        }
    }

}





