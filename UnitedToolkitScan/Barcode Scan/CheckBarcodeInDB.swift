////
////  CheckBarcodeInDB.swift
////  UnitedToolkitScan
////
////  Created by Team United Airlines on 11/2/18.
////  Copyright © 2018 Team United Airlines. All rights reserved.
////
//
//import Foundation
//import Alamofire
//import AlamofireNetworkActivityIndicator
//import KeychainAccess
//import UIKit
//
//class CheckBarcodeInDB{
//    let sessionManager = loadSession()
//    //Decodable JSON for authentication token from Django server
//    struct BarcodeJSONResponse: Decodable{
//        let toolkit_name: String
//        let toolkit_barcode: String
//        let expected_tool_count: Int
//    }
//    
//    func SendBarcodeToServer(decodedBarcode: String){
//        let keychain = Keychain(service: "com.UnitedAirlinesCapstone.UnitedToolkitScan")
//        let token = try? keychain.get("auth_token")
//        print(token!!)
//        
//        let parameters: Parameters = [
//            "barcode_text": decodedBarcode
//        ]
//        
//        let headers: HTTPHeaders = [
//            "Authorization" : "Token " + token!!
//        ]
//        //Alamofire passes credentials to url to verify the existence of the barcode in the system
//        let url = "https://35.9.22.103/image_verifier/api/barcode_validate/"
//        _ = sessionManager.getManager().request(url, method:.post, parameters: parameters, encoding: URLEncoding(destination: .methodDependent), headers: headers).responseString { response in
//            switch response.result {
//            case .success:
//                let jsonData = response.data
//                print(response)
//                let decoder = JSONDecoder()
//                guard let decodedResponse = try? decoder.decode(BarcodeJSONResponse.self, from: jsonData!) else{
//                    print("barcode not in DB")
//                    let alert = UIAlertController(title: "ERROR", message: "Toolkit not found in database. Try again.", preferredStyle: .actionSheet)
//                    let manEntryOption = UIAlertAction(title: "Manual Entry", style:UIAlertAction.Style.default, handler:{(action) -> Void in
//                        self.manEntry.sendActions(for: .touchUpInside)
//                    })
//                    let cancel = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler:nil)
//                    alert.addAction(manEntryOption)
//                    alert.addAction(cancel)
//                    self.present(alert, animated: true, completion: nil)
//                    return
//                }
//                print(decodedResponse.expected_tool_count)
//                let storyboard = UIStoryboard(name: "ToolkitCapture", bundle: Bundle.main)
//                guard let controller = storyboard.instantiateViewController(withIdentifier: "CaptureToolkitStoryboard") as? CameraCaptureController else{
//                    print("cannot find view controller")
//                    return
//                }
//                self.navigationController!.pushViewController(controller, animated: true)
//                
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
//}
