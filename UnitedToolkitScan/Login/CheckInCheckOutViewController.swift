//
//  CheckInCheckOutViewController.swift
//  UnitedToolkitScan
//
//  Created by Team United Airlines on 10/15/18.
//  Copyright © 2018 Team United Airlines. All rights reserved.
//

import UIKit
import Alamofire
import KeychainAccess

class CheckInCheckOutViewController: UIViewController {

    var check_type: String!
    let sessionManager = loadSession()
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        logout()
    }
    //check_type represents if user is checking in or checking out toolkit. Passed through vc's until image sent to server
    @IBAction func checkInButtonPush(_ sender: UIButton) {
        self.check_type = "in"
        loadNextStoryboard()
    }
    
    @IBAction func checkOutButtonPush(_ sender: UIButton) {
        self.check_type = "out"
        loadNextStoryboard()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    //Load barcode capture storyboard
    func loadNextStoryboard(){
        let storyboard = UIStoryboard(name: "BarcodeCapture", bundle: Bundle.main)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "BarcodeScanner") as? BarcodeScanner else{
            print("cannot find view controller")
            return
        }
        controller.check_type = self.check_type
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    func logout(){
        let url = "https://35.9.22.103/image_verifier/api/logout/"
        
        let keychain = Keychain(service: "com.UnitedAirlinesCapstone.UnitedToolkitScan")
        let token = try? keychain.get("auth_token")
        print(token!!)
        
        let headers: HTTPHeaders = [
            "Authorization" : "Token " + token!!
        ]
        _ = sessionManager.getManager().request(url, method: .post, encoding:
            URLEncoding(destination: .methodDependent),headers: headers).responseString{ response in
                switch response.result{
                case .success:
                    
                    print("success")
                    print(response.description)
                
                case .failure:
                    print("failure")
                    print(response.description)
                }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is BarcodeScanner
        {
            let loadView = segue.destination as? BarcodeScanner
            loadView?.check_type = self.check_type
        }
    }
}
