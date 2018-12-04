//
//  ManualEntryViewController.swift
//  UnitedToolkitScan
//
//  Created by Team United Airlines on 10/18/18.
//  Copyright © 2018 Team United Airlines. All rights reserved.
//
//  Manual entry serves similar purpose as barcodecontroller but has a user input the barcode instead of scanning.

import UIKit
import KeychainAccess
import Alamofire
import AlamofireNetworkActivityIndicator

class ManualEntryViewController: UIViewController {
    var check_type: String!
    let sessionManager = loadSession()
    struct BarcodeJSONResponse: Decodable{
        let toolkit_name: String
        let toolkit_barcode: String
        let expected_tool_count: Int
    }
    var barcodeFromServ: String!
    
    @IBOutlet weak var manEntryField: UITextField!
    @IBAction func manEntryConfirm(_ sender: UIButton) {
        if (manEntryField.text == "") {
            let alert = UIAlertController(title: "ERROR", message: "Barcode Field Empty. Try Again.", preferredStyle: .actionSheet)
            let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        
        else{
            confirmBarcodeInDatabase()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func confirmBarcodeInDatabase(){
        let keychain = Keychain(service: "com.UnitedAirlinesCapstone.UnitedToolkitScan")
        let token = try? keychain.get("auth_token")
        print(token!!)
        
        let parameters: Parameters = [
            "barcode_text": manEntryField.text!
        ]
        
        let headers: HTTPHeaders = [
            "Authorization" : "Token " + token!!
        ]
        //Alamofire passes credentials to url to verify the existence of the barcode in the system
        let url = "https://35.9.22.103/image_verifier/api/barcode_validate/"
        _ = sessionManager.getManager().request(url, method:.post, parameters: parameters, encoding: URLEncoding(destination: .methodDependent), headers: headers).responseString { response in
            switch response.result {
            case .success:
                let jsonData = response.data
                print(response)
                let decoder = JSONDecoder()
                guard let decodedResponse = try? decoder.decode(BarcodeJSONResponse.self, from: jsonData!) else{
                    print("barcode not in DB")
                    let alert = UIAlertController(title: "ERROR", message: "Toolkit not found in database. Contact Administrator.", preferredStyle: .actionSheet)
                    let cancel = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler:nil)
                    alert.addAction(cancel)
                    
                    //different alert popup for iPads
                    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad )
                    {
                        if let currentPopoverpresentioncontroller = alert.popoverPresentationController{
                            currentPopoverpresentioncontroller.sourceView = self.view
                            currentPopoverpresentioncontroller.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                            currentPopoverpresentioncontroller.permittedArrowDirections = []
                            self.present(alert, animated: true, completion: nil)
                        }
                    }else{
                        self.present(alert, animated: true, completion: nil)
                        //present(alert, animated: true, completion: nil)
                        
                    }
                    
                    return
                }
                print(decodedResponse.expected_tool_count)
                let storyboard = UIStoryboard(name: "ToolkitCapture", bundle: Bundle.main)
                guard let controller = storyboard.instantiateViewController(withIdentifier: "CaptureToolkitStoryboard") as? CameraCaptureController else{
                    print("cannot find view controller")
                    return
                }
                self.barcodeFromServ = self.manEntryField.text!
                controller.barcodeFromServ = self.barcodeFromServ
                controller.check_type = self.check_type
                self.navigationController!.pushViewController(controller, animated: true)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is LoadingViewController
        {
            let loadView = segue.destination as? CameraCaptureController
            loadView?.barcodeFromServ = barcodeFromServ
            loadView?.check_type = check_type
        }
    }
}
