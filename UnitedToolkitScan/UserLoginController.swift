//
//  UserLoginController.swift
//  UnitedToolkitScan
//
//  Created by Team United Airlines on 9/30/18.
//  Copyright © 2018 Team United Airlines. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import KeychainAccess

class UserLogin: UIViewController, UITextFieldDelegate{
    

    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    struct JSONResponse: Decodable{
        let auth_token: String
    }
    
    @IBAction func login(_ sender: UIButton) {
        loginButtonPressed()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true;
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        self.navigationController?.isNavigationBarHidden = false;
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == username){
            username.resignFirstResponder()
            password.becomeFirstResponder()
        }
        else{
            password.resignFirstResponder()
            loginButtonPressed()
        }
        
        return true
    }
    
    func loginButtonPressed(){
        if(username.text == "" || password.text == ""){
            let alert = UIAlertController(title: "Missing Login Information", message: "A username or password was not entered. Please try again.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            
            
            self.present(alert, animated: true)
        }
        
        else{

            let parameters:[String: Any] = [
                "username": username.text!,
                "password": password.text!
            ]
            
            
            let url = "http://35.9.22.103/image_verifier/api/login/"
            let request = Alamofire.request(url, method:.post, parameters: parameters, encoding: URLEncoding(destination: .methodDependent)).responseString { response in
                switch response.result {
                case .success:
                    print("success")
                    print(response.description)
                    if(response.description == "SUCCESS: Get outta here")
                    {
                        let loginAlert = UIAlertController(title: "User Not Found", message: "User not found in system. Contact System Administrator.", preferredStyle: .alert)
                        
                        loginAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        
                        
                        self.present(loginAlert, animated: true)
                        print("you cannot login")
                    }
                    else{
                        let jsonData = response.data
                        let decoder = JSONDecoder()
                        guard let decodedKey = try? decoder.decode(JSONResponse.self, from: jsonData!) else{
                            print("error with auth key")
                            return
                        }
                        
                        let keychain = Keychain(service: "com.UnitedAirlinesCapstone.UnitedToolkitScan")
                        keychain["auth_token"] = decodedKey.auth_token
                        
                        
                        let storyboard = UIStoryboard(name: "CheckInCheckOut", bundle: Bundle.main)
                        guard let controller = storyboard.instantiateViewController(withIdentifier: "CheckInCheckOutStoryboard") as? CheckInCheckOutViewController else{
                            print("cannot find view controller")
                            return
                        }
                        
                        print(keychain["auth_token"] ?? "")
                        self.navigationController!.pushViewController(controller, animated: true)
                    }

                case .failure(let error):
                    print("error")
                    print(error)
                }
            }
        }
    }
}
